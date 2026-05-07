public with sharing class OrderSelector {

    public static Order getOrderWithAccount(Id orderId) {
        return [
            SELECT Id, ShippingCountry, AccountId, Account.Type
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];
    }
}