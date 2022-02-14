import {LightningElement, api, wire, track} from 'lwc';
import getRelatedEmployees from '@salesforce/apex/EmployeesComponentController.getRelatedEmployees';

export default class Employees extends LightningElement {

    @track columns = [{
        label: 'EMPLOYEE NAME',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    }
    ];

    @api recordId;
    @track error;
    @track list;
    @api checkedEmployees;
    @api isActive = null;
    @wire(getRelatedEmployees, {recordId: '$recordId'})
    wiredEmployees({error, data}) {
        if (data) {
            this.list = data;
        } else if (error) {
            this.error = error;
        }
    }

    showAllEmployees(event){
        this.checkedEmployees = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.isActive = false;
        const myEvent = new CustomEvent("selection",{
            detail: {
                checkedEmployees: [...this.checkedEmployees],
                isActive: this.isActive
            }
        });
        this.dispatchEvent(myEvent);
    }

    showActiveEmployees(event){
        this.checkedEmployees = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.isActive = true;
        const myEvent = new CustomEvent("selection",{
            detail: {
                checkedEmployees: [...this.checkedEmployees],
                isActive: this.isActive
            }
        });
        this.dispatchEvent(myEvent);
    }


}