@isTest
private class DeliveryFeeSelectorTest {

    @TestSetup
    static void setupTestData() {
        List<Transporter__c> transporters = new List<Transporter__c>{
            new Transporter__c(Name = 'TestIndividualOnly', ClientType__c = 'Individual'),
            new Transporter__c(Name = 'TestProOnly', ClientType__c = 'Professional'),
            new Transporter__c(Name = 'TestBoth', ClientType__c = 'Both')
        };
        insert transporters;

        List<DeliveryFee__c> fees = new List<DeliveryFee__c>{
            new DeliveryFee__c(Transporter__c = transporters[0].Id, Country__c = 'France', Price__c = 15, DeliveryTime__c = 3),
            new DeliveryFee__c(Transporter__c = transporters[0].Id, Country__c = 'Belgium', Price__c = 20, DeliveryTime__c = 4),
            new DeliveryFee__c(Transporter__c = transporters[1].Id, Country__c = 'France', Price__c = 25, DeliveryTime__c = 1),
            new DeliveryFee__c(Transporter__c = transporters[1].Id, Country__c = 'Belgium', Price__c = 30, DeliveryTime__c = 2),
            new DeliveryFee__c(Transporter__c = transporters[2].Id, Country__c = 'France', Price__c = 10, DeliveryTime__c = 5),
            new DeliveryFee__c(Transporter__c = transporters[2].Id, Country__c = 'Belgium', Price__c = 12, DeliveryTime__c = 6)
        };
        insert fees;
    }

    @isTest
    static void testGetCompatible_individualInFrance_returnsCorrectFees() {
        Test.startTest();
        List<DeliveryFee__c> result = DeliveryFeeSelector.getCompatible('France', 'Individual');
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Doit retourner 2 tarifs');
        for (DeliveryFee__c fee : result) {
            System.assertEquals('France', fee.Country__c, 'Tarifs France uniquement');
        }
    }

    @isTest
    static void testGetCheapest_individualInFrance_returnsCheapest() {
        Test.startTest();
        DeliveryFee__c result = DeliveryFeeSelector.getCheapest('France', 'Individual');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Doit retourner un tarif');
        System.assertEquals(10, result.Price__c, 'Le moins cher = 10');
    }

    @isTest
    static void testGetFastest_professionalInFrance_returnsFastest() {
        Test.startTest();
        DeliveryFee__c result = DeliveryFeeSelector.getFastest('France', 'Professional');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Doit retourner un tarif');
        System.assertEquals(1, result.DeliveryTime__c, 'Le plus rapide = 1 jour');
    }

    @isTest
    static void testGetCheapest_noDataForCountry_returnsNull() {
        Test.startTest();
        DeliveryFee__c result = DeliveryFeeSelector.getCheapest('Switzerland', 'Individual');
        Test.stopTest();

        System.assertEquals(null, result, 'Doit retourner null');
    }
}
