trigger am_updateHoursUsed on Sprint__c (after update) {
  //  check trigger only runs once
  if(checkRecursive.runOnce())
    am_Project_Progress.updateProjectHoursUsed(trigger.new[0]);
}