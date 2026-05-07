public with sharing class OrderTriggerHandler {

    public static void run() {
        if (Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
        }
    }

    private static void handleBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        List<Order> ordersToValidate = new List<Order>();

        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrders.get(newOrder.Id);

            Boolean justActivated = newOrder.Status == 'Activated'
                && oldOrder.Status != 'Activated';

            if (justActivated) {
                ordersToValidate.add(newOrder);
            }
        }

        if (ordersToValidate.isEmpty()) {
            return;
        }

        OrderService.validateOrders(ordersToValidate);
    }
}