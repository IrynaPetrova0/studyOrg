/**
 * Created by iryna.petrova on 12/9/2021.
 */

trigger ProjectTrigger on Project__c (before delete, after delete, after undelete) {

    if (Trigger.isDelete) {
        ProjectTriggerHandler.onBeforeDelete(Trigger.old);
    }else if(Trigger.isUndelete){
        ProjectTriggerHandler.onAfterUndelete(Trigger.new);
    }
}