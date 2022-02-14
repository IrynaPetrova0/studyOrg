@isTest
public with sharing class SubscriptionTriggerTest {

    @testSetup static void setup() {
        Reader__c reader1 = new Reader__c(Name = 'Test1', Email__c = 'test1@test.com');
        Book__c book1 = new Book__c(Name = 'Book1Test', Author__c = 'Author1');
        insert reader1;
        insert book1;

        Subscription__c subscription1 = new Subscription__c(Start_Date__c = Date.today().addDays(-5), Reader__c = reader1.Id, Book__c = book1.Id);
        insert subscription1;
    }

    @isTest static void adDuplicateSubscription(){

        List<Book__c> books = new List<Book__c>([SELECT Id, Name, Author__c FROM Book__c WHERE Name = 'Book1Test']);
        Book__c book1 = books.get(0);
        List<Reader__c> readers = new List<Reader__c>([SELECT Id, Name, Email__c  FROM Reader__c WHERE Name = 'Test1' AND Email__c = 'test1@test.com']);
        Reader__c reader1 = readers.get(0);

        Subscription__c subscription2 = new Subscription__c(Start_Date__c = Date.today(), Reader__c = reader1.Id, Book__c = book1.Id);

        Test.startTest();
        Database.SaveResult result = Database.insert(subscription2, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Current reader already has this book subscription.',
                result.getErrors()[0].getMessage());



    }

}