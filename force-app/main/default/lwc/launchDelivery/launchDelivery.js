import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDeliveryOptions from '@salesforce/apex/LaunchDeliveryController.getDeliveryOptions';
import launchDelivery from '@salesforce/apex/LaunchDeliveryController.launchDelivery';

export default class LaunchDeliveryComponent extends LightningElement {
    @api recordId;  // Id de l'Order (injecté automatiquement par la page)

    cheapest;
    fastest;
    allOptions = [];
    selectedFeeId;
    isLoading = true;
    errorMessage;

    /**
     * Récupère les options de livraison via le controller Apex.
     */
    @wire(getDeliveryOptions, { orderId: '$recordId' })
    wiredOptions({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.cheapest = data.cheapest;
            this.fastest = data.fastest;
            this.allOptions = data.allOptions || [];
            this.errorMessage = undefined;
        } else if (error) {
            this.errorMessage = error.body?.message || 'Erreur lors du chargement des options.';
        }
    }

    /**
     * Liste mise en forme pour le combobox.
     */
    get comboboxOptions() {
        return this.allOptions.map(fee => ({
            label: `${fee.Transporter__r.Name} — ${fee.DeliveryTime__c}j — ${fee.Price__c}€`,
            value: fee.Id
        }));
    }

    /**
     * Vrai si on a au moins le tarif le moins cher (= des options dispo).
     */
    get hasOptions() {
        return !this.isLoading && !this.errorMessage && this.cheapest;
    }

    /**
     * Le bouton "Lancer la livraison" est actif uniquement si une option est choisie.
     */
    get isLaunchDisabled() {
        return !this.selectedFeeId;
    }

    selectCheapest() {
        this.selectedFeeId = this.cheapest.Id;
        this.showToast('Sélection', 'Option la moins chère choisie.', 'success');
    }

    selectFastest() {
        this.selectedFeeId = this.fastest.Id;
        this.showToast('Sélection', 'Option la plus rapide choisie.', 'success');
    }

    handleTransporterChange(event) {
        this.selectedFeeId = event.detail.value;
    }

    /**
     * Lance la création de la Delivery via Apex.
     */
    handleLaunchDelivery() {
        const selectedFee = this.allOptions.find(fee => fee.Id === this.selectedFeeId);

        if (!selectedFee) {
            this.showToast('Erreur', 'Aucun transporteur sélectionné.', 'error');
            return;
        }

        launchDelivery({
            orderId: this.recordId,
            transporterId: selectedFee.Transporter__c,
            deliveryTime: selectedFee.DeliveryTime__c
        })
            .then(deliveryId => {
                this.showToast(
                    'Livraison créée 🎉',
                    `Delivery ID : ${deliveryId}`,
                    'success'
                );
                this.selectedFeeId = undefined;
            })
            .catch(error => {
                this.showToast(
                    'Erreur',
                    error.body?.message || 'Impossible de lancer la livraison.',
                    'error'
                );
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}