# frozen_string_literal: true

module ::DiscourseMarketplaceCredits
  class CreditManager
    FIELD_NAME = "marketplace_credits"
    CHANNEL = "/marketplace-credits"

    def self.remaining(user)
      return 0 if user.blank?
      user.custom_fields[FIELD_NAME].to_i
    end

    def self.can_create?(user)
      remaining(user) > 0
    end

    def self.add(user, amount = nil)
      return if user.blank?

      amount ||= SiteSetting.credits_per_purchase

      DistributedMutex.synchronize("marketplace_credits_#{user.id}") do
        current = remaining(user)
        new_credits = current + amount
        user.custom_fields[FIELD_NAME] = new_credits
        user.save_custom_fields

        MessageBus.publish(CHANNEL, { credits: new_credits }, user_ids: [user.id])
      end
    end

    def self.deduct(user)
      return false if user.blank?

      DistributedMutex.synchronize("marketplace_credits_#{user.id}") do
        current = remaining(user)
        return false if current <= 0

        new_credits = current - 1
        user.custom_fields[FIELD_NAME] = new_credits
        user.save_custom_fields

        MessageBus.publish(CHANNEL, { credits: new_credits }, user_ids: [user.id])

        true
      end
    end

    def self.marketplace_category?(category_id)
      return false if category_id.blank?

      marketplace_id = SiteSetting.marketplace_category.to_i
      return false if marketplace_id <= 0

      category_id = category_id.to_i
      return true if category_id == marketplace_id

      Category.find_by(id: category_id)&.parent_category_id == marketplace_id
    end
  end
end
