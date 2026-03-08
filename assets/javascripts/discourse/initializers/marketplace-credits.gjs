import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  if (!currentUser) {
    return;
  }

  const messageBus = api.container.lookup("service:message-bus");

  messageBus.subscribe("/marketplace-credits", (data) => {
    currentUser.set("marketplace_credits", data.credits);
  });
});
