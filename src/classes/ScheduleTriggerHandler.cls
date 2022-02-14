/**
 * Created by iryna.petrova on 12/13/2021.
 */

public with sharing class ScheduleTriggerHandler {

    public static void onAfterInsertUpdate(List<Schedule__c> newSchedules) {

        Set<Id> busRoutesIds = new Set<Id>();

        for (Schedule__c schedule : newSchedules) {
            busRoutesIds.add(schedule.Bus_Route__c);
        }

        Map<Id, Schedule__c> allSchedules = new Map<Id, Schedule__c>([
                SELECT Id, Bus_Route__c, Bus_Stop__c, Time__c
                FROM Schedule__c
                WHERE Bus_Route__c IN :busRoutesIds
                ORDER BY Time__c
        ]);
        System.debug(allSchedules);

        Map<Id, List<Schedule__c>> routesToSchedules = new Map<Id, List<Schedule__c>>();

        for (Id scheduleId : allSchedules.keySet()) {
            if (routesToSchedules.containsKey(allSchedules.get(scheduleId).Bus_Route__c)) {
                routesToSchedules.get(allSchedules.get(scheduleId).Bus_Route__c).add(allSchedules.get(scheduleId));
            } else {
                routesToSchedules.put(allSchedules.get(scheduleId).Bus_Route__c, new List<Schedule__c>{
                        allSchedules.get(scheduleId)
                });
            }
        }
        System.debug('Routes to schedules: '+routesToSchedules);


        List<Bus_Route__c> busRoutesUpd = new List<Bus_Route__c>();

        for (Id busRouteId : busRoutesIds) {
            Bus_Route__c busRoute = new Bus_Route__c(Id = busRouteId);
            busRoute.Start_Time__c = routesToSchedules.get(busRouteId).get(0).Time__c;
            busRoute.End_Time__c =
                    routesToSchedules.get(busRouteId).get(routesToSchedules.get(busRouteId).size() - 1).Time__c;
            busRoutesUpd.add(busRoute);
        }

        try {
            update busRoutesUpd;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static void onBeforeInsert(List<Schedule__c> newSchedules) {
        Set<Id> busRoutes = new Set<Id>();

        for (Schedule__c schedule : newSchedules) {
            busRoutes.add(schedule.Bus_Route__c);
        }

        Map<Id, Schedule__c> allSchedules = new Map<Id, Schedule__c>([
                SELECT Id, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Route__c IN:busRoutes
                ORDER BY Time__c
        ]);

        Map<Id, List<Schedule__c>> routesToSchedules = new Map<Id, List<Schedule__c>>();
        Map<Id, List<Schedule__c>> newRoutesToSchedules = new Map<Id, List<Schedule__c>>();
//        System.debug(allSchedules);

        if (!allSchedules.isEmpty()) {
            for (Id scheduleId : allSchedules.keySet()) {
                if (routesToSchedules.containsKey(allSchedules.get(scheduleId).Bus_Route__c)) {
                    routesToSchedules.get(allSchedules.get(scheduleId).Bus_Route__c).add(allSchedules.get(scheduleId));
                } else {
                    routesToSchedules.put(allSchedules.get(scheduleId).Bus_Route__c, new List<Schedule__c>{
                            allSchedules.get(scheduleId)
                    });
                }
            }
        }else{
            for (Schedule__c schedule : newSchedules) {
                if (newRoutesToSchedules.containsKey(schedule.Bus_Route__c)) {
                    newRoutesToSchedules.get(schedule.Bus_Route__c).add(schedule);
                } else {
                    newRoutesToSchedules.put(schedule.Bus_Route__c, new List<Schedule__c>{
                            schedule
                    });
//                    System.debug('new map element created');
                }
            }
        }
//        System.debug(newRoutesToSchedules);
//        System.debug(newSchedules);

        for(Schedule__c schedule : newSchedules){ //what if insert 3_10 and 3_20
            if(routesToSchedules.containsKey(schedule.Bus_Route__c)){
                for (Schedule__c scheduleFromList : routesToSchedules.get(schedule.Bus_Route__c)) {
                    if (schedule.Time__c < scheduleFromList.Time__c) {
                        schedule.Time_to_Next_Stop__c = 60 * (scheduleFromList.Time__c.hour() - schedule.Time__c.hour()) +
                                scheduleFromList.Time__c.minute() - schedule.Time__c.minute();
                        break;
                    } else {
                        schedule.Time_to_Next_Stop__c = null;
                    }
                }
            }else {
                List<Schedule__c> schedulesList = newRoutesToSchedules.get(schedule.Bus_Route__c);
                for (Integer i = 0; i < schedulesList.size(); i++){
                    List<Integer> timeToNext = new List<Integer>();
                    for(Integer j = 0; j < schedulesList.size(); j++){
                        timeToNext.add(60 * (schedulesList[j].Time__c.hour() - schedulesList[i].Time__c.hour()) +
                                schedulesList[j].Time__c.minute() - schedulesList[i].Time__c.minute());
                    }
                    timeToNext.sort();
//                    System.debug(timeToNext);
                    for(Integer numberMinutes: timeToNext){
                        if(numberMinutes > 0){
                            schedulesList[i].Time_to_Next_Stop__c = numberMinutes;
//                            System.debug(schedulesList[i].Time__c + ' ' + schedulesList[i].Time_to_Next_Stop__c);
                            break;
                        }
                    }
                }
            }
        }
    }

    public static void onBeforeUpdate(Map<Id, Schedule__c> oldSchedules, List<Schedule__c> newSchedules) {

        Set<Id> busRoutesIds = new Set<Id>();
        for (Id scheduleId : oldSchedules.keySet()) {
            busRoutesIds.add(oldSchedules.get(scheduleId).Bus_Route__c);
        }

        List<Schedule__c> allSchedules = new List<Schedule__c>([
                SELECT Id, Bus_Route__c, Time__c, Time_to_Next_Stop__c
                FROM Schedule__c
                WHERE Bus_Route__c IN:busRoutesIds
                ORDER BY Time__c
        ]);

        Map<Id, List<Schedule__c>> routesToSchedules = new Map<Id, List<Schedule__c>>();

        for (Schedule__c schedule : allSchedules) {
            if (routesToSchedules.containsKey(schedule.Bus_Route__c)) {
                routesToSchedules.get(schedule.Bus_Route__c).add(schedule);
            } else {
                routesToSchedules.put(schedule.Bus_Route__c, new List<Schedule__c>{
                        schedule
                });
            }
        }
        Map<Id, Schedule__c> schedulesForUpdate = new Map<Id, Schedule__c>();

        for (Id scheduleId : oldSchedules.keySet()) {
            List<Schedule__c> schedulesList = routesToSchedules.get(oldSchedules.get(scheduleId).Bus_Route__c);
            for (Integer i = 0; i < schedulesList.size(); i++) {
                if (schedulesList.get(i).Id == scheduleId) {
                    if (i > 0 && i < schedulesList.size() - 1) {
                        schedulesList.get(i - 1).Time_to_Next_Stop__c =
                                60 * (schedulesList.get(i + 1).Time__c.hour() - schedulesList.get(i - 1).Time__c.hour()) +
                                        schedulesList.get(i + 1).Time__c.minute() - schedulesList.get(i - 1).Time__c.minute();
                        schedulesForUpdate.put(schedulesList.get(i - 1).Id, schedulesList.get(i - 1));
                        schedulesList.remove(i);
                    } else if (i == schedulesList.size() - 1) {
                        schedulesList.get(i - 1).Time_to_Next_Stop__c = null;
                        schedulesForUpdate.put(schedulesList.get(i - 1).Id, schedulesList.get(i - 1));
                        schedulesList.remove(i);
                    }
                    break;
                }
            }
        }
        System.debug(schedulesForUpdate);

        for (Schedule__c schedule : newSchedules) {
            List<Schedule__c> schedulesList = routesToSchedules.get(schedule.Bus_Route__c);
            System.debug(schedulesList);
            for (Integer i = 0; i < schedulesList.size(); i++) {
                if (schedule.Time__c < schedulesList.get(i).Time__c) {
//                    System.debug('uslow');
//                    System.debug(schedulesList.size());
//                    System.debug(i > 0);
//                    System.debug(i < schedulesList.size());
                    if (i == 0) {
//                        System.debug('if(i==0)');
                        schedule.Time_to_Next_Stop__c = 60 * (schedulesList.get(i).Time__c.hour() - schedule.Time__c.hour()) +
                                schedulesList.get(i).Time__c.minute() - schedule.Time__c.minute();


                    } else if (i > 0 && i < schedulesList.size()) {
//                        System.debug('else >0 < size -1 ');
                        schedule.Time_to_Next_Stop__c = 60 * (schedulesList.get(i).Time__c.hour() - schedule.Time__c.hour()) +
                                schedulesList.get(i).Time__c.minute() - schedule.Time__c.minute();
                        schedulesList.get(i - 1).Time_to_Next_Stop__c = 60 * (schedule.Time__c.hour() - schedulesList.get(i - 1).Time__c.hour()) +
                                schedule.Time__c.minute() - schedulesList.get(i - 1).Time__c.minute();
                        schedulesForUpdate.put(schedulesList.get(i - 1).Id, schedulesList.get(i - 1));

                    }
                    break;
                } else if (schedule.Time__c > schedulesList.get(schedulesList.size() - 1).Time__c) {
//                    System.debug('konets');
                    schedule.Time_to_Next_Stop__c = null;
                    schedulesList.get(schedulesList.size() - 1).Time_to_Next_Stop__c =
                            60 * (schedule.Time__c.hour() - schedulesList.get(schedulesList.size() - 1).Time__c.hour()) +
                            schedule.Time__c.minute() - schedulesList.get(schedulesList.size() - 1).Time__c.minute();
                    schedulesForUpdate.put(schedulesList.get(schedulesList.size() - 1).Id, schedulesList.get(schedulesList.size() - 1));
                    break;
                }
            }
        }
        System.debug(schedulesForUpdate);


        try {
            update schedulesForUpdate.values();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }


    }
}