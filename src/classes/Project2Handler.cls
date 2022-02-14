/**
 * Created by iryna.petrova on 12/21/2021.
 */

public with sharing class Project2Handler {

    public static void onAfterUpdate(Map<Id, Project2__c> oldProjects, Map<Id, Project2__c> updatedProjects) {

        List<Project_Assignment__c> projectAssignments = [
                SELECT Id, Project2__c, Developer__c
                FROM Project_Assignment__c];

        Set<Id> developersIds = new Set<Id>();
        for (Project_Assignment__c projectAssignment : projectAssignments) {
            developersIds.add(projectAssignment.Developer__c);
        }

        List<Developer__c> devUpd = [
                SELECT Id, Total_Billable_Projects__c, (
                        SELECT Project2__c
                        FROM Project_Assignments__r
                        WHERE Project2__r.Is_Billable__c = TRUE
                )
                FROM Developer__c
                WHERE Id IN : developersIds
        ];

        for (Developer__c developer : devUpd) {
            developer.Total_Billable_Projects__c = developer.Project_Assignments__r.size();
        }
        try {
            update devUpd;
        } catch (DmlException e) {
    System.debug(e.getMessage());
        }

//        List<Id> developersIds = new List<Id>();
//        for (Project_Assignment__c projectAssignment : updated) {
//            developersIds.add(projectAssignment.Developer__c);
//        }

//        List<Developer__c> devUpd = [
//                SELECT Id, Total_Billable_Projects__c, (
//                        SELECT Project2__c, Project2__r.Is_Billable__c
//                        FROM Project_Assignments__r
//                        WHERE Project2__c IN :updatedProjects
//                )
//                FROM Developer__c
//        ];

//        for (Developer__c developer : devUpd) {
//            if(oldProjects.get(developer.Project_Assignments__r))
//        }

//        Map<Id, List<Project2__c>> devIdToProjects = new Map<Id, List<Project2__c>>();
//        for (Developer__c developer : devUpd) {
//            devIdToProjects.put(developer.Id, new List<Project2__c>{
//                    developer.Project_Assignments__r.
//            });
//
//        }
    }

}