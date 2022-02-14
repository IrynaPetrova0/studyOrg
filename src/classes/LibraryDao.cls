public class LibraryDao {

    /**
    * get total subscribed books for reader (who`s SubscriptionType__c is not not one-time)
    *
    * @param readerId id of selected user
    *
    * @return list of active Subscriptions of selected user
    */
    public static List<Subscription__c> getActiveSubscriptions(Id readerId){
        
        List<Subscription__c> subscriptionsActive = new List<Subscription__c>([
            SELECT Reader__r.Id, Book__r.Name
            FROM Subscription__c
            WHERE Reader__r.Id = :readerId]);
        
        return subscriptionsActive;
    }

    /**
    * get all Subscription__c using limit and offset
    *
    * @param limitN limit for rows
    * @param offsetN exclude number of rows
    *
    * @return all Subscriptions using limit and offset
    */

    public static List<Subscription__c> getAllSubscriptions(Integer limitN, Integer offsetN){
        
        List<Subscription__c> subscriptions = new List<Subscription__c>([
            SELECT Id, Name
            FROM Subscription__c
            LIMIT: limitN 
            OFFSET: offsetN
        ]);        
        
        return subscriptions;
    }

    /**
    * get count off all readers in the system
    *
    * @return count off all readers
    */

    public static List<AggregateResult> getReadersCount(){
        List<AggregateResult> totalAmountReaders = new List<AggregateResult>([
            SELECT Count(Id) readers
            FROM Reader__c
        ]);
        
        return totalAmountReaders;
    }

    /**
    * get all Readers with selected Book
    *
    * @param bookId id of selected Book
    *
    * @return all Readers with selected Book
    */

    public static List<Reader__c> getReadersOfBook(Id bookId){
        List<Subscription__c> subscriptions = new List<Subscription__c>([
                SELECT Id, Reader__r.Id FROM Subscription__c WHERE Book__r.Id = :bookId
        ]);

        Set<Id> readersIds = new Set<Id>();

        for (Subscription__c subscription: subscriptions){
            readersIds.add(subscription.Reader__c);
        }

        List<Reader__c> readers = new List<Reader__c>([
                SELECT Id, Name FROM Reader__c WHERE Id IN : readersIds
        ]);


        return readers;
    }

    /**
    * Get all termitated books using limit and offset
    *
    * @param limitN limit of rows
    * @param offsetN number of rows to exclude
    *
    * @return all termitated books using limit and offset
    */


    public static List<Book__c> getTerminatedBooks(Integer limitN, Integer offsetN){
        List<Subscription__c> subscriptions = new List<Subscription__c>([SELECT Id, Hold_Duration__c, Days_Of_Hold_Allowed__c, Book__c
        FROM Subscription__c
        ]);

        List<Id> booksIds = new List<Id>();


        for (Subscription__c subscription: subscriptions){
            if (subscription.Hold_Duration__c > subscription.Days_Of_Hold_Allowed__c) {
                booksIds.add(subscription.Book__c);
            }
        }

        List<Book__c> terminatedBooks = new List<Book__c>([
                SELECT Id, Name, Author__c
                FROM Book__c
                WHERE Id IN : booksIds
                LIMIT : limitN
                OFFSET : offsetN
        ]);

        return terminatedBooks;
    }

    /**
    * Get all Ids of Reader who has at least one terminated book
    *
    * @return Set of Readers' Ids
    */
    public static Set<Id> getTerminationReaders(){
        List<Subscription__c> subscriptions = new List<Subscription__c>([SELECT Id, Hold_Duration__c, Days_Of_Hold_Allowed__c, Reader__c
        FROM Subscription__c
        ]);

        Set<Id> readersId = new Set<Id>();


        for (Subscription__c s: subscriptions){
            if (s.Hold_Duration__c > s.Days_Of_Hold_Allowed__c) {
                readersId.add(s.Reader__c);
            }
        }


        return readersId;

    }

}