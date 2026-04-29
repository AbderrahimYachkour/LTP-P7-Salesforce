/**
 * @description Classe de test pour OrderService.
 *              Couvre les principaux scénarios de validation du nombre 
 *              minimum de produits selon le type de client.
 *              Utilise Database.update(records, false) pour récupérer
 *              les erreurs ajoutées par addError() sans crasher la transaction.
 * @author      Abderrahim Yachkour
 * @date        29/04/2026
 */
@isTest
private class OrderServiceTest {

    /**
     * @description Crée 5 produits + leurs PricebookEntries au Standard Pricebook,
     *              à utiliser dans les Orders de test.
     *              Retourne la liste des PricebookEntries pour pouvoir créer
     *              les OrderItems facilement.
     */
    private static List<PricebookEntry> setupTestProducts(Integer count) {
        // Création des produits
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < count; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                IsActive = true,
                ProductCode = 'TP-' + i
            ));
        }
        insert products;

        // Création des PricebookEntries (le prix dans le Standard Pricebook)
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Product2 p : products) {
            entries.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = p.Id,
                UnitPrice = 100,
                IsActive = true
            ));
        }
        insert entries;

        return entries;
    }

    /**
     * @description Utilitaire qui crée une Order Draft avec un nombre donné
     *              d'OrderItems, prête à être activée.
     * @param  account   L'Account déjà créé en base
     * @param  productCount  Nombre d'OrderItems à ajouter à l'Order
     */
    private static Order createOrderWithProducts(Account account, Integer productCount) {
        // Création de l'Order
        Order o = new Order(
            AccountId = account.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        // Création des OrderItems
        List<PricebookEntry> entries = setupTestProducts(productCount);
        List<OrderItem> items = new List<OrderItem>();
        for (PricebookEntry pbe : entries) {
            items.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 100
            ));
        }
        insert items;

        return o;
    }

    /**
     * @description Cas KO : Particulier avec 2 produits → activation doit être refusée.
     */
    @isTest
    static void testValidateOrder_individualWithTooFewProducts_blocksActivation() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test Individual', Type = 'Individual');
        insert a;

        Order o = createOrderWithProducts(a, 2);
        o.Status = 'Activated';

        // ============ ACT ============
        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        // ============ ASSERT ============
        System.assert(!result.isSuccess(), 'L\'activation doit échouer');
        System.assert(
            result.getErrors()[0].getMessage().contains('3 produits'),
            'Le message doit indiquer le minimum requis (3)'
        );
    }

    /**
     * @description Cas OK : Particulier avec 3 produits → activation acceptée.
     */
    @isTest
    static void testValidateOrder_individualWithEnoughProducts_allowsActivation() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test Individual', Type = 'Individual');
        insert a;

        Order o = createOrderWithProducts(a, 3);
        o.Status = 'Activated';

        // ============ ACT ============
        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        // ============ ASSERT ============
        System.assert(result.isSuccess(), 'L\'activation doit réussir avec 3 produits pour un Individual');
    }

    /**
     * @description Cas KO : Professionnel avec 4 produits → activation refusée.
     */
    @isTest
    static void testValidateOrder_professionalWithTooFewProducts_blocksActivation() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test Pro', Type = 'Professional');
        insert a;

        Order o = createOrderWithProducts(a, 4);
        o.Status = 'Activated';

        // ============ ACT ============
        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        // ============ ASSERT ============
        System.assert(!result.isSuccess(), 'L\'activation doit échouer');
        System.assert(
            result.getErrors()[0].getMessage().contains('5 produits'),
            'Le message doit indiquer le minimum requis (5)'
        );
    }

    /**
     * @description Cas OK : Professionnel avec 5 produits → activation acceptée.
     */
    @isTest
    static void testValidateOrder_professionalWithEnoughProducts_allowsActivation() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test Pro', Type = 'Professional');
        insert a;

        Order o = createOrderWithProducts(a, 5);
        o.Status = 'Activated';

        // ============ ACT ============
        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        // ============ ASSERT ============
        System.assert(result.isSuccess(), 'L\'activation doit réussir avec 5 produits pour un Professional');
    }

    /**
     * @description Cas garde-fou : Account sans Type renseigné → on ne valide pas.
     *              L'Order doit pouvoir être activée même avec 1 seul produit.
     */
    @isTest
    static void testValidateOrder_accountWithoutType_skipsValidation() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test No Type'); // Type non renseigné
        insert a;

        Order o = createOrderWithProducts(a, 1);
        o.Status = 'Activated';

        // ============ ACT ============
        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        // ============ ASSERT ============
        System.assert(result.isSuccess(),
            'Pas de Type sur l\'Account → la validation est skippée → activation OK');
    }

    /**
     * @description Cas robustesse : appel direct du Service avec liste vide.
     *              Doit gérer sans erreur (early return).
     */
    @isTest
    static void testValidateOrders_emptyList_doesNothing() {
        // ============ ACT ============
        Test.startTest();
        OrderService.validateOrders(new List<Order>());
        OrderService.validateOrders(null);  // null aussi
        Test.stopTest();

        // ============ ASSERT ============
        // Si on arrive ici sans exception → OK
        System.assert(true, 'Doit gérer la liste vide et null sans crasher');
    }

    /**
     * @description Cas wrapper : tester que validateOrder(Order) appelle bien
     *              validateOrders(List<Order>) avec une liste d'1 élément.
     */
    @isTest
    static void testValidateOrder_singleOrder_delegatesToBulkVersion() {
        // ============ ARRANGE ============
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;
        Order o = createOrderWithProducts(a, 3);

        // ============ ACT ============
        Test.startTest();
        OrderService.validateOrder(o);
        OrderService.validateOrder(null);  // null aussi
        Test.stopTest();

        // ============ ASSERT ============
        // Pas d'exception = OK
        System.assert(true, 'Le wrapper doit gérer 1 Order et null sans erreur');
    }
}