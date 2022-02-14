/**
 * Created by iryna.petrova on 12/9/2021.
 */
@IsTest
public with sharing class TaskTriggerTest {

    @TestSetup static void setup() {
        Person__c person1 = new Person__c(Total_Amount_of_Projects__c = 0, Total_Amount_of_Tasks__c = 0, First_Name__c = 'Alan', Last_Name__c = 'Shweps');
        Person__c person2 = new Person__c(Total_Amount_of_Projects__c = 0, Total_Amount_of_Tasks__c = 0, First_Name__c = 'Mia', Last_Name__c = 'Chia');

        insert person1;
        insert person2;

        Project__c project1 = new Project__c(Name = 'Project_1');
        Project__c project2 = new Project__c(Name = 'Project_2');

        insert project1;
        insert project2;

        List<Task__c> tasks = new List<Task__c>();

        for (Integer i = 1; i < 3; i++) {
            tasks.add(new Task__c(Label__c = 'Task_' + i, Project__c = [SELECT Id FROM Project__c WHERE Name = 'Project_1'].Id, Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Alan'].Id, Status__c = 'Draft'));
        }
        for (Integer i = 3; i < 4; i++) {
            tasks.add(new Task__c(Label__c = 'Task_' + i, Project__c = [SELECT Id FROM Project__c WHERE Name = 'Project_2'].Id, Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id, Status__c = 'Draft'));
        }
        tasks.add(new Task__c(Label__c = 'Task_4', Project__c = [SELECT Id FROM Project__c WHERE Name = 'Project_2'].Id, Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Alan'].Id, Status__c = 'Completed'));
        insert tasks;
    }

    @IsTest static void insertTaskTest() {
        Task__c newTask1 = new Task__c(
                Label__c = 'Task_5', Project__c = [SELECT Id FROM Project__c WHERE Name = 'Project_1'].Id,
                Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id);

        Test.startTest();
        insert newTask1;
        Test.stopTest();

        Integer taskSum = [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Mia'].size();
        System.assertEquals(2, taskSum);
        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id
                GROUP BY Person__c
        ]);
        System.assertEquals(2,projectAmountPersonChanged.get(0).get('sumProjects'));

    }

    @IsTest static void updateTaskTest() {

        Task__c taskId = [SELECT Id, Person__c, Project__c FROM Task__c WHERE Label__c = 'Task_2'];
        Task__c forUpdateTask1 = new Task__c(Id = taskId.Id);
        forUpdateTask1.Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id;
        Task__c forUpdateTask4 = [SELECT Id, Person__c, Project__c, Status__c, Label__c FROM Task__c WHERE Label__c = 'Task_4'];
        forUpdateTask4.Person__c = [SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id;

        Test.startTest();

        try {
            update forUpdateTask1;
            update forUpdateTask4;
            System.assert(false,'Exception should appear');
        } catch (Exception e) {
            Boolean actualExceptionThrown = e.getMessage().contains('Sorry, but when the Task is Completed responsible Person can\'t be changed.');

            //System.assertEquals(actualExceptionThrown, true);
            System.assert(actualExceptionThrown);
        }

        Test.stopTest();

        System.assertEquals(2, [SELECT Total_Amount_of_Tasks__c FROM Person__c WHERE First_Name__c = 'Mia'].get(0).Total_Amount_of_Tasks__c);
        System.assertEquals(2, [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Alan'].size());

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id
                GROUP BY Person__c
        ]);
        System.assertEquals(2,projectAmountPersonChanged.get(0).get('sumProjects'));
    }

    @IsTest static void deleteTaskTest(){
        List<Task__c> tasksDelete = new List<Task__c>([SELECT Id, Label__c FROM Task__c WHERE  Label__c = 'Task_3']);
        tasksDelete.add([SELECT Id, Label__c FROM Task__c WHERE  Label__c = 'Task_1']);

        Test.startTest();
        delete tasksDelete;
        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Mia'].size());
        System.assertEquals(2, [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Alan'].size());

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id
                GROUP BY Person__c
        ]);
        System.debug(projectAmountPersonChanged);
        System.assertEquals(true,projectAmountPersonChanged.isEmpty());

        List<AggregateResult> projectAmountPersonChanged2 = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Alan'].Id
                GROUP BY Person__c
        ]);
        System.assertEquals(2,projectAmountPersonChanged2.get(0).get('sumProjects'));
    }

    @IsTest static void undeleteTaskTest(){
        List<Task__c> tasksDelete = new List<Task__c>([SELECT Id, Label__c FROM Task__c WHERE  Label__c = 'Task_3']);
        tasksDelete.add([SELECT Id, Label__c FROM Task__c WHERE  Label__c = 'Task_1']);

        delete tasksDelete;

        Test.startTest();
        undelete tasksDelete;
        Test.stopTest();

        System.assertEquals(1, [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Mia'].size());
        System.assertEquals(3, [SELECT Id, Person__c FROM Task__c WHERE Person__r.First_Name__c = 'Alan'].size());

        List<AggregateResult> projectAmountPersonChanged = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Mia'].Id
                GROUP BY Person__c
        ]);
        System.assertEquals(1,projectAmountPersonChanged.get(0).get('sumProjects'));

        List<AggregateResult> projectAmountPersonChanged2 = new List<AggregateResult>(
        [
                SELECT COUNT_DISTINCT(Project__c) sumProjects, Person__c
                FROM Task__c
                WHERE Person__c = :[SELECT Id FROM Person__c WHERE First_Name__c = 'Alan'].Id
                GROUP BY Person__c
        ]);
        System.assertEquals(2,projectAmountPersonChanged2.get(0).get('sumProjects'));

    }

}