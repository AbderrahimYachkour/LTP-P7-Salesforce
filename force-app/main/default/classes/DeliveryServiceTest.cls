@isTest
private class DeliveryServiceTest {

    @TestSetup
    static void setupData() {
        Transporter__c t = new Transporter__c(Name = 'TestCarrier', ClientType__c = 'Both');
        insert t;

        DeliveryFee__c fee = new DeliveryFee__c(
            Transporter__c = t.Id,
            Country__c = 'France',
            Price__c = 15,
            DeliveryTime__c = 2
        );
        insert fee;
    }

    private static Order createValidOrder() {
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
        return o;
    }

    @isTest
    static void testGetDeliveryOptionsForOrder_validOrder_returnsOptions() {
        Order o = createValidOrder();

        Test.startTest();
        LaunchDeliveryController.DeliveryOptions result = DeliveryService.getDeliveryOptionsForOrder(o.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Doit retourner les options');
        System.assertNotEquals(null, result.cheapest, 'cheapest doit etre renseigne');
        System.assertNotEquals(null, result.fastest, 'fastest doit etre renseigne');
        System.assert(!result.allOptions.isEmpty(), 'allOptions doit contenir au moins 1 tarif');
    }

    @isTest
    static void testGetDeliveryOptionsForOrder_missingShippingCountry_throwsDeliveryException() {
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        Boolean thrown = false;
        Test.startTest();
        try {
            DeliveryService.getDeliveryOptionsForOrder(o.Id);
        } catch (DeliveryService.DeliveryException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Doit lever une DeliveryException si ShippingCountry manquant');
    }

    @isTest
    static void testGetDeliveryOptionsForOrder_missingAccountType_throwsDeliveryException() {
        Account a = new Account(Name = 'Test');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShippingCountry = 'France',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        Boolean thrown = false;
        Test.startTest();
        try {
            DeliveryService.getDeliveryOptionsForOrder(o.Id);
        } catch (DeliveryService.DeliveryException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Doit lever une DeliveryException si Type manquant');
    }

    @isTest
    static void testCreateDelivery_nullInputs_throwsException() {
        Boolean thrown = false;
        Test.startTest();
        try {
            DeliveryService.createDelivery(null, null, 1);
        } catch (Exception e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Doit lever une exception si parametres null');
    }
}
