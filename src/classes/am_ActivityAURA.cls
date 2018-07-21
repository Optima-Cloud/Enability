public with sharing class am_ActivityAURA {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          1/7/2017 
   *  Modified by: 
   *  Date Modified:  
   *
   *  Description:   Handles all the activity interface methods from AURA components
   *            
   ***********************************************************************************************/  
  @AuraEnabled 
  public static List<Activity__c> getActivities(Id aItem, Id aSprint){
    return am_Activity.getActivities(aItem, aSprint);
  }

  @AuraEnabled 
  public static Activity__c getActivity(String aActivityId){
    return am_Activity.getActivity(aActivityId);
  }  
    
}