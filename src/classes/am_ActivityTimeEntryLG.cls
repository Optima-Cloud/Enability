public with sharing class am_ActivityTimeEntryLG {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          20/11/2016
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles all requests to salesforce from Activity Time Entry component.
   *                 
   ***********************************************************************************************/  
   @AuraEnabled 
   public static List<Project__c> getProjects(){
   	  return am_ProjectExt.getProjects();
   }
    
   @AuraEnabled 
   public static List<Sprint__c> getSprints(String aProject){
   	  return am_Sprint.getSprints(aProject);
   }

   @AuraEnabled 
   public static List<Sprint_Items__c> getItems(String aSprint){
   	  return am_SprintItemExt.getItems(aSprint);
   }

   @AuraEnabled 
   public static List<Activity__c> getActivities(Id aItem, Id aSprint){
   	  return am_Activity.getActivities(aItem, aSprint);
   }
   
   @AuraEnabled 
   public static Activity__c getActivity(String aActivityId){
   	  return am_Activity.getActivity(aActivityId);
   }
   
   @AuraEnabled 
   public static List<Staff__c> getStaff(){
   	  return am_Staff.getStaff();
   }

   @AuraEnabled 
   public static void updateStaffActivities(Staff_Activity__c[] aStaffActivities){
     List<Staff_Activity__c> tempSAs = new List<Staff_Activity__c>();
     for (Staff_Activity__c sa :aStaffActivities){
        Staff_Activity__c tempSA = new Staff_Activity__c();
        tempSA = sa;
     	tempSAs.add(tempSA);
     }
   	  am_StaffActivity.updateStaffActivities(tempSAs);
   }

   @AuraEnabled 
   public static void updateStaffActivity(Staff_Activity__c aStaffActivity){
   	  am_StaffActivity.updateStaffActivity(aStaffActivity);
   }
}