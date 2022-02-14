import getRelatedActiveEmployees from '@salesforce/apex/EmployeesComponentController.getRelatedActiveEmployees';
import {api, LightningElement, track, wire} from 'lwc';
import {refreshApex} from "@salesforce/apex";

// const actions = [
//     { label: 'Activate', name: 'activate' },
//     { label: 'Deactivate', name: 'deactivate' },
// ];

export default class SiteTeam extends LightningElement {
    @track columns = [
        {
            label: 'MEMBER NAME',
            fieldName: 'memberName',
            type: 'text',
            sortable: true
        },
        {
            label: 'START DATE',
            fieldName: 'Start_Date__c',
            type: 'date',
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'ACTIVE',
            fieldName: 'Active__c',
            type: 'boolean',
            cellAttributes: { alignment: 'center' }
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions } }
    ];

    @api recordId;
    @track error;
    @track list;
    @api checkedEmployees;
    @api isActive;
    @api rowData;
    @api typeOfMember;
    @track empty;
    wiredEmployees

    @wire(getRelatedActiveEmployees, {
        checkedEmployees: '$checkedEmployees',
        sourceTable: 'Site_Team_Member__c',
        isActive: '$isActive',
        recordId: '$recordId'
    })
    wiredGetRelatedEmployees(result) {
        this.wiredEmployees =result;
        if (result.data) {
            this.list = result.data.map(row=>{
                return{...row, memberName: row.Employee__r.Name}
            })
            this.error = undefined;
            this.empty = this.list.length === 0;
        } else if (result.error) {
            this.error = result.error;
        }
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if (row['Active__c']) {
            actions.push({
                'label': 'Deactivate',
                'iconName': 'utility:block_visitor',
                'name': 'deactivate'
            });
        } else {
            actions.push({
                'label': 'Activate',
                'iconName': 'utility:adduser',
                'name': 'activate'
            });
        }
            doneCallback(actions);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        this.rowData = event.detail.row;
        this.typeOfMember = 'Site_Team_Member';
        const myEvent = new CustomEvent("callmodal",{
            detail: {
                rowData: this.rowData,
                typeOfMember: this.typeOfMember
            }
        });
        this.dispatchEvent(myEvent);
    }

    @api updateDatatable(){
        refreshApex(this.wiredEmployees);
    }
}