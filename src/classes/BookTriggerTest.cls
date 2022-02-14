@isTest
public with sharing class BookTriggerTest {


    @isTest static void addDuplicateSubscription() {

        Reader__c reader1 = new Reader__c();
        reader1.Name = 'Test1';
        reader1.Email__c = 'test1@test.com';
        reader1.Debtor__c = false;
        reader1.Subscription_Type__c = 'Year';

        Book__c book = new Book__c(Name = 'Book1Test', Author__c = 'Author1');
        insert reader1;
        insert book;

        Subscription__c subscription1 = new Subscription__c(Start_Date__c = Date.today().addDays(-5), Reader__c = reader1.Id, Book__c = book.Id);
        insert subscription1;

        Test.startTest();

        Book__c book1 = [SELECT Id, Name FROM Book__c];
        Database.DeleteResult result = Database.delete(book1, true);

//        try{
//            delete book1;
//        }catch (DmlException e){
//            System.debug(e.getMessage());
//        }
        Boolean debtorBoolean = [SELECT Debtor__c FROM Reader__c].Debtor__c;
        System.debug(debtorBoolean);
        System.debug(book1);
        Test.stopTest();

        System.assertEquals(true, debtorBoolean);
    }
}