/**
 * Created by iryna.petrova on 12/21/2021.
 */

public with sharing class ProjectAssignmentHandler {

    public static void onAfterInsert(List<Project_Assignment__c> newProjectAssignments) {

        List<Id> developersIds = new List<Id>();
        for (Project_Assignment__c projectAssignment : newProjectAssignments) {
            developersIds.add(projectAssignment.Developer__c);
        }

        List<Developer__c> devUpd = [
                SELECT Id, Total_Billable_Projects__c, (
                        SELECT Project2__c
                        FROM Project_Assignments__r
                        WHERE Project2__r.Is_Billable__c = TRUE
                )
                FROM Developer__c
                WHERE Id IN :developersIds
        ];

        for (Developer__c developer : devUpd) {
            developer.Total_Billable_Projects__c = developer.Project_Assignments__r.size();
        }

        try {
            update devUpd;
//            Database.update(devUpd, false);
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }

    public static void onBeforeInsert(List<Project_Assignment__c> newProjectAssignments) {

        for (Integer i = 0; i < newProjectAssignments.size() - 1; i++) { //2*for
            if(newProjectAssignments[i].Developer__c == newProjectAssignments[i+1].Developer__c &&
                    newProjectAssignments[i].Project2__c == newProjectAssignments[i+1].Project2__c){
                newProjectAssignments[i].addError('Sorry, but you can\'t insert Project Assignments with the same parameters');
            }
        }

        Set<Id> developersIds = new Set<Id>();
        Set<Id> projectsIds = new Set<Id>();

        for (Project_Assignment__c assignment : newProjectAssignments) {
            developersIds.add(assignment.Developer__c);
            projectsIds.add(assignment.Project2__c);
        }

        List<Project_Assignment__c> allAssignments = [
                SELECT Id, Developer__c, Project2__c, Developer__r.Name
                FROM Project_Assignment__c
                WHERE Project2__c IN :projectsIds
                AND Developer__c IN:developersIds
        ];

        for (Project_Assignment__c newProjectAssignment : newProjectAssignments) {
            for (Project_Assignment__c oldProjectAssignment : allAssignments) {
                if (newProjectAssignment.Developer__c == oldProjectAssignment.Developer__c &&
                        newProjectAssignment.Project2__c == oldProjectAssignment.Project2__c) {
                    newProjectAssignment.addError('Sorry, but Project Assignment with such Developer and Project is already created');
                }
            }
        }
        //Map<String, List<Project_Assignment>> String = Developer + Project ---> Set!
        //Database.insert...
    }
}