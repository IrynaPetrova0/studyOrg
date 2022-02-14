/**
 * Created by iryna.petrova on 12/22/2021.
 */
@IsTest
public with sharing class Project2_Test {

    @TestSetup
    static void setup() {
        List<Developer__c> developers = new List<Developer__c>();
        for (Integer i = 1; i < 3; i++) {
            developers.add(new Developer__c(
                    Name = 'Developer_' + i,
                    Total_Billable_Projects__c = 0
            ));
        }
        insert developers;

        List<Project2__c> projects = new List<Project2__c>();
        for (Integer i = 0; i < 2; i++) {
            projects.add(new Project2__c(
                    Name = 'Project_' + i,
                    Active__c = true,
                    Is_Billable__c = true,
                    Project_Budget__c = 100 + i
            ));
        }
        insert projects;

        List<Project_Assignment__c> assignments = new List<Project_Assignment__c>();
        assignments.add(new Project_Assignment__c(
                Developer__c = developers[0].Id,
                Project2__c = projects[0].Id
        ));

        assignments.add(new Project_Assignment__c(
                Developer__c = developers[1].Id,
                Project2__c = projects[1].Id
        ));

        insert assignments;
    }

    @IsTest static void afterUpdateProjectTest() {
        Project2__c project = [
                SELECT Name, Id, Is_Billable__c
                FROM Project2__c
                WHERE Name = 'Project_0'
        ];
        project.Is_Billable__c = false;

        Test.startTest();
        {
            update project;
        }
        Test.stopTest();

        System.assertEquals(0, [
                SELECT Total_Billable_Projects__c
                FROM Developer__c
                WHERE Name = 'Developer_1'
        ].Total_Billable_Projects__c, '');
    }
}