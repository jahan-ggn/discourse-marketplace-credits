# frozen_string_literal: true

DiscourseMarketplaceCredits::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw do
  mount ::DiscourseMarketplaceCredits::Engine, at: "discourse-marketplace-credits"
end
