/**
 * Created by iryna.petrova on 12/7/2021.
 */

trigger TaskTrigger on Task__c (after insert,before update, after update, before delete, after undelete) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            TaskTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.old);
        }else if(Trigger.isDelete){
            TaskTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            TaskTriggerHandler.onAfterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            TaskTriggerHandler.onAfterUpdate(Trigger.new, Trigger.old);
        }else if(Trigger.isUndelete){
            TaskTriggerHandler.onAfterUndelete(Trigger.new);
        }
    }



}