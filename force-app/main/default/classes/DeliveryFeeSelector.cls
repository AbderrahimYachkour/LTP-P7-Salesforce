public with sharing class DeliveryFeeSelector {

    public static List<DeliveryFee__c> getCompatible(String country, String clientType) {
        return queryFees(country, clientType, 'Price__c ASC', null);
    }

    public static DeliveryFee__c getCheapest(String country, String clientType) {
        List<DeliveryFee__c> fees = queryFees(country, clientType, 'Price__c ASC', 1);
        return fees.isEmpty() ? null : fees[0];
    }

    public static DeliveryFee__c getFastest(String country, String clientType) {
        List<DeliveryFee__c> fees = queryFees(country, clientType, 'DeliveryTime__c ASC', 1);
        return fees.isEmpty() ? null : fees[0];
    }

    // SECURITE : orderBy et rowLimit sont des constantes internes (jamais issues d'un input utilisateur)
    // donc pas de risque de SOQL injection. country et clientType sont bindes via :var ce qui les protege.
    // Si un jour orderBy devient parametrable depuis l'exterieur, il faudra le valider via une whitelist.
    private static List<DeliveryFee__c> queryFees(String country, String clientType, String orderBy, Integer rowLimit) {
        String query =
            'SELECT Id, Name, Country__c, Price__c, DeliveryTime__c, ' +
            '       Transporter__c, Transporter__r.Name, Transporter__r.ClientType__c ' +
            'FROM DeliveryFee__c ' +
            'WHERE Country__c = :country ' +
            '  AND (Transporter__r.ClientType__c = :clientType ' +
            '       OR Transporter__r.ClientType__c = \'Both\') ' +
            'ORDER BY ' + orderBy;

        if (rowLimit != null) {
            query += ' LIMIT ' + rowLimit;
        }

        return Database.query(query);
    }
}
