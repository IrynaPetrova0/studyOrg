@RestResource(UrlMapping = '/top5Readers/*')
global with sharing class ReaderControllerREST {

    @HttpGet
    global static List<Reader__c> getReaders(){
        return [SELECT Id, Name, Number_Of_Hold_Books__c FROM Reader__c ORDER BY Number_Of_Hold_Books__c DESC LIMIT 5];
    }
}