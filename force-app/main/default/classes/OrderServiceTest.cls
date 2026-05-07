@isTest
private class OrderServiceTest {

    private static List<PricebookEntry> setupTestProducts(Integer count) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < count; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                IsActive = true,
                ProductCode = 'TP-' + i
            ));
        }
        insert products;

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

    private static Order createOrderWithProducts(Account account, Integer productCount) {
        Order o = new Order(
            AccountId = account.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

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

    @isTest
    static void testValidateOrder_individualWithTooFewProducts_blocksActivation() {
        Account a = new Account(Name = 'Test Individual', Type = 'Individual');
        insert a;

        Order o = createOrderWithProducts(a, 2);
        o.Status = 'Activated';

        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'L\'activation doit échouer');
        System.assert(
            result.getErrors()[0].getMessage().contains('3 produits'),
            'Le message doit indiquer le minimum requis (3)'
        );
    }

    @isTest
    static void testValidateOrder_individualWithEnoughProducts_allowsActivation() {
        Account a = new Account(Name = 'Test Individual', Type = 'Individual');
        insert a;

        Order o = createOrderWithProducts(a, 3);
        o.Status = 'Activated';

        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        System.assert(result.isSuccess(), 'L\'activation doit réussir avec 3 produits pour un Individual');
    }

    @isTest
    static void testValidateOrder_professionalWithTooFewProducts_blocksActivation() {
        Account a = new Account(Name = 'Test Pro', Type = 'Professional');
        insert a;

        Order o = createOrderWithProducts(a, 4);
        o.Status = 'Activated';

        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'L\'activation doit échouer');
        System.assert(
            result.getErrors()[0].getMessage().contains('5 produits'),
            'Le message doit indiquer le minimum requis (5)'
        );
    }

    @isTest
    static void testValidateOrder_professionalWithEnoughProducts_allowsActivation() {
        Account a = new Account(Name = 'Test Pro', Type = 'Professional');
        insert a;

        Order o = createOrderWithProducts(a, 5);
        o.Status = 'Activated';

        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        System.assert(result.isSuccess(), 'L\'activation doit réussir avec 5 produits pour un Professional');
    }

    @isTest
    static void testValidateOrder_accountWithoutType_skipsValidation() {
        Account a = new Account(Name = 'Test No Type');
        insert a;

        Order o = createOrderWithProducts(a, 1);
        o.Status = 'Activated';

        Test.startTest();
        Database.SaveResult result = Database.update(o, false);
        Test.stopTest();

        System.assert(result.isSuccess(),
            'Pas de Type sur l\'Account → la validation est skippée → activation OK');
    }

    @isTest
    static void testValidateOrders_emptyList_doesNothing() {
        Test.startTest();
        OrderService.validateOrders(new List<Order>());
        OrderService.validateOrders(null);
        Test.stopTest();

        System.assert(true, 'Doit gérer la liste vide et null sans crasher');
    }
}