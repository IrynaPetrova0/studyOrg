import { LightningElement ,api, wire, track} from 'lwc';
import getRelatedBooks from '@salesforce/apex/ReaderRelatedBooksController.getRelatedBooks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import makeGetCallout from '@salesforce/apex/RefreshReadersData.makeGetCallout';



export default class LightningDatatableLWCExample extends LightningElement {
    @track columns = [{
        label: 'Book',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
        {
            label: 'Author',
            fieldName: 'Author__c',
            type: 'text',
            sortable: true
        }

    ];
    @api recordId;
    @track error;
    @track list;
    @wire(getRelatedBooks, {recordId: '$recordId'})

    wiredContacts({error, data}) {
        if (data) {
            this.list = data;
        } else if (error) {
            this.error = error;
        }
    }


   
    showSuccessToast(event) {

        makeGetCallout({myTest:this.recordId})

        const evt = new ShowToastEvent({
            message: 'Readers info is updated. Please, reload the page.',
            variant: 'success',
            mode: 'dismissible'
        });
        this.dispatchEvent(evt);

    }



}