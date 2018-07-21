public with sharing class am_IssueItemExtLG {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          16/05/2017
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles all requests to salesforce from formReviewIssue lightning component.
   *                 
   ***********************************************************************************************/  
   @AuraEnabled 
   public static List<Issue_Item__c> getIssueItems(String aProject, String aItem, String aLevel){ 
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.level = aLevel;
     searchArguments.item = aItem; 
     searchArguments.project = aProject; 
   	  return IssueItemsController.getIssueItems(searchArguments);
   }

   @AuraEnabled 
   public static void saveIssueItems(Issue_Item__c[] aIssueItems){
   	  IssueItemsController.saveIssueItems(aIssueItems);
   }
    
}