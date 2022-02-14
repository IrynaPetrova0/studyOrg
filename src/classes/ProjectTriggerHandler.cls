/**
 * Created by iryna.petrova on 12/9/2021.
 */

public with sharing class ProjectTriggerHandler {

    public static void onBeforeDelete(List <Project__c> deletedProjects) {

        List<Task__c> connectedTasks = new List<Task__c>([
                SELECT Id, Person__c, Project__c
                FROM Task__c
                WHERE Project__c IN :deletedProjects
        ]);

        Set<Id> peopleId = new Set<Id>();
        for(Task__c task : connectedTasks){
            peopleId.add(task.Person__c);
        }

        List<Person__c> peopleForUpdate = new List<Person__c>([
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN : peopleId
        ]);

        for (Integer i = 0; i < peopleForUpdate.size(); i++) {
            for (Integer j = 0; j < connectedTasks.size(); j++) {
                if(peopleForUpdate.get(i).Id == connectedTasks.get(j).Person__c){
                peopleForUpdate.get(i).Total_Amount_of_Tasks__c--;
                    if (peopleForUpdate.get(i).Total_Amount_of_Projects__c == 1 && peopleForUpdate.get(i).Total_Amount_of_Tasks__c == 0) {
                        peopleForUpdate.get(i).Total_Amount_of_Projects__c = 0;
                    }
                }
            }
        }

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c IN :peopleId AND Id NOT IN :connectedTasks
                GROUP BY Person__c
        ]);

        System.debug(projectAmountPersonChanged);

        Map<Id, Integer> projectAmountMap = new Map<Id, Integer>();
        for (AggregateResult result : projectAmountPersonChanged) {
            projectAmountMap.put((Id) result.get('Person__c'), (Integer) result.get('sumProjects'));
        }
        for (Id person : projectAmountMap.keySet()) {
            for (Person__c personUpdate : peopleForUpdate) {
                if (person == personUpdate.Id) {
                    personUpdate.Total_Amount_of_Projects__c = projectAmountMap.get(person);
                }
            }
        }

        try {
            update peopleForUpdate;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }

    }

    public static void onAfterUndelete(List<Project__c> undeletedProjects){

        List<Task__c> undeletedTasks = new List<Task__c>([
                SELECT Id, Person__c, Project__c
                FROM Task__c
                WHERE Project__c IN : undeletedProjects
        ]);

        Set<Id> peopleId = new Set<Id>();
        for(Task__c task : undeletedTasks){
            peopleId.add(task.Person__c);
        }

        List<Person__c> peopleForUpdate = new List<Person__c>([
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN : peopleId
        ]);

        for(Integer i = 0; i < peopleForUpdate.size(); i++){
            for(Integer j = 0; j < undeletedTasks.size(); j++){
                if(peopleForUpdate.get(i).Id == undeletedTasks.get(j).Person__c){
                    peopleForUpdate.get(i).Total_Amount_of_Tasks__c++;
                }
            }
        }

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c IN :peopleId
                GROUP BY Person__c
        ]);

        Map<Id, Integer> projectAmountMap = new Map<Id, Integer>();
        for (AggregateResult result : projectAmountPersonChanged) {
            projectAmountMap.put((Id) result.get('Person__c'), (Integer) result.get('sumProjects'));
        }
        for (Id person : projectAmountMap.keySet()) {
            for (Person__c personUpdate : peopleForUpdate) {
                if (person == personUpdate.Id) {
                    personUpdate.Total_Amount_of_Projects__c = projectAmountMap.get(person);
                }
            }
        }

        try {
            update peopleForUpdate;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }



    }
}