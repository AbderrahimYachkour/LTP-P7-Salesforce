@isTest
private class OrderItemSelectorTest {

    private static List<PricebookEntry> createProductsAndEntries(Integer count) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < count; i++) {
            products.add(new Product2(Name = 'P' + i, IsActive = true, ProductCode = 'PC-' + i));
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

    @isTest
    static void testCountByOrderIds_orderWith3Items_returnsCount3() {
        Account a = new Account(Name = 'Test', Type = 'Individual');
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        List<PricebookEntry> entries = createProductsAndEntries(3);
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

        Test.startTest();
        Map<Id, Integer> result = OrderItemSelector.countByOrderIds(new Set<Id>{ o.Id });
        Test.stopTest();

        System.assertEquals(3, result.get(o.Id), 'Doit compter 3 OrderItems');
    }

    @isTest
    static void testCountByOrderIds_emptySet_returnsEmptyMap() {
        Test.startTest();
        Map<Id, Integer> result = OrderItemSelector.countByOrderIds(new Set<Id>());
        Test.stopTest();

        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(0, result.size(), 'La Map doit être vide');
    }

    @isTest
    static void testCountByOrderIds_nullSet_returnsEmptyMap() {
        Test.startTest();
        Map<Id, Integer> result = OrderItemSelector.countByOrderIds(null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(0, result.size(), 'La Map doit être vide');
    }
}