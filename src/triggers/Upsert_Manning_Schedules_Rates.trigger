trigger Upsert_Manning_Schedules_Rates on RateandAllowance__c (after update) {
  if (!test.isRunningTest()) 
    Manning_schedule.Upsert_Manning_Schedules();

}