public with sharing class TransporterSelector {
   
    public static List<DeliveryFee__c> getCompatibleDeliveryFees(String country, String clientType) {
        return [
            SELECT Id, Name, Country__c, Price__c, DeliveryTime__c,
                   Transporter__c, Transporter__r.Name, Transporter__r.ClientType__c
            FROM DeliveryFee__c
            WHERE Country__c = :country
              AND (Transporter__r.ClientType__c = :clientType
                   OR Transporter__r.ClientType__c = 'Both')
            ORDER BY Price__c ASC
        ];
    }

   
    public static DeliveryFee__c getCheapestDeliveryFee(String country, String clientType) {
        List<DeliveryFee__c> fees = [
            SELECT Id, Name, Country__c, Price__c, DeliveryTime__c,
                   Transporter__c, Transporter__r.Name
            FROM DeliveryFee__c
            WHERE Country__c = :country
              AND (Transporter__r.ClientType__c = :clientType
                   OR Transporter__r.ClientType__c = 'Both')
            ORDER BY Price__c ASC
            LIMIT 1
        ];
        return fees.isEmpty() ? null : fees[0];
    }


    public static DeliveryFee__c getFastestDeliveryFee(String country, String clientType) {
        List<DeliveryFee__c> fees = [
            SELECT Id, Name, Country__c, Price__c, DeliveryTime__c,
                   Transporter__c, Transporter__r.Name
            FROM DeliveryFee__c
            WHERE Country__c = :country
              AND (Transporter__r.ClientType__c = :clientType
                   OR Transporter__r.ClientType__c = 'Both')
            ORDER BY DeliveryTime__c ASC
            LIMIT 1
        ];
        return fees.isEmpty() ? null : fees[0];
    }
}