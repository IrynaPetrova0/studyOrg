/**
 * Created by iryna.petrova on 12/22/2021.
 */
@IsTest
public with sharing class ProjectAssignment_Test {

    @TestSetup
    static void setup(){
        List<Developer__c> developers = new List<Developer__c>();
        for(Integer i = 1; i < 3; i++){
            developers.add(new Developer__c(
                    Name = 'Developer_' + i,
                    Total_Billable_Projects__c = 0
            ));
        }
        insert developers;

        List<Project2__c> projects = new List<Project2__c>();
        for(Integer i = 0; i < 2; i++){
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

    @IsTest static void afterInsertAssignmentTest(){
        Id developer1 = [SELECT Id, Name FROM Developer__c WHERE Name = 'Developer_1'].Id;
        Id developer2 = [SELECT Id, Name FROM Developer__c WHERE Name = 'Developer_2'].Id;
        Id project1 = [SELECT Id, Name FROM  Project2__c WHERE Name = 'Project_0'].Id;
        Id project2 = [SELECT Id, Name FROM  Project2__c WHERE Name = 'Project_1'].Id;

        Project2__c project3 = new Project2__c(
                Name = 'Project_3',
                Active__c = true,
                Is_Billable__c = true,
                Project_Budget__c = 1500
        );
        insert project3;

        List<Project_Assignment__c> newAssignments = new List<Project_Assignment__c>();
        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer1,
                Project2__c = project2
        ));

        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer2,
                Project2__c = project1
        ));

        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer2,
                Project2__c = [SELECT Id FROM Project2__c WHERE Name = 'Project_3'].Id
        ));

        Test.startTest();
        {
            insert newAssignments;
        }
        Test.stopTest();

        System.assertEquals(2, [SELECT Total_Billable_Projects__c FROM Developer__c WHERE Id = : developer1].Total_Billable_Projects__c);
        System.assertEquals(3, [SELECT Total_Billable_Projects__c FROM Developer__c WHERE Id = : developer2].Total_Billable_Projects__c);
    }

    @IsTest static void beforeInsertAssignmentTest1(){
        Id developer1 = [SELECT Id, Name FROM Developer__c WHERE Name = 'Developer_1'].Id;
        Id project1 = [SELECT Id, Name FROM  Project2__c WHERE Name = 'Project_0'].Id;

        List<Project_Assignment__c> newAssignments = new List<Project_Assignment__c>();
        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer1,
                Project2__c = project1
        ));

        Test.startTest();
        try {
            insert newAssignments;
        } catch (Exception e) {
            Boolean exceptionThrown = e.getMessage().contains('Sorry, but Project Assignment with such Developer and Project is already created');
            System.assert(exceptionThrown);
        }
        Test.stopTest();
    }

    @IsTest static void beforeInsertAssignmentTest2(){
        Id developer1 = [SELECT Id, Name FROM Developer__c WHERE Name = 'Developer_1'].Id;
        Id project2 = [SELECT Id, Name FROM  Project2__c WHERE Name = 'Project_1'].Id;

        List<Project_Assignment__c> newAssignments = new List<Project_Assignment__c>();
        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer1,
                Project2__c = project2
        ));

        newAssignments.add(new Project_Assignment__c(
                Developer__c = developer1,
                Project2__c = project2
        ));

        Test.startTest();
        try {
            insert newAssignments;
        } catch (Exception e) {
            Boolean exceptionThrown = e.getMessage().contains('Sorry, but you can\'t insert Project Assignments with the same parameters');
            System.assert(exceptionThrown);
        }
        Test.stopTest();
    }

}