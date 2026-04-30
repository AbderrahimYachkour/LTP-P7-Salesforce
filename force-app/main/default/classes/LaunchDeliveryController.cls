public with sharing class LaunchDeliveryController {

    @AuraEnabled(cacheable=true)
    public static DeliveryOptionsWrapper getDeliveryOptions(Id orderId) {
        // Récupérer l'Order avec son Account
        Order order = [
            SELECT Id, ShippingCountry, AccountId, Account.Type
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        // Vérifications
        if (String.isBlank(order.ShippingCountry)) {
            throw new AuraHandledException('Le pays de livraison n\'est pas renseigné sur la commande.');
        }
        if (order.Account == null || String.isBlank(order.Account.Type)) {
            throw new AuraHandledException('Le type de client n\'est pas renseigné sur le compte.');
        }

        String country = order.ShippingCountry;
        String clientType = order.Account.Type;

        // Construire le wrapper avec les 3 informations
        DeliveryOptionsWrapper result = new DeliveryOptionsWrapper();
        result.cheapest = TransporterSelector.getCheapestDeliveryFee(country, clientType);
        result.fastest = TransporterSelector.getFastestDeliveryFee(country, clientType);
        result.allOptions = TransporterSelector.getCompatibleDeliveryFees(country, clientType);

        return result;
    }

    /**
     *  Crée une Delivery liée à l'Order avec le transporteur choisi             
     */
    @AuraEnabled
    public static Id launchDelivery(Id orderId, Id transporterId, Integer deliveryTime) {
        // Vérification de la Custom Permission
        if (!FeatureManagement.checkPermission('CanLaunchDelivery')) {
            throw new AuraHandledException('Vous n\'avez pas la permission de lancer une livraison.');
        }

        // Validation des paramètres
        if (orderId == null || transporterId == null) {
            throw new AuraHandledException('Order ou Transporter manquant.');
        }

        // Création de la Delivery
        Delivery__c delivery = new Delivery__c(
            Order__c = orderId,
            Transporter__c = transporterId,
            Status__c = 'New',
            ScheduledDate__c = Date.today().addDays(deliveryTime != null ? deliveryTime : 0)
        );

        insert delivery;
        return delivery.Id;
    }

    /**
     * Wrapper exposé au LWC pour transporter les 3 listes d'options de livraison.
     */
    public class DeliveryOptionsWrapper {
        @AuraEnabled public DeliveryFee__c cheapest { get; set; }
        @AuraEnabled public DeliveryFee__c fastest { get; set; }
        @AuraEnabled public List<DeliveryFee__c> allOptions { get; set; }
    }
}