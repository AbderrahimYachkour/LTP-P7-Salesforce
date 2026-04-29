public with sharing class AccountSelector {
    /**
     * @description Récupère un seul compte à partir de son Id.
     *              Utile quand on veut afficher le détail d'un compte.
     * @param  accountId  L'Id du compte à récupérer
     * @return            L'enregistrement Account, ou null si non trouvé
     */
    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, Name, Type, Industry, BillingCity, BillingCountry, Phone, Website
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }
    /**
     * @description Récupère plusieurs comptes à partir d'un ensemble d'Ids,
     *              de manière bulkifiée (1 seule requête SOQL).
     *              Retourne une Map pour permettre une recherche rapide par Id.
     *              Indispensable dans les triggers pour respecter les limites Salesforce.
     * @param  accountIds  Ensemble d'Ids des comptes à récupérer
     * @return             Map associant chaque Id à son Account
     */
    public static Map<Id, Account> getAccountsByIds(Set<Id> accountIds) {
    return new Map<Id, Account>([
        SELECT Id, Name, Type, Industry, BillingCity, BillingCountry
        FROM Account
        WHERE Id IN :accountIds
    ]);
}
}