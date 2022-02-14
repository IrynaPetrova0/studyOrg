@isTest
public with sharing class UtilsTest {

     static List<SObject> testList = new List<Book__c>([
            SELECT Name, Quantity__c
            FROM Book__c]);

    @testSetup static void setup() {

        List<Book__c> testBooks = new List<Book__c>();



        for(Integer i=0;i<2;i++) {
            testBooks.add(new Book__c(Name = 'TestBook'+i, Quantity__c = 2));
        }

        for(Integer i=2;i<3;i++) {
            testBooks.add(new Book__c(Name = 'TestBook'+i, Quantity__c = 1 ));
        }

        insert testBooks;



    }

    @isTest static void groupRecordsByFieldTest(){

        Map<String, List<sObject>> expectedResult = new Map<String, List<SObject>>();
        expectedResult.put('2', new List<Book__c>([SELECT Name, Quantity__c FROM Book__c WHERE Quantity__c = 2]));
        expectedResult.put('1', new List<Book__c>([SELECT Name, Quantity__c FROM Book__c WHERE Quantity__c = 1]));

        Test.startTest();
        Map<String, List<sObject>> result = Utils.groupRecordsByField(testList, 'Quantity__c');
        Test.stopTest();


        System.assertEquals(expectedResult, result);
    }


    @isTest static void getFieldValueFromSobjectListTest() {



        Set<String> expectedResult = new Set<String>();
        for(Integer i = 0; i < 3; i++){
            expectedResult.add('TestBook'+i);
        }

        Test.startTest();
        Set <String> result = Utils.getFieldValueFromSobjectList(testList, 'Name');
        Test.stopTest();

        System.assertEquals(expectedResult, result);

    }

}