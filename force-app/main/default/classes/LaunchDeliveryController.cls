public with sharing class LaunchDeliveryController {

    public class DeliveryOptions {
        @AuraEnabled public DeliveryFee__c cheapest { get; set; }
        @AuraEnabled public DeliveryFee__c fastest { get; set; }
        @AuraEnabled public List<DeliveryFee__c> allOptions { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static DeliveryOptions getDeliveryOptions(Id orderId) {
        try {
            return DeliveryService.getDeliveryOptionsForOrder(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id launchDelivery(Id orderId, Id transporterId, Integer deliveryTime) {
        try {
            return DeliveryService.createDelivery(orderId, transporterId, deliveryTime);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
