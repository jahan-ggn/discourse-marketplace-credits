# Discourse Marketplace Credits Plugin

**Plugin Summary**

A Discourse plugin that controls topic creation in a Marketplace category using a credit-based system.

## How It Works

1. A user purchases a Marketplace listing via the Discourse Subscriptions plugin (Stripe)
2. The plugin automatically grants marketplace credits to the user
3. Each new topic in the Marketplace category consumes one credit
4. Users with zero credits are blocked from creating new topics and shown a purchase link
5. Users can always edit their existing Marketplace topics
6. Marketplace topics are automatically deleted after a configurable number of days (default: 60)
7. Moving existing topics into the Marketplace category is blocked
8. Staff members bypass all credit checks