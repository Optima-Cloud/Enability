trigger Upsert_Manning_Schedules_Staff on Staff__c (before update) {
  if (!test.isRunningTest()) 
    Manning_schedule.Upsert_Manning_Schedules();

}