public with sharing class SubscriptionTriggerHandler {

    public static void onBeforeInsert(List<Subscription__c> newSubscriptions){
        Set<Id> booksIds = new Set<Id>();
        Set<Id> readersIds = new Set<Id>();

        for(Subscription__c subscription: newSubscriptions){
            booksIds.add(subscription.Book__c);
            readersIds.add(subscription.Reader__c);
        }

        List<Subscription__c> oldSubscriptions = new List<Subscription__c>([
            SELECT Id, Reader__c, Book__c
            FROM Subscription__c
            WHERE Reader__c IN : readersIds AND Book__c IN : booksIds
        ]);


       for(Subscription__c newSubscription: newSubscriptions){
           for (Subscription__c oldSubscription: oldSubscriptions){
               if (newSubscription.Reader__c == oldSubscription.Reader__c && newSubscription.Book__c == oldSubscription.Book__c) {
                    newSubscription.addError('Current reader already has this book subscription.');
               }
           }
       }
    }
}