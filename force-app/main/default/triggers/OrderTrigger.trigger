trigger OrderTrigger on Order (after insert, after update) {
    OrderService.validateOrders(Trigger.new);
}