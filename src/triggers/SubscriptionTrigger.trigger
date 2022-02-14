trigger SubscriptionTrigger on Subscription__c (before insert, before update) {

       SubscriptionTriggerHandler.onBeforeInsert(Trigger.new);


}