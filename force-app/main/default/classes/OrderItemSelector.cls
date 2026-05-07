public with sharing class OrderItemSelector {

    public static Map<Id, Integer> countByOrderIds(Set<Id> orderIds) {
        Map<Id, Integer> result = new Map<Id, Integer>();

        if (orderIds == null || orderIds.isEmpty()) {
            return result;
        }

        for (AggregateResult ar : [
            SELECT OrderId, COUNT(Id) total
            FROM OrderItem
            WHERE OrderId IN :orderIds
            GROUP BY OrderId
        ]) {
            result.put(
                (Id) ar.get('OrderId'),
                Integer.valueOf(String.valueOf(ar.get('total')))
            );
        }

        return result;
    }
}