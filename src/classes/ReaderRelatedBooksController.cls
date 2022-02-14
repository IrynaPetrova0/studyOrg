public with sharing class ReaderRelatedBooksController {

    @AuraEnabled(Cacheable=true)
    public static List<Book__c> getRelatedBooks(Id recordId){
        List<Subscription__c> subscriptions = new List<Subscription__c>([SELECT Book__c
        FROM Subscription__c
        WHERE Reader__c = :recordId AND Start_Date__c = THIS_YEAR]);
        Set<Id> bookId = new Set<Id>();
        for (Subscription__c subs: subscriptions){
            bookId.add(subs.Book__c);
        }


        return [SELECT Name, Author__c FROM Book__c WHERE Id IN : bookId];

    }
}