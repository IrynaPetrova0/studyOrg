import {LightningElement, api, track} from 'lwc';
import changeActiveStatus from '@salesforce/apex/EmployeesComponentController.changeActiveStatus';
import {ShowToastEvent} from "lightning/platformShowToastEvent";


export default class Teams extends LightningElement {
    @api recordId
    @api checkedEmployees
    @api isActive
    @api rowData
    @api rowDataId
    @api rowDataActive
    @api typeOfMember
    @track activateModal = false;
    @track textModal
    @track headerModal

    showAllEmployees(event){
        this.checkedEmployees = event.detail.checkedEmployees;
        this.isActive = event.detail.isActive
        console.log(this.checkedEmployees);
        console.log(this.isActive);
    }

    getDataActivate(event){
        this.rowData = event.detail.rowData;
        this.rowDataId = event.detail.rowData['Id'];
        this.rowDataActive = event.detail.rowData['Active__c'];
        console.log(this.rowDataActive);
        this.typeOfMember = event.detail.typeOfMember;
        this.activateModal = true;
        this.textModal = `Are you sure you want to ${this.rowDataActive?'deactivate':'activate'} 
            ${this.rowData['memberName']} ?`;
        this.headerModal = `Team member ${this.rowDataActive?'deactivation':'activation'} `

    }

    cancelModal(event){
        this.activateModal = false;
    }

    confirmModal(event){
        this.activateModal = false;
console.log('next --> changeActiveStatus');
        changeActiveStatus({
            recordId: this.rowDataId,
            isActive: this.rowDataActive
        })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Team member successfully updated',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                if (this.typeOfMember === 'Country_Team_Member'){
                    this.template.querySelector("c-country-team").updateDatatable();
                }else if(this.typeOfMember === 'Study_Team_Member'){
                    this.template.querySelector("c-study-team").updateDatatable();
                }else{
                    this.template.querySelector("c-site-team").updateDatatable();
                }

            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title : 'Ooops...',
                    message: error.body.message,
                    variant : 'error'
                });
                this.dispatchEvent(event);
            });
    }

}