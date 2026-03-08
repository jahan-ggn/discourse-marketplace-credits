import Component from "@glimmer/component";
import { service } from "@ember/service";
import Category from "discourse/models/category";
import { eq } from "discourse/truth-helpers";

export default class MarketplaceCreditsNotice extends Component {
  @service currentUser;
  @service siteSettings;

  get marketplaceCategoryId() {
    return parseInt(this.siteSettings.marketplace_category, 10);
  }

  get isMarketplaceCategory() {
    if (!this.args.outletArgs?.model?.creatingTopic) {
      return false;
    }
    const categoryId = this.args.outletArgs?.model?.categoryId;
    if (!categoryId || !this.marketplaceCategoryId) {
      return false;
    }
    if (categoryId === this.marketplaceCategoryId) {
      return true;
    }

    const category = Category.findById(categoryId);
    return category?.parent_category_id === this.marketplaceCategoryId;
  }

  get credits() {
    return this.currentUser?.marketplace_credits || 0;
  }

  get purchaseUrl() {
    const productId = this.siteSettings.marketplace_stripe_product_id;
    if (!productId) {
      return null;
    }
    return `/s/${productId}`;
  }

  <template>
    {{#if this.isMarketplaceCategory}}
      <div
        class="marketplace-credits-notice
          {{if (eq this.credits 0) 'no-credits'}}"
      >
        {{#if (eq this.credits 0)}}
          You have no marketplace credits remaining.
          {{#if this.purchaseUrl}}
            <a
              href={{this.purchaseUrl}}
              target="_blank"
              rel="noopener noreferrer"
            >{{this.siteSettings.marketplace_purchase_link_text}}</a>
          {{/if}}
        {{else}}
          You have
          {{this.credits}}
          marketplace credit(s) remaining.
        {{/if}}
      </div>
    {{/if}}
  </template>
}
