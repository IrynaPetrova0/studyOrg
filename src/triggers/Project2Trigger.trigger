/**
 * Created by iryna.petrova on 12/21/2021.
 */

trigger Project2Trigger on Project2__c (after update) {

    if(Trigger.isBefore){

    }else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Project2Handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}