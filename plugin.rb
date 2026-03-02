# frozen_string_literal: true

# name: discourse-marketplace-credits
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_marketplace_credits_enabled

module ::DiscourseMarketplaceCredits
  PLUGIN_NAME = "discourse-marketplace-credits"
end

require_relative "lib/discourse_marketplace_credits/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
