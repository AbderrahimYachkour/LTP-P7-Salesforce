public with sharing class DeliveryService {

    public class DeliveryException extends Exception {}

    public static LaunchDeliveryController.DeliveryOptions getDeliveryOptionsForOrder(Id orderId) {
        Order ord = OrderSelector.getOrderWithAccount(orderId);

        if (String.isBlank(ord.ShippingCountry)) {
            throw new DeliveryException('Le pays de livraison n\'est pas renseigne sur la commande.');
        }
        if (ord.Account == null || String.isBlank(ord.Account.Type)) {
            throw new DeliveryException('Le type de client n\'est pas renseigne sur le compte.');
        }

        LaunchDeliveryController.DeliveryOptions opt = new LaunchDeliveryController.DeliveryOptions();
        opt.cheapest   = DeliveryFeeSelector.getCheapest(ord.ShippingCountry, ord.Account.Type);
        opt.fastest    = DeliveryFeeSelector.getFastest(ord.ShippingCountry, ord.Account.Type);
        opt.allOptions = DeliveryFeeSelector.getCompatible(ord.ShippingCountry, ord.Account.Type);

        return opt;
    }

    public static Id createDelivery(Id orderId, Id transporterId, Integer deliveryTime) {
        if (!FeatureManagement.checkPermission('CanLaunchDelivery')) {
            throw new DeliveryException('Vous n\'avez pas la permission de lancer une livraison.');
        }

        if (orderId == null || transporterId == null) {
            throw new DeliveryException('Order ou Transporter manquant.');
        }

        Delivery__c delivery = new Delivery__c(
            Order__c         = orderId,
            Transporter__c   = transporterId,
            Status__c        = 'New',
            ScheduledDate__c = Date.today().addDays(deliveryTime != null ? deliveryTime : 0)
        );

        insert delivery;
        return delivery.Id;
    }
}
