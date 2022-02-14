import {LightningElement, api, wire, track} from 'lwc';
import getRelatedActiveEmployees from '@salesforce/apex/EmployeesComponentController.getRelatedActiveEmployees';
import {refreshApex} from "@salesforce/apex";

// const actions = [
//     { label: 'Activate', name: 'activate' },
//     { label: 'Deactivate', name: 'deactivate' },
// ];

export default class StudyTeam extends LightningElement {
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
        { type: 'action', typeAttributes: { rowActions: this.getRowActions } }
    ];

    @api recordId;
    @track error;
    @track data;
    @api checkedEmployees;
    @api isActive;
    @api rowData;
    @api typeOfMember;
    @track empty;
    wiredEmployees

    @wire(getRelatedActiveEmployees, {
        checkedEmployees: '$checkedEmployees',
        sourceTable: 'Study_Team_Member__c',
        isActive: '$isActive',
        recordId: '$recordId'
    })
    wiredGetRelatedEmployees(result) {
        this.wiredEmployees = result;
        if (result.data) {
            this.data = result.data.map(row=>{
                return{...row, memberName: row.Employee__r.Name}
            })
            this.empty = this.data.length === 0;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
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
        // simulate a trip to the server
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        this.rowData = event.detail.row;
        this.typeOfMember = 'Study_Team_Member';
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