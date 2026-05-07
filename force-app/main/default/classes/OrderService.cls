public with sharing class OrderService {

    private static final Integer MIN_PRODUCTS_INDIVIDUAL = 3;
    private static final Integer MIN_PRODUCTS_PROFESSIONAL = 5;

    public static void validateOrders(List<Order> orders) {
        if (orders == null || orders.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();

        for (Order o : orders) {
            if (o.AccountId != null) {
                accountIds.add(o.AccountId);
            }
            if (o.Id != null) {
                orderIds.add(o.Id);
            }
        }

        Map<Id, Account> accountsById = AccountSelector.getAccountsByIds(accountIds);
        Map<Id, Integer> productCountByOrderId = OrderItemSelector.countByOrderIds(orderIds);

        for (Order o : orders) {
            Account acc = accountsById.get(o.AccountId);

            if (acc == null || String.isBlank(acc.Type)) {
                continue;
            }

            Integer productCount = productCountByOrderId.containsKey(o.Id)
                ? productCountByOrderId.get(o.Id)
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
}