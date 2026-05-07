public with sharing class AccountSelector {
    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, Name, Type, Industry, BillingCity, BillingCountry, Phone, Website
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }
    public static Map<Id, Account> getAccountsByIds(Set<Id> accountIds) {
    return new Map<Id, Account>([
        SELECT Id, Name, Type, Industry, BillingCity, BillingCountry
        FROM Account
        WHERE Id IN :accountIds
    ]);
}
}