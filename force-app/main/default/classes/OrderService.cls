public with sharing class OrderService {

    private static final Integer MIN_PRODUCTS_INDIVIDUAL = 3;
    private static final Integer MIN_PRODUCTS_PROFESSIONAL = 5;

    public static void validateOrder(Order orderToValidate) {
        if (orderToValidate == null) return;
        validateOrders(new List<Order>{ orderToValidate });
    }

    public static void validateOrders(List<Order> orders) {

        if (orders == null || orders.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();

        for (Order o : orders) {
            if (o.AccountId != null) {
                accountIds.add(o.AccountId);
            }
            // ⚠️ Important : seulement si Id existe (update / after insert)
            if (o.Id != null) {
                orderIds.add(o.Id);
            }
        }

        Map<Id, Account> accountsById = AccountSelector.getAccountsByIds(accountIds);

        // ⚠️ Si pas d’Id (before insert), on skip la validation
        Map<Id, Integer> orderItemCountByOrderId = orderIds.isEmpty()
            ? new Map<Id, Integer>()
            : countOrderItems(orderIds);

        for (Order o : orders) {

            Account acc = accountsById.get(o.AccountId);

            if (acc == null || String.isBlank(acc.Type)) {
                continue;
            }

            Integer productCount = orderItemCountByOrderId.containsKey(o.Id)
                ? orderItemCountByOrderId.get(o.Id)
                : 0;

            Integer requiredMinimum = (acc.Type == 'Professional')
                ? MIN_PRODUCTS_PROFESSIONAL
                : MIN_PRODUCTS_INDIVIDUAL;

            if (productCount < requiredMinimum) {
                o.addError(
                    'Minimum requis : ' + requiredMinimum +
                    ' produits pour un client ' + acc.Type +
                    ' (actuellement ' + productCount + ')'
                );
            }
        }
    }

    private static Map<Id, Integer> countOrderItems(Set<Id> orderIds) {

        Map<Id, Integer> result = new Map<Id, Integer>();

        if (orderIds == null || orderIds.isEmpty()) return result;

        for (AggregateResult ar : [
            SELECT OrderId, COUNT(Id) total
            FROM OrderItem
            WHERE OrderId IN :orderIds
            GROUP BY OrderId
        ]) {
            Id orderId = (Id) ar.get('OrderId');

            // ✅ Cast sécurisé
            Integer countValue = Integer.valueOf(String.valueOf(ar.get('total')));

            result.put(orderId, countValue);
        }

        return result;
    }
}