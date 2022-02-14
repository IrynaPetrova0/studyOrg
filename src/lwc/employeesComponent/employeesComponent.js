import {LightningElement, api, wire, track} from 'lwc';
import getRelatedEmployees from '@salesforce/apex/EmployeesComponentController.getRelatedEmployees';
import getRelatedActiveEmployees from '@salesforce/apex/EmployeesComponentController.getRelatedActiveEmployees';
import {refreshApex} from '@salesforce/apex';


export default class DatatableWithRow extends LightningElement {

    @track columns = [{
        label: 'EMPLOYEE NAME',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    }
    ];

    @track studyColumns = [{
        label: 'MEMBER NAME',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
        {
            label: 'START DATE',
            fieldName: 'StartDate__c',
            type:'date',
            sortable: true
        }];

    @api recordId;
    @track error;
    @track list;
    @wire(getRelatedEmployees, {recordId: '$recordId'})

    wiredEmployees({error, data}) {
        if (data) {
            this.list = data;
        } else if (error) {
            this.error = error;
        }
    }

    showActiveEmployees(event){
       getRelatedActiveEmployees({recordId: this.recordId})
            .then(result =>{
                this.list = result;
                return refreshApex(this.list);
            })
            .catch(error =>{
                this.error = error;
            })

    }

    showAllEmployees(event){
        getRelatedEmployees({recordId: this.recordId})
            .then(result =>{
                this.list = result;
                return refreshApex(result);
            })
            .catch(error =>{
                this.error = error;
            })

    }


}