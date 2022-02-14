/**
 * Created by iryna.petrova on 12/15/2021.
 */
@IsTest
public with sharing class ScheduleTriggerTest {

    @TestSetup static void setup() {
        List<Bus_Route__c> busRoutes = new List<Bus_Route__c>();
        for (Integer i = 1; i < 3; i++) {
            busRoutes.add(new Bus_Route__c(Route_Number__c = i + 'A'));
        }
        insert busRoutes;

        List<Bus_Stop__c> busStops = new List<Bus_Stop__c>();
        for (Integer i = 1; i < 9; i++) {
            busStops.add(new Bus_Stop__c(Name = 'Stop_' + i));
        }
        insert busStops;

        List<Schedule__c> schedules = new List<Schedule__c>();
        for (Integer i = 0; i < 8; i++) {
            if (i >= 0 && i < 6) {
                schedules.add(new Schedule__c(Bus_Route__c = [SELECT Id, Route_Number__c FROM Bus_Route__c WHERE Route_Number__c = '1A'].Id,
                        Time_to_Next_Stop__c = null, Bus_Stop__c = busStops[i].Id,
                        Time__c = Time.newInstance(1, i, 0, 0)));
            } else {
                schedules.add(new Schedule__c(Bus_Route__c = [SELECT Id, Route_Number__c FROM Bus_Route__c WHERE Route_Number__c = '2A'].Id,
                        Time_to_Next_Stop__c = null, Bus_Stop__c = busStops[i].Id,
                        Time__c = Time.newInstance(2, i, 0, 0)));
            }

        }
        System.debug(schedules);
        insert schedules;
    }

    @IsTest static void insertSchedule() {
        Id busRouteId = [SELECT Id FROM Bus_Route__c WHERE Route_Number__c = '1A'].Id;
        Bus_Stop__c busStop1 = new Bus_Stop__c(Name = 'New_Stop_1');
        Bus_Stop__c busStop2 = new Bus_Stop__c(Name = 'New_Stop_2');
        List<Bus_Stop__c> newBusStops = new List<Bus_Stop__c>{
                busStop1, busStop2
        };
        insert newBusStops;
        List<Schedule__c> newSchedules = new List<Schedule__c>();
        newSchedules.add(new Schedule__c(
                Bus_Route__c = busRouteId,
                Bus_Stop__c = [SELECT Id FROM Bus_Stop__c WHERE Name = 'New_Stop_1'].Id,
                Time__c = Time.newInstance(0, 0, 0, 0)));
        newSchedules.add(new Schedule__c(
                Bus_Route__c = busRouteId,
                Bus_Stop__c = [SELECT Id FROM Bus_Stop__c WHERE Name = 'New_Stop_2'].Id,
                Time__c = Time.newInstance(8, 0, 0, 0)));

        Test.startTest();
        insert newSchedules;
        Test.stopTest();

        Bus_Route__c busRouteCheck = [SELECT Id, Start_Time__c, End_Time__c, Duration_in_Minutes__c FROM Bus_Route__c WHERE Route_Number__c = '1A'];

        System.assertEquals(Time.newInstance(0, 0, 0, 0), busRouteCheck.Start_Time__c,
                'Start time should be 00:00');

        System.assertEquals(Time.newInstance(8, 0, 0, 0), busRouteCheck.End_Time__c,
                'End time should be 08:00');

        System.assertEquals(480, busRouteCheck.Duration_in_Minutes__c, 'Bus Route duration should be 480 minutes');

        System.assertEquals(60,
                [SELECT Id, Bus_Route__c, Bus_Stop__c, Time_to_Next_Stop__c FROM Schedule__c WHERE Bus_Stop__r.Name = 'New_Stop_1'].Time_to_Next_Stop__c,
                'Time to next stop should be 60 min');

        System.assertEquals(null,
                [SELECT Id, Bus_Route__c, Bus_Stop__c, Time_to_Next_Stop__c FROM Schedule__c WHERE Bus_Stop__r.Name = 'New_Stop_2'].Time_to_Next_Stop__c,
                'Time to next stop should be null, because it is last stop for route');
    }

    @IsTest static void updateSchedule() {
        List<Schedule__c> schedulesForUpdate = new List<Schedule__c>();

        Bus_Stop__c busStop5 = [SELECT Name, Id FROM Bus_Stop__c WHERE Name = 'Stop_5'];
        Schedule__c scheduleUpdate1 = [
                SELECT Id, Bus_Stop__c, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop5.Id
        ];
        scheduleUpdate1.Time__c = Time.newInstance(2, 5, 0, 0);
        schedulesForUpdate.add(scheduleUpdate1);

        Bus_Stop__c busStop3 = [SELECT Name, Id FROM Bus_Stop__c WHERE Name = 'Stop_3'];
        Schedule__c scheduleUpdate2 = [
                SELECT Id, Bus_Stop__c, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop3.Id
        ];
        scheduleUpdate2.Time__c = Time.newInstance(0, 50, 0, 0);
        schedulesForUpdate.add(scheduleUpdate2);

        Test.startTest();
        update schedulesForUpdate;
        Test.stopTest();

        Bus_Route__c busRouteCheck = [
                SELECT Id, Start_Time__c, End_Time__c, Duration_in_Minutes__c
                FROM Bus_Route__c
                WHERE Route_Number__c = '1A'
        ];
        System.assertEquals(Time.newInstance(0, 50, 0, 0), busRouteCheck.Start_Time__c,
                'Start time should be at 00:50');

        System.assertEquals(Time.newInstance(2, 5, 0, 0), busRouteCheck.End_Time__c,
                'End time should be at 02:05');

        System.assertEquals(10,
                [SELECT Bus_Stop__c, Time_to_Next_Stop__c FROM Schedule__c WHERE Bus_Stop__c = :busStop3.Id].Time_to_Next_Stop__c);

        System.assertEquals(null,
                [SELECT Bus_Stop__c, Time_to_Next_Stop__c FROM Schedule__c WHERE Bus_Stop__c = :busStop5.Id].Time_to_Next_Stop__c);

        Bus_Stop__c busStop2 = [
                SELECT Name, Id
                FROM Bus_Stop__c
                WHERE Name = 'Stop_2'
        ];

        Bus_Stop__c busStop4 = [
                SELECT Name, Id
                FROM Bus_Stop__c
                WHERE Name = 'Stop_4'
        ];

        System.assertEquals(2, [
                SELECT Bus_Stop__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop2.Id
        ].Time_to_Next_Stop__c);

        System.assertEquals(2, [
                SELECT Bus_Stop__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop4.Id
        ].Time_to_Next_Stop__c);
    }

    @IsTest static void updateSchedule2() {
        List<Schedule__c> schedulesForUpdate = new List<Schedule__c>();

        Bus_Stop__c busStop3 = [
                SELECT Name, Id
                FROM Bus_Stop__c
                WHERE Name = 'Stop_3'
        ];

        Schedule__c scheduleUpdate1 = [
                SELECT Id, Bus_Stop__c, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop3.Id
        ];

        scheduleUpdate1.Time__c = Time.newInstance(1, 5, 0, 0);
        schedulesForUpdate.add(scheduleUpdate1);

        Bus_Stop__c busStop6 = [
                SELECT Name, Id
                FROM Bus_Stop__c
                WHERE Name = 'Stop_6'
        ];
        Schedule__c scheduleUpdate2 = [
                SELECT Id, Bus_Stop__c, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop6.Id
        ];
        scheduleUpdate2.Time__c = Time.newInstance(1, 2, 0, 0);
        schedulesForUpdate.add(scheduleUpdate2);

        Test.startTest();
        update schedulesForUpdate;
        Test.stopTest();

        System.assertEquals(1, [
                SELECT Bus_Stop__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Stop__c = :busStop6.Id
        ].Time_to_Next_Stop__c);
    }
}