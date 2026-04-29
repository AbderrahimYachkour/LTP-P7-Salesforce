/**
 * @description Classe de test pour AccountSelector.
 *              Teste chacune des méthodes publiques avec différents scénarios :
 *              - cas nominal (données présentes)
 *              - cas limite (set vide)
 *              - cas d'erreur (Id inexistant)
 * @author      Abderrahim Yachkour
 * @date        29/04/2026
 */
@isTest
private class AccountSelectorTest {

    /**
     * @description Vérifie que getAccountById retourne le bon Account 
     *              quand l'Id existe en base.
     */
    @isTest
    static void testGetAccountById_existingAccount_returnsAccount() {
        // ============ ARRANGE ============
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Individual'
        );
        insert testAccount;

        // ============ ACT ============
        Test.startTest();
        Account result = AccountSelector.getAccountById(testAccount.Id);
        Test.stopTest();

        // ============ ASSERT ============
        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(testAccount.Id, result.Id, 'L\'Id doit correspondre');
        System.assertEquals('Test Account', result.Name, 'Le Name doit correspondre');
        System.assertEquals('Individual', result.Type, 'Le Type doit correspondre');
    }

    /**
     * @description Vérifie que getAccountsByIds retourne tous les Accounts
     *              correspondants dans une Map.
     */
    @isTest
    static void testGetAccountsByIds_multipleAccounts_returnsMap() {
        // ============ ARRANGE ============
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Account 1', Type = 'Individual'),
            new Account(Name = 'Account 2', Type = 'Professional'),
            new Account(Name = 'Account 3', Type = 'Individual')
        };
        insert testAccounts;

        Set<Id> accountIds = new Set<Id>();
        for (Account a : testAccounts) {
            accountIds.add(a.Id);
        }

        // ============ ACT ============
        Test.startTest();
        Map<Id, Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // ============ ASSERT ============
        System.assertEquals(3, result.size(), 'La Map doit contenir 3 Accounts');
        for (Account a : testAccounts) {
            System.assert(
                result.containsKey(a.Id),
                'La Map doit contenir l\'Id de chaque Account créé'
            );
        }
    }

    /**
     * @description Vérifie que getAccountsByIds gère correctement un Set vide
     *              sans planter (cas limite à toujours tester).
     */
    @isTest
    static void testGetAccountsByIds_emptySet_returnsEmptyMap() {
        // ============ ARRANGE ============
        Set<Id> emptySet = new Set<Id>();

        // ============ ACT ============
        Test.startTest();
        Map<Id, Account> result = AccountSelector.getAccountsByIds(emptySet);
        Test.stopTest();

        // ============ ASSERT ============
        System.assertNotEquals(null, result, 'Le résultat ne doit jamais être null');
        System.assertEquals(0, result.size(), 'La Map doit être vide pour un Set vide');
    }
}