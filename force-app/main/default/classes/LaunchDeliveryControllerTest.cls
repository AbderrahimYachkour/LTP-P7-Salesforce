@isTest
private class LaunchDeliveryControllerTest {

    /**
     * @description Crée un transporteur + un tarif pour la France + Individual.
     */
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

    /**
     * @description Cas nominal : récupère les options pour une Order valide.
     */
    @isTest
    static void testGetDeliveryOptions_validOrder_returnsWrapper() {
        // ARRANGE
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

        // ACT
        Test.startTest();
        LaunchDeliveryController.DeliveryOptionsWrapper result =
            LaunchDeliveryController.getDeliveryOptions(o.Id);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, result, 'Le wrapper ne doit pas être null');
        System.assertNotEquals(null, result.cheapest, 'cheapest doit être renseigné');
        System.assertNotEquals(null, result.fastest, 'fastest doit être renseigné');
        System.assert(!result.allOptions.isEmpty(), 'allOptions doit contenir au moins 1 tarif');
    }

    /**
     * @description Cas d'erreur : Order sans pays de livraison → exception.
     */
    @isTest
    static void testGetDeliveryOptions_noShippingCountry_throwsException() {
        // ARRANGE
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        // ACT + ASSERT
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            LaunchDeliveryController.getDeliveryOptions(o.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Une exception doit être levée si pas de ShippingCountry');
    }

    /**
     * @description Cas nominal : crée bien une Delivery liée à l'Order.
     */
    @isTest
    static void testLaunchDelivery_validInputs_createsDelivery() {
        // ARRANGE
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

        // ACT
        Test.startTest();
        Id deliveryId = LaunchDeliveryController.launchDelivery(o.Id, t.Id, 2);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, deliveryId, 'L\'Id de la Delivery doit être retourné');

        Delivery__c created = [SELECT Id, Order__c, Transporter__c, Status__c
                                FROM Delivery__c WHERE Id = :deliveryId];
        System.assertEquals(o.Id, created.Order__c, 'La Delivery doit être liée à l\'Order');
        System.assertEquals(t.Id, created.Transporter__c, 'La Delivery doit pointer vers le Transporter');
        System.assertEquals('New', created.Status__c, 'Status par défaut = New');
    }

    /**
     * @description Cas d'erreur : params null → exception levée proprement.
     */
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

        System.assert(exceptionThrown, 'Doit lever une exception si paramètres null');
    }
}