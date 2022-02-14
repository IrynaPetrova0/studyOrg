public with sharing class BookTriggerHandler {
    

    public static void onBeforeDelete(List<Book__c> booksDelete){
        System.debug('Books delete:' + booksDelete);

        List<Subscription__c> subscriptions = new List<Subscription__c>([
            SELECT Reader__c
            FROM Subscription__c
            WHERE Book__c IN :booksDelete
        ]);

        System.debug('All subscr' + subscriptions);

        Set<Id> readerIds = new Set<Id>();

        for (Subscription__c subscription: subscriptions){
           readerIds.add((Id)subscription.Reader__c);
        }
        System.debug(readerIds);
        List<Reader__c> readersDebtors = new List<Reader__c>();
        //Reader__c readerDebtor;

        for(Id readerId: readerIds){
            //Reader__c readerDebtor  = new Reader__c(Id = readerId, Debtor__c = true);
            readersDebtors.add(new Reader__c(Id = readerId, Debtor__c = true));
        }
            try{
                update readersDebtors;
                System.debug('updated' + readersDebtors);
            }catch(DmlException e){
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }



    }
}