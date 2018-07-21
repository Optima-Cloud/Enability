trigger Upsert_Manning_Schedules on Staff_Cost_Constants__c (after update) {

  if (!test.isRunningTest()) 
    Manning_schedule.Upsert_Manning_Schedules();
}