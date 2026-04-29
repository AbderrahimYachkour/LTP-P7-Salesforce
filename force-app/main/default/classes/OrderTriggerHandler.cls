/**
 * @description Handler du trigger sur l'objet Order.
 *              Centralise tout le routage des événements (before insert, etc.)
 *              et délègue la logique métier aux Services appropriés.
 * @author      Abderrahim Yachkour
 * @date        29/04/2026
 */
public with sharing class OrderTriggerHandler {

    /**
     * @description Point d'entrée appelé par OrderTrigger.
     *              Détermine le type d'événement et appelle la méthode adéquate.
     */
    public static void run() {
    // Si on est dans un contexte BEFORE INSERT
    if (Trigger.isBefore && Trigger.isInsert) {
        handleBeforeInsert((List<Order>) Trigger.new);
    }

    // Si on est dans un contexte BEFORE UPDATE
    if (Trigger.isBefore && Trigger.isUpdate) {
        handleBeforeUpdate((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }
}

    /**
     * @description Logique avant insertion d'une ou plusieurs Orders.
     * @param  newOrders  Les Orders en cours d'insertion (Trigger.new)
     */
    private static void handleBeforeInsert(List<Order> newOrders) {
        // Pour l'instant, rien à valider à l'insertion
        // (la validation des produits se fait à l'activation, pas à la création)
    }

    /**
     * @description Logique avant mise à jour d'une ou plusieurs Orders.
     *              Valide la règle des produits minimum UNIQUEMENT quand
     *              le Status passe à "Activated".
     * @param  newOrders  Les Orders avec leurs nouvelles valeurs
     * @param  oldOrders  Map des Orders avant modification (Trigger.oldMap)
     */
    private static void handleBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        // Filtrer : on ne veut valider que les Orders qui PASSENT à "Activated"
        List<Order> ordersToValidate = new List<Order>();

        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrders.get(newOrder.Id);

            // L'Order vient de passer en "Activated" (changement de statut)
            Boolean justActivated = newOrder.Status == 'Activated'
                && oldOrder.Status != 'Activated';

            if (justActivated) {
                ordersToValidate.add(newOrder);
            }
        }

        // Si rien à valider, on ne fait rien (pas de SOQL inutile)
        if (ordersToValidate.isEmpty()) {
            return;
        }

        // Délégation au Service métier
        OrderService.validateOrders(ordersToValidate);
    }
}