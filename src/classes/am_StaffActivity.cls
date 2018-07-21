public with sharing class am_StaffActivity {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          5/12/2016 
   *  Modified by: 
   *  Date Modified: 
   *
   *  Description:   Staff Activites track actual staff times against activities
   *            
   ***********************************************************************************************/  
 
  @AuraEnabled 
  public static void updateStaffActivities(List<Staff_Activity__c> aStaffActivities){
    upsert aStaffActivities;
  }  
    
  @AuraEnabled 
  public static void updateStaffActivity(Staff_Activity__c aStaffActivity){
    upsert aStaffActivity;
  }  
    
}