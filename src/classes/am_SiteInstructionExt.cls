public with sharing class am_SiteInstructionExt {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          23/2/2017 
   *  Modified by:   David Strangward
   *  Date Modified: 
   *                 Add method to get Staff Activities, Item Details, Variation details
   *  Description:   Handles .
   *            
   ***********************************************************************************************/  
    public Progress__c selectedItem {set; get;} 
    public Issue_Item__c selectedIssueItem {set; get;} 
    public List<Staff_Activity__c> selectedStaffActivities {set; get;}
    public Boolean initialised{get; set;}
    public String todaysDate{get; set;}

     
    public am_SiteInstructionExt(ApexPages.StandardController Controller){
        selectedIssueItem = [SELECT Id, Issue_Notifications__r.Name
                         FROM Issue_Item__c where Item__c = :Controller.getId()];
 
        selectedItem = [SELECT Name, Id, Project__r.Name, Material_Used__c,
                         Comment__c, Project__r.Role_Site_Supervisor__r.Name
                         FROM Progress__c where id = :Controller.getId()];

        selectedStaffActivities = [SELECT Activity__c, Staff__r.Name, Time_Worked__c, Description__c, Date__c, Approved_Status__c
                                  FROM Staff_Activity__c 
                                  WHERE Approved_Status__c = false AND
                                  Activity__c IN (SELECT Id FROM Activity__c WHERE Item__c = :selectedItem.Id)];
       initialised=false;
       todaysDate = system.today().format();
     }
    
     public void updateStaffActivityStatus(){
       if (!initialised){
	     List<Staff_Activity__c> tempStaffActivities  = new List<Staff_Activity__c>();
         for(Staff_Activity__c sas: selectedStaffActivities){
           Staff_Activity__c sa = new Staff_Activity__c();
           sa = sas;
           sa.Approved_Date__c = system.today();
           sa.Approved_Status__c = true;
           tempStaffActivities.add(sa);
         }
         am_StaffActivity.updateStaffActivities(tempStaffActivities);
         initialised=true;
         
       }
     }
     
}