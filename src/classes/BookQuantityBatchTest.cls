@IsTest
public with sharing class BookQuantityBatchTest {
    @TestSetup
    static void  setup(){
        List<Book__c> books = new List<Book__c>();

        for(Integer i = 0; i < 4; i++){
            Book__c book = new Book__c();
            book.Name = 'Book # ' + i;
            book.Quantity__c = 1;
            books.add(book);
        }
        books.add(new Book__c(Name = 'Special Book', Quantity__c = 100));
        insert books;

        Reader__c reader1 = new Reader__c();
        reader1.Name = 'Test1';
        reader1.Email__c = 'test1@test.com';
        reader1.Debtor__c = false;
        reader1.Subscription_Type__c = 'Year';
        insert reader1;

        List<Book__c> insBooks = new List<Book__c>([SELECT Id FROM Book__c]);
        List<Subscription__c> allSubscriptions = new List<Subscription__c>();
        for(Book__c book: insBooks){
            Subscription__c subscription = new Subscription__c();
            subscription.Start_Date__c = Date.today().addDays(-3);
            subscription.Book__c = book.Id;
            subscription.Reader__c = [SELECT Id FROM Reader__c].Id;
            allSubscriptions.add(subscription);
        }
        insert allSubscriptions;
    }

    @IsTest
    static void test(){
        Test.startTest();
        BookQuantityBatch myBatch = new BookQuantityBatch();
        Id myBatchId = Database.executeBatch(myBatch);
        Test.stopTest();
        System.debug([SELECT id, Quantity__c FROM Book__c]);

        System.assertEquals(4, [SELECT COUNT() FROM Book__c WHERE Quantity__c = 4]);
    }
}