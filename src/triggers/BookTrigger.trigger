trigger BookTrigger on Book__c (before delete) {

   BookTriggerHandler.onBeforeDelete(Trigger.old);
    

}