public with sharing class TopBooksServices {
    @AuraEnabled
    public static List <Book__c> fetchBooks() {

        List<AggregateResult> booksFromSubscriptions = new List<AggregateResult>([SELECT Book__c
        FROM Subscription__c
        GROUP BY Book__c
        Order BY COUNT(Book__r.Id) DESC
        LIMIT 10]);
        List<Book__c> bookAll = new List<Book__c>([SELECT Id, Name, Author__c FROM Book__c]);
        List<Id> booksIds = new List<Id>();
        for(AggregateResult groupB: booksFromSubscriptions){
            booksIds.add((Id)groupB.get('Book__c'));
        }
        List<Book__c> topBooks = new List<Book__c>();

        for (Id bookId: booksIds){
            for(Book__c book: bookAll){
                if(bookId == book.Id){
                    topBooks.add(book);
                }
            }
        }

        return topBooks;
    }

}