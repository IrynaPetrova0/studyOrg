/**
 * Created by iryna.petrova on 12/21/2021.
 */

trigger ProjectAssignmentTrigger on Project_Assignment__c (before insert ,after insert) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('Trigger activated');
            ProjectAssignmentHandler.onBeforeInsert(Trigger.new);
        }
    }else if (Trigger.isAfter) {
        if(Trigger.isInsert){
            ProjectAssignmentHandler.onAfterInsert(Trigger.new);
        }
    }
}