public with sharing class BookQuantityBatch implements Database.Batchable<SObject>, Schedulable {


    public Database.QueryLocator start(Database.BatchableContext bc) {

        List<Book__c> books = new List<Book__c>([SELECT Id, Quantity__c FROM Book__c]);

        List<AggregateResult> sumBooks = new List<AggregateResult>(
        [SELECT Book__c, COUNT(Book__r.Id) sumBook
        FROM Subscription__c
        WHERE Returned_Date__c  = NULL
        GROUP BY Book__c]);
        System.debug(sumBooks);
        List<Book__c> updateBooks = new List<Book__c>();
        Map<Id, Integer> mapBook = new Map<Id, Integer>();
        for (AggregateResult result: sumBooks){
            mapBook.put((Id)result.get('Book__c'), (Integer)result.get('sumBook'));
        }
        System.debug(mapBook);

        for(Id book: mapBook.keySet()){
            for(Book__c b: books){
                if(book == b.Id && mapBook.get(book) >= b.Quantity__c){
                    updateBooks.add(b);
                }
            }
        }

        //System.debug(updateBooks);

        return Database.getQueryLocator('SELECT Id, Quantity__c FROM Book__c WHERE Id IN: updateBooks');
    }


    public void execute(Database.BatchableContext bc, List<Book__c> books) {
        List<Book__c> updatedBooks = new List<Book__c>();
        for (Book__c book: books){
            book.Quantity__c += 3;
            updatedBooks.add(book);
        }

        update updatedBooks;

    }

    public void execute(SchedulableContext param1) {
        BookQuantityBatch myBatch = new BookQuantityBatch();
        String cronStr = '0 0 0 1 * ?';
        String jobID = System.schedule('Update Book Quantity' , cronStr, myBatch);

    }

    public void finish(Database.BatchableContext param1) {
    }


}