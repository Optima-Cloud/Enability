trigger Upsert_Manning_Schedules_Days on Project_Days_Off__c (after update) {
    if (!test.isRunningTest())
      Manning_schedule.Upsert_Manning_Schedules();
}