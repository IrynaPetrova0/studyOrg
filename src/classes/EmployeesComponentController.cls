
public with sharing class EmployeesComponentController {

    @AuraEnabled(Cacheable=true)
    public static List<Employee__c> getRelatedEmployees(Id recordId) {
        List<Employee__c> employees = new List<Employee__c>([
                SELECT Id, Name
                FROM Employee__c
                WHERE Id IN (
                        SELECT Employee__c
                        FROM Study_Team_Member__c
                        WHERE Study__c = :recordId
                )
        ]);
        employees.addAll([
                SELECT Id, Name
                FROM Employee__c
                WHERE Id IN (
                        SELECT Employee__c
                        FROM Country_Team_Member__c
                        WHERE Country__r.Study__c = :recordId
                ) AND Id NOT IN :employees
        ]);

        employees.addAll([
                SELECT Id, Name
                FROM Employee__c
                WHERE Id IN (
                        SELECT Employee__c
                        FROM Site_Team_Member__c
                        WHERE Site__r.Country__r.Study__c = :recordId
                ) AND Id NOT IN :employees
        ]);

        return employees;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Employee__c> getRelatedActiveEmployees(List<Employee__c> checkedEmployees, String sourceTable, Boolean isActive, Id recordId) {
        System.debug(checkedEmployees);
        System.debug(sourceTable);
        Set<Id> employeesIds = new Set<Id>();
        for (Employee__c employee : checkedEmployees) {
            employeesIds.add(employee.Id);
        }

        String query = 'SELECT Employee__r.Name, Active__c, Start_Date__c FROM ' + sourceTable
                + ' WHERE Employee__c IN :checkedEmployees AND ' ;

        if (sourceTable == 'Study_Team_Member__c') {
            query += 'Study__c = :recordId';
        } else if (sourceTable == 'Country_Team_Member__c') {
            query += 'Country__r.Study__c = :recordId';
        } else {
            query += 'Site__r.Country__r.Study__c = :recordId';
        }

        if (isActive) {
            query += ' AND Active__c = TRUE';
        }

        return Database.query(query);
    }

    @AuraEnabled
    public static void changeActiveStatus(Id recordId, Boolean isActive) {
        System.debug('changeActiveStatus');
        System.debug(recordId);
        System.debug(isActive);

        SObject updateMember = recordId.getSobjectType().newSObject(recordId);
        updateMember.put('Active__c', !isActive);
        try {
            update updateMember;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());

        }

    }


}