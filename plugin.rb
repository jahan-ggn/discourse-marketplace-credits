# frozen_string_literal: true

# name: discourse-marketplace-credits
# about: Controls topic creation in a Marketplace category using a credit-based system
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-marketplace-credits

enabled_site_setting :discourse_marketplace_credits_enabled

module ::DiscourseMarketplaceCredits
  PLUGIN_NAME = "discourse-marketplace-credits"
end

require_relative "lib/discourse_marketplace_credits/engine"
require_relative "lib/discourse_marketplace_credits/credit_manager"

register_asset "stylesheets/common.scss"

after_initialize do
  add_to_serializer(:current_user, :marketplace_credits) do
    object.custom_fields["marketplace_credits"].to_i
  end

  add_model_callback(::DiscourseSubscriptions::Customer, :after_save) do
    next if self.product_id.blank?
    next if SiteSetting.marketplace_stripe_product_id.blank?
    next if self.product_id != SiteSetting.marketplace_stripe_product_id

    user = ::User.find_by(id: self.user_id)
    next if user.blank?

    ::DiscourseMarketplaceCredits::CreditManager.add(user)
  end

  add_model_callback(::Topic, :before_save) do
    if persisted? && category_id_changed?
      if ::DiscourseMarketplaceCredits::CreditManager.marketplace_category?(category_id)
        purchase_link = ""
        if SiteSetting.marketplace_stripe_product_id.present?
          link_text = SiteSetting.marketplace_purchase_link_text
          url = "/s/#{SiteSetting.marketplace_stripe_product_id}"
          purchase_link = "<a href='#{url}' target='_blank'>#{link_text}</a>"
        end

        error_message = SiteSetting.cannot_move_to_marketplace_message.gsub("%{purchase_link}", purchase_link)
        errors.add(:base, error_message)
        throw(:abort)
      end
    end
  end

  NewPostManager.add_handler do |manager|
    next unless manager.args[:topic_id].blank?
    next unless ::DiscourseMarketplaceCredits::CreditManager.marketplace_category?(manager.args[:category])

    user = manager.user
    next if user.staff?

    unless ::DiscourseMarketplaceCredits::CreditManager.deduct(user)
      purchase_link = ""
      if SiteSetting.marketplace_stripe_product_id.present?
        link_text = SiteSetting.marketplace_purchase_link_text
        url = "/s/#{SiteSetting.marketplace_stripe_product_id}"
        purchase_link = "<a href='#{url}' target='_blank'>#{link_text}</a>"
      end
      error_message = SiteSetting.out_of_credits_message.gsub("%{purchase_link}", purchase_link)
      result = NewPostResult.new(:created_post, false)
      result.errors.add(:base, error_message)
      next result
    end

    nil
  end

  DiscourseEvent.on(:topic_created) do |topic, opts, user|
    if ::DiscourseMarketplaceCredits::CreditManager.marketplace_category?(topic.category_id)
      topic.set_or_create_timer(
        TopicTimer.types[:delete],
        SiteSetting.topic_expiry_days * 24,
        by_user: Discourse.system_user
      )
    end
  end
end
