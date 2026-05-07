@isTest
private class LaunchDeliveryControllerTest {

    @TestSetup
    static void setupData() {
        Transporter__c t = new Transporter__c(
            Name = 'TestCarrier',
            ClientType__c = 'Both'
        );
        insert t;

        DeliveryFee__c fee = new DeliveryFee__c(
            Transporter__c = t.Id,
            Country__c = 'France',
            Price__c = 15,
            DeliveryTime__c = 2
        );
        insert fee;
    }

    @isTest
    static void testGetDeliveryOptions_validOrder_returnsWrapper() {
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShippingCountry = 'France',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        Test.startTest();
        LaunchDeliveryController.DeliveryOptions result = LaunchDeliveryController.getDeliveryOptions(o.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Le wrapper ne doit pas etre null');
        System.assertNotEquals(null, result.cheapest, 'cheapest doit etre renseigne');
        System.assertNotEquals(null, result.fastest, 'fastest doit etre renseigne');
        System.assert(!result.allOptions.isEmpty(), 'allOptions doit contenir au moins 1 tarif');
    }

    @isTest
    static void testGetDeliveryOptions_noShippingCountry_throwsException() {
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            LaunchDeliveryController.getDeliveryOptions(o.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Une exception doit etre levee si pas de ShippingCountry');
    }

    @isTest
    static void testLaunchDelivery_validInputs_createsDelivery() {
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShippingCountry = 'France',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        Transporter__c t = [SELECT Id FROM Transporter__c WHERE Name = 'TestCarrier' LIMIT 1];

        Test.startTest();
        Id deliveryId = LaunchDeliveryController.launchDelivery(o.Id, t.Id, 2);
        Test.stopTest();

        System.assertNotEquals(null, deliveryId, 'L\'Id de la Delivery doit etre retourne');

        Delivery__c created = [SELECT Id, Order__c, Transporter__c, Status__c FROM Delivery__c WHERE Id = :deliveryId];
        System.assertEquals(o.Id, created.Order__c, 'La Delivery doit etre liee a l\'Order');
        System.assertEquals(t.Id, created.Transporter__c, 'La Delivery doit pointer vers le Transporter');
        System.assertEquals('New', created.Status__c, 'Status par defaut = New');
    }

    @isTest
    static void testLaunchDelivery_nullInputs_throwsException() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            LaunchDeliveryController.launchDelivery(null, null, 1);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Doit lever une exception si parametres null');
    }
}
