trigger updateRatesOnProfile on Staff_Profile__c (after insert,after update) {
    //  check trigger only runs once
    if(checkRecursive.runOnce())
      am_StaffProfiles.updateProfileRates();
}