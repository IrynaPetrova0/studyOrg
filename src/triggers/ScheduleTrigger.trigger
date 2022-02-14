/**
 * Created by iryna.petrova on 12/13/2021.
 */

trigger ScheduleTrigger on Schedule__c (before insert, after insert, before update, after update) {

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                ScheduleTriggerHandler.onBeforeInsert(Trigger.new);
            } else
                    if (Trigger.isUpdate && checkRecursive.runOnce()) {
                ScheduleTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.new);

            }

        } else if (Trigger.isAfter ) {
            if (Trigger.isInsert || Trigger.isUpdate ) {
                System.debug('After');
                ScheduleTriggerHandler.onAfterInsertUpdate(Trigger.new);
            }

        }

}