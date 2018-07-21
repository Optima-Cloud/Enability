public with sharing class am_formReviewIssueAURA {
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
     searchArguments.project = aProject; searchArguments.item = aItem; searchArguments.level = aLevel;
  	 return IssueItemsController.getIssueItems(searchArguments);
   } 
 
   @AuraEnabled 
   public static List<am_BacklogQueueElement> getItemsAndIssues(String aProject, String aItem, String aLevel){ 
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.project = aProject; searchArguments.item = aItem; searchArguments.level = aLevel;
   	 return am_BacklogQueue.getBacklog(searchArguments, 'level');
   }

   @AuraEnabled 
   public static void saveIssueItems(Issue_Item__c[] aIssueItems){
   	  IssueItemsController.saveIssueItems(aIssueItems);
   }

   @AuraEnabled 
   public static void saveItems(String aBacklogElements){ 
     //  deserialize JSON object from lightning due to SF bug which causes list elements to be null
     List<am_BacklogQueueElement> backlogElementsList = (List<am_BacklogQueueElement>)JSON.deserialize(aBacklogElements, List<am_BacklogQueueElement>.class);
     //  get item objects from the backlog list
   	 List<Progress__c> aItems = am_BacklogQueueElement.getItemsFromBacklog(backlogElementsList);
   	 //  save the items
   	 am_Issue.saveItems(aItems); 
   }
}