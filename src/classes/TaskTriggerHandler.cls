/**
 * Created by iryna.petrova on 12/7/2021.
 */

public with sharing class TaskTriggerHandler {

    public static void onAfterInsert(List<Task__c> newTasks) {

        Set<Id> peoplesId = new Set<Id>();
        for (Task__c task : newTasks) {
            peoplesId.add(task.Person__c);
        }

        List<Person__c> peopleForUpdateL = [
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN :peoplesId
        ];

        Map<Id, Person__c> peopleForUpdate = new Map<Id, Person__c>([
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN :peoplesId
        ]);

        List<AggregateResult> projectAmount = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c IN :peoplesId
                GROUP BY Person__c
        ]);

        Map<Id, Integer> projectAmountMap = new Map<Id, Integer>();
        for (AggregateResult result : projectAmount) {
            projectAmountMap.put((Id) result.get('Person__c'), (Integer) result.get('sumProjects'));
        }

        for (Id personId : projectAmountMap.keySet()) {
            peopleForUpdate.get(personId).Total_Amount_of_Projects__c = projectAmountMap.get(personId);
        }

        for (Task__c task : newTasks) {
            peopleForUpdate.get(task.Person__c).Total_Amount_of_Tasks__c++;
        }

//        for (Integer i = 0; i < peopleForUpdate.size(); i++) {
//            for (Integer j = 0; j < newTasks.size(); j++) {
//                if (peopleForUpdate.get(i).Id == newTasks.get(j).Person__c) {
//                    peopleForUpdate.get(i).Total_Amount_of_Tasks__c++;
//                }
//            }
//        }


        try {
            update peopleForUpdate.values();
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }

    }

    public static void onAfterUpdate(List<Task__c> newTasks, List<Task__c> oldTasks) {
        List<Id> newPeopleIdForUpdate = new List<Id>();
        List<Id> oldPeopleIdForUpdate = new List<Id>();


        for (Integer i = 0; i < newTasks.size(); i++) {
            for (Integer j = 0; j < oldTasks.size(); j++) {
                if (newTasks.get(i).Id == oldTasks.get(j).Id) {
                    if (newTasks.get(i).Person__c != oldTasks.get(j).Person__c) {
                        newPeopleIdForUpdate.add(newTasks.get(i).Person__c);
                        oldPeopleIdForUpdate.add(oldTasks.get(j).Person__c);
                    }
                }
            }
        }

        Set<Id> nonDuplicatePeopleIdUpdate = new Set<Id>();
        nonDuplicatePeopleIdUpdate.addAll(newPeopleIdForUpdate);
        nonDuplicatePeopleIdUpdate.addAll(oldPeopleIdForUpdate);

        List<Person__c> allPeopleForUpdate = new List<Person__c>(
        [
                SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c
                FROM Person__c
                WHERE Id IN :nonDuplicatePeopleIdUpdate
        ]);

        for (Person__c people : allPeopleForUpdate) {
            for (Id addTaskPeople : newPeopleIdForUpdate) {
                if (people.Id == addTaskPeople) {
                    people.Total_Amount_of_Tasks__c++;
                }
            }
            for (Id delTaskPeople : oldPeopleIdForUpdate) {
                if (people.Id == delTaskPeople) {
                    people.Total_Amount_of_Tasks__c--;
                    if (people.Total_Amount_of_Tasks__c == 0) {
                        people.Total_Amount_of_Projects__c = 0;
                    }
                }
            }
        }

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c IN :nonDuplicatePeopleIdUpdate
                GROUP BY Person__c
        ]);

        Map<Id, Integer> projectAmountMap = new Map<Id, Integer>();
        for (AggregateResult result : projectAmountPersonChanged) {
            projectAmountMap.put((Id) result.get('Person__c'), (Integer) result.get('sumProjects'));
        }
        for (Id person : projectAmountMap.keySet()) {
            for (Person__c personUpdate : allPeopleForUpdate) {
                if (person == personUpdate.Id) {
                    personUpdate.Total_Amount_of_Projects__c = projectAmountMap.get(person);
                }
            }
        }

        try {
            update allPeopleForUpdate;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }

    }

    public static void onBeforeUpdate(List<Task__c> updatedTasks, List<Task__c> oldTasks) {
        for (Integer i = 0; i < updatedTasks.size(); i++) {
            for (Integer j = 0; j < oldTasks.size(); j++) {
                if (updatedTasks.get(i).Id == oldTasks.get(j).Id && oldTasks.get(j).Status__c.equals('Completed')
                        && updatedTasks.get(i).Person__c != oldTasks.get(j).Person__c) {
                    //updatedTasks.get(i).Person__c = oldTasks.get(j).Person__c;
                    updatedTasks.get(i).Person__c.addError('Sorry, but when the Task is Completed responsible Person can\'t be changed.');
                }
            }
        }
    }

    public static void onBeforeDelete(List <Task__c> deletedTasks) {

        //Set<Id> projectsWithDeletedTasks = new Set<Id>();
        Set<Id> peopleWithDeletedTasks = new Set<Id>();

        Map<Id, Set<Id>> personToProjectsDeleted = new Map<Id, Set<Id>>();
        Map<Id, Integer> personToTasksSum = new Map<Id, Integer>();

        for (Task__c deletedTask : deletedTasks) {
            //projectsWithDeletedTasks.add(deletedTask.Project__c); //для продж мапа Id Person -> сет Id Project Map<Id, Set<Id>>
            peopleWithDeletedTasks.add(deletedTask.Person__c); // Map<Id, Task(Integer) numberOfTasks>
            if (personToProjectsDeleted.containsKey(deletedTask.Person__c)) {
                personToProjectsDeleted.get(deletedTask.Person__c).add(deletedTask.Project__c);
            } else {
                personToProjectsDeleted.put(deletedTask.Person__c, new Set<Id>{deletedTask.Project__c});
            }

            if (personToTasksSum.containsKey(deletedTask.Person__c)) {
                Integer sumUpd = personToTasksSum.get(deletedTask.Person__c) + 1;
                personToTasksSum.put(deletedTask.Person__c, sumUpd);
            } else {
                personToTasksSum.put(deletedTask.Person__c, 1);
            }
        }

        Map<Id, Person__c> peopleForUpdate = new Map<Id, Person__c>([
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN :peopleWithDeletedTasks
        ]);

        List<Task__c> notDeletedTasks = [SELECT Id, Person__c, Project__c FROM Task__c WHERE Id NOT IN :deletedTasks];
        Map<Id, Set<Id>> personToProjects = new Map<Id, Set<Id>>();

        for (Task__c notDeletedTask : notDeletedTasks) {

            if (personToProjects.containsKey(notDeletedTask.Person__c)) {
                personToProjects.get(notDeletedTask.Person__c).add(notDeletedTask.Project__c);
            } else {
                personToProjects.put(notDeletedTask.Person__c, new Set<Id>{
                        notDeletedTask.Project__c
                });
            }
        }

        for (Id personId : peopleForUpdate.keySet()) {
            peopleForUpdate.get(personId).Total_Amount_of_Tasks__c -= personToTasksSum.get(personId);
            for (Id project : personToProjectsDeleted.get(personId)) {
                if (!personToProjects.get(personId).contains(project)) {
                    peopleForUpdate.get(personId).Total_Amount_of_Projects__c--;
                }
            }
        }


//        List<Person__c> peopleForUpdate = new List<Person__c>(
//        [
//                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
//                FROM Person__c
//                WHERE Id IN :peopleWithDeletedTasks
//        ]);


//        for (Integer i = 0; i < peopleForUpdate.size(); i++) {
//            for (Integer j = 0; j < deletedTasks.size(); j++) {
//                if (peopleForUpdate.get(i).Id == deletedTasks.get(j).Person__c) {
//                    peopleForUpdate.get(i).Total_Amount_of_Tasks__c--;
//                    if (peopleForUpdate.get(i).Total_Amount_of_Tasks__c == 0) {
//                        peopleForUpdate.get(i).Total_Amount_of_Projects__c = 0;
//                    }
//                }
//            }
//        }
//
//        List<AggregateResult> projectAmount = new List<AggregateResult>(
//        [
//                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
//                FROM Task__c
//                WHERE Person__c IN :peopleForUpdate AND Id NOT IN :deletedTasks
//                GROUP BY Person__c
//        ]);
//
//        Map<Id, Integer> projectAmountMap = new Map<Id, Integer>();
//        for (AggregateResult result : projectAmount) {
//            projectAmountMap.put((Id) result.get('Person__c'), (Integer) result.get('sumProjects'));
//        }
//        for (Id person : projectAmountMap.keySet()) {
//            for (Person__c personUpdate : peopleForUpdate) {
//                if (person == personUpdate.Id) {
//                    personUpdate.Total_Amount_of_Projects__c = projectAmountMap.get(person);
//                }
//            }
//        }


        try {
            update peopleForUpdate.values();
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }

    }

    public static void onAfterUndelete(List <Task__c> undeletedTasks) {

        Set<Id> peopleId = new Set<Id>();
        for (Task__c undeletedTask : undeletedTasks) {
            peopleId.add(undeletedTask.Person__c);
        }

        List<Person__c> peopleForUpdate = new List<Person__c>([
                SELECT Id, Total_Amount_of_Tasks__c, Total_Amount_of_Projects__c
                FROM Person__c
                WHERE Id IN :peopleId
        ]);


        for (Integer i = 0; i < peopleForUpdate.size(); i++) {
            for (Integer j = 0; j < undeletedTasks.size(); j++) {
                if (peopleForUpdate.get(i).Id == undeletedTasks.get(j).Person__c) {
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