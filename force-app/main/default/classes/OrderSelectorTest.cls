@isTest
private class OrderSelectorTest {

    @isTest
    static void testGetOrderWithAccount_existingOrder_returnsOrderWithAccountFields() {
        Account a = new Account(Name = 'Test', Type = 'Professional');
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
        Order result = OrderSelector.getOrderWithAccount(o.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'L\'Order ne doit pas être null');
        System.assertEquals(o.Id, result.Id, 'L\'Id doit correspondre');
        System.assertEquals('France', result.ShippingCountry, 'ShippingCountry doit être chargé');
        System.assertEquals(a.Id, result.AccountId, 'AccountId doit être chargé');
        System.assertEquals('Professional', result.Account.Type, 'Account.Type doit être chargé via la relation');
    }
}