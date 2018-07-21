trigger Upsert_Manning_Schedules_Project on Project__c (after update) {
    if(checkRecursive.runOnce())
      if (!test.isRunningTest()){
        system.debug('Upsert_Manning_Schedules_Project test.isRunningTest()' + test.isRunningTest());
        Manning_schedule.Upsert_Manning_Schedules();
      }
}