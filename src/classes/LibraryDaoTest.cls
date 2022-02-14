@isTest
public with sharing class LibraryDaoTest {
   static List<Reader__c> readers = new List<Reader__c>();


    @testSetup static void setup() {


        Reader__c reader1 = new Reader__c(Name = 'Test1', Email__c = 'test1@test.com', Subscription_Type__c = 'Year');
        readers.add(reader1);
        Reader__c reader2 = new Reader__c(Name = 'Test2', Email__c = 'test2@test.com');
        readers.add(reader2);

        List<Book__c> books = new List<Book__c>();
        Book__c book1 = new Book__c(Name = 'Book1Test', Author__c = 'Author1');
        books.add(book1);
        Book__c book2 = new Book__c(Name = 'Book2Test', Author__c = 'Author2');
        books.add(book2);

        insert readers;
        insert books;

        List<Subscription__c> subscriptions = new List<Subscription__c>();
        Subscription__c subscription1 = new Subscription__c(Start_Date__c = Date.today().addDays(-1), Days_Of_Hold_Allowed__c = 61, Reader__c =  reader1.Id, Book__c = book1.Id);
        subscriptions.add(subscription1);
        Subscription__c subscription2 = new Subscription__c(Start_Date__c = Date.today().addYears(-1), Days_Of_Hold_Allowed__c = 0, Reader__c =  reader2.Id, Book__c = book2.Id);
        subscriptions.add(subscription2);
        Subscription__c subscription3 = new Subscription__c(Start_Date__c = Date.today().addDays(-5), Days_Of_Hold_Allowed__c = 61, Reader__c =  reader2.Id, Book__c = book1.Id);
        subscriptions.add(subscription3);

        insert subscriptions;


    }

    @isTest static void getActiveSubscriptionsTest(){

        Id readerId = [SELECT Reader__r.Id FROM Subscription__c LIMIT 1].Reader__r.Id;
        List<Subscription__c> subscriptions = LibraryDao.getActiveSubscriptions(readerId);

        System.assert( subscriptions  != null);

    }

    @isTest static void getAllSubscriptionsTest(){
        List<Subscription__c> subscriptions = LibraryDao.getAllSubscriptions(2, 1);
        System.assert(subscriptions.size() == 2);
    }

    @isTest static void getReadersCountTest(){
        List<AggregateResult> result = LibraryDao.getReadersCount();

        System.assert(result[0].get('readers') == 2);
    }

    @isTest static void getReadersOfBookTest(){
        Id bookId = [SELECT Id FROM Book__c WHERE Name = 'Book1Test' ].Id;
        Test.startTest();
        List<Reader__c> result = LibraryDao.getReadersOfBook(bookId);
        Test.stopTest();
        readers = [SELECT  Id, Name FROM Reader__c];
        System.assertEquals(readers, result);

    }

    @isTest static void getTerminatedBooksTest(){ // smth wrong with test

        Test.startTest();
        List<Book__c> result = LibraryDao.getTerminatedBooks(3, 0);
        Test.stopTest();

        List<Book__c> expectedResult = new List<Book__c>([SELECT Id, Name, Author__c FROM Book__c WHERE Name = 'Book2Test']);
        System.assertEquals(expectedResult, result);
    }


    @isTest static void getTerminationReadersTest(){ //smth wrong with test

        Test.startTest();
        Set<Id> result = LibraryDao.getTerminationReaders();
        System.debug(result);
        Test.stopTest();

        Set<Id> expectedResult = new Set<Id>();
        expectedResult.add([SELECT Id FROM Reader__c WHERE Name = 'Test2' AND Email__c = 'test2@test.com'].Id);


        System.assertEquals(expectedResult, result);
    }



}