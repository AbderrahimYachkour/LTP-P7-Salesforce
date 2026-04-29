/**
 * @description Classe de test pour TransporterSelector.
 *              Crée ses propres données (transporteurs et tarifs)
 *              pour rester indépendante de l'état de l'org.
 * @author      Abderrahim Yachkour
 * @date        29/04/2026
 */
@isTest
private class TransporterSelectorTest {

    /**
     * @description Méthode utilitaire qui crée un jeu de données complet :
     *              - 3 transporteurs (Individual, Professional, Both)
     *              - Plusieurs tarifs pour France et Belgium
     *              Appelée par chaque test pour avoir des données fraîches.
     */
    @TestSetup
    static void setupTestData() {
        // Création des 3 transporteurs
        List<Transporter__c> transporters = new List<Transporter__c>{
            new Transporter__c(Name = 'TestIndividualOnly', ClientType__c = 'Individual'),
            new Transporter__c(Name = 'TestProOnly', ClientType__c = 'Professional'),
            new Transporter__c(Name = 'TestBoth', ClientType__c = 'Both')
        };
        insert transporters;

        // Création des tarifs : 2 pays x 3 transporteurs = 6 tarifs
        // Prix et délais variés pour pouvoir tester "le moins cher" et "le plus rapide"
        List<DeliveryFee__c> fees = new List<DeliveryFee__c>{
            // TestIndividualOnly
            new DeliveryFee__c(Transporter__c = transporters[0].Id,
                Country__c = 'France', Price__c = 15, DeliveryTime__c = 3),
            new DeliveryFee__c(Transporter__c = transporters[0].Id,
                Country__c = 'Belgium', Price__c = 20, DeliveryTime__c = 4),
            // TestProOnly
            new DeliveryFee__c(Transporter__c = transporters[1].Id,
                Country__c = 'France', Price__c = 25, DeliveryTime__c = 1),
            new DeliveryFee__c(Transporter__c = transporters[1].Id,
                Country__c = 'Belgium', Price__c = 30, DeliveryTime__c = 2),
            // TestBoth
            new DeliveryFee__c(Transporter__c = transporters[2].Id,
                Country__c = 'France', Price__c = 10, DeliveryTime__c = 5),
            new DeliveryFee__c(Transporter__c = transporters[2].Id,
                Country__c = 'Belgium', Price__c = 12, DeliveryTime__c = 6)
        };
        insert fees;
    }

    /**
     * @description Vérifie que getCompatibleDeliveryFees retourne les tarifs
     *              du bon pays + transporteurs compatibles avec Individual + Both.
     */
    @isTest
    static void testGetCompatibleDeliveryFees_individualInFrance_returnsCorrectFees() {
        // ============ ACT ============
        Test.startTest();
        List<DeliveryFee__c> result = TransporterSelector.getCompatibleDeliveryFees('France', 'Individual');
        Test.stopTest();

        // ============ ASSERT ============
        // Pour la France + Individual, on attend :
        // - TestIndividualOnly (15€) ✅
        // - TestBoth (10€)           ✅
        // - TestProOnly est exclu car Professional uniquement ❌
        System.assertEquals(2, result.size(), 'Doit retourner 2 tarifs (Individual + Both)');

        // Vérifier que tous les pays sont 'France'
        for (DeliveryFee__c fee : result) {
            System.assertEquals('France', fee.Country__c, 'Tous les tarifs doivent être pour la France');
        }
    }

    /**
     * @description Vérifie que getCheapestDeliveryFee retourne bien
     *              le moins cher (TestBoth à 10€ pour France + Individual).
     */
    @isTest
    static void testGetCheapestDeliveryFee_individualInFrance_returnsCheapest() {
        // ============ ACT ============
        Test.startTest();
        DeliveryFee__c result = TransporterSelector.getCheapestDeliveryFee('France', 'Individual');
        Test.stopTest();

        // ============ ASSERT ============
        System.assertNotEquals(null, result, 'Doit retourner un tarif');
        System.assertEquals(10, result.Price__c, 'Le moins cher pour France + Individual doit être 10€ (TestBoth)');
    }

    /**
     * @description Vérifie que getFastestDeliveryFee retourne bien
     *              le plus rapide (TestProOnly = 1 jour pour Pro en France).
     */
    @isTest
    static void testGetFastestDeliveryFee_professionalInFrance_returnsFastest() {
        // ============ ACT ============
        Test.startTest();
        DeliveryFee__c result = TransporterSelector.getFastestDeliveryFee('France', 'Professional');
        Test.stopTest();

        // ============ ASSERT ============
        // Pour France + Professional, on attend :
        // - TestProOnly (1 jour, 25€)   ← le plus rapide ✅
        // - TestBoth (5 jours, 10€)
        // - TestIndividualOnly est exclu
        System.assertNotEquals(null, result, 'Doit retourner un tarif');
        System.assertEquals(1, result.DeliveryTime__c, 'Le plus rapide pour France + Pro doit être 1 jour');
    }

    /**
     * @description Cas limite : pays sans aucun tarif → doit retourner null
     *              (Switzerland n'a aucune donnée dans @TestSetup).
     */
    @isTest
    static void testGetCheapestDeliveryFee_noDataForCountry_returnsNull() {
        // ============ ACT ============
        Test.startTest();
        DeliveryFee__c result = TransporterSelector.getCheapestDeliveryFee('Switzerland', 'Individual');
        Test.stopTest();

        // ============ ASSERT ============
        System.assertEquals(null, result, 'Doit retourner null si aucun tarif disponible');
    }
}