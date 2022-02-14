public with sharing class LibraryService {

    /**
    * Create Subscription record and populate it`s bookId and readerId
    *
    * @param bookId Id of selected Book
    * @param readerId Id of selected Reader
    */
    public static void createSubscription(Id bookId, Id readerId){

        Subscription__c subscription = new Subscription__c(Book__c = bookId, Reader__c = readerId, Start_Date__c = Date.today());

        try{
            insert subscription;
        }catch (DmlException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }

    /**
    * Sets ReturnedDate__c to current date
    *
    * @param subscriptionId Id of selected Subscription
    */
    public static void closeSubscription(Id subscriptionId){

        Subscription__c subscription = new Subscription__c(Id = subscriptionId, Returned_Date__c = Date.today());

        try{
            update subscription;
        }catch(DmlException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }

    /**
    * Create Reader obj.
    *
    * @param name Name of created Reader
    * @param subscriptionType Subscription Type (one-time, month, year, VIP) of created Reader
    * @param email Email of created Reader
    */
    public static void createReader(String name, String subscriptionType, String email){
        Reader__c reader = new Reader__c(Name = name, Subscription_Type__c = subscriptionType, Email__c = email);

        try{
            insert reader;
        }catch(DmlException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }

    /**
    * Update readers with specified subscription
    *
    * @param readerIds List of selected Readers' Ids
    * @param subscriptionType Type of Subscription (one-time, month, year, VIP) to update
    */
    public static void upgradeReader(List<Id> readerIds, String subscriptionType){
        List<Reader__c> readersUpdate = new List<Reader__c>();
        for (Id readerId: readerIds) {
            readersUpdate.add(new Reader__c(Id = readerId, Subscription_Type__c = subscriptionType));
            //Reader__c reader = new Reader__c(Id = readerId, Subscription_Type__c = subscriptionType);
        }
            try {
                update readersUpdate;

            } catch (DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }

    }

    /**
    * Delete  selected books by Id
    *
    * @param bookIds List of selected Books" Ids to delete
    */
    public static void deleteBooks(List<Id> bookIds){

        List<Book__c> booksDelete = new List<Book__c>();
        for (Id bookId: bookIds) {
            //Book__c book = new Book__c(Id = bookId);
            booksDelete.add(new Book__c(Id = bookId));
        }
            try {
                delete booksDelete;
            } catch (DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }


    }
}