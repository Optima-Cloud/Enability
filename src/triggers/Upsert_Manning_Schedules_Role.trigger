trigger Upsert_Manning_Schedules_Role on Project_Role__c (after update) {
  if (!test.isRunningTest()) 
    Manning_schedule.Upsert_Manning_Schedules();
}