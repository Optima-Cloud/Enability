public with sharing class am_BacklogQueueAURA {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          1/11/2016
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles all requests to salesforce from BacklogQueue component.
   *                 
   ***********************************************************************************************/  
   @AuraEnabled 
   public static List<am_BacklogQueueElement> getBacklogQueueData(String aProject, String aSprint, String aItem, String aLevel){
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.level = aLevel;
     searchArguments.item = aItem; 
     searchArguments.sprint = aSprint;
     searchArguments.project = aProject; 
   	 return am_BacklogQueue.getBacklog(searchArguments, 'audits');
   } 

   @AuraEnabled 
  public static Map<String, List<am_BacklogQueueElement>> getAggBacklogQueueData(String aProject, String aSprint, String aItem, String aLevel){ 
     //  returns a map of Backlogs by Item to enable grouping on form
     List<am_BacklogQueueElement> backlogs = getBacklogQueueData(aProject, aSprint, aItem, aLevel);
     Map<String, List<am_BacklogQueueElement>> sortedBacklogs = new Map<String, List<am_BacklogQueueElement>>();
     for (am_BacklogQueueElement bl : backlogs){
       if(sortedBacklogs.containsKey(bl.aggregateItemTitle)){
         // add the backlog element to an existing audit list
         sortedBacklogs.get(bl.aggregateItemTitle).add(bl);
       } else {
         //  add the item key and list of backlog elements 
         List<am_BacklogQueueElement> newList = new List<am_BacklogQueueElement>(); 
         newList.add(bl); 
         sortedBacklogs.put(bl.aggregateItemTitle, newList);
       }
     }
     return sortedBacklogs; 
   }

   @AuraEnabled 
   public static List<Project__c> getProjects(){
   	  return am_ProjectExt.getProjects();
   }
   
   @AuraEnabled 
   public static void addItemToSprint(String aSelectedItems, String aSprint){
     //  work around for bug in apex parameter passing
     List<String> selectedItems = (List<String>) system.JSON.deserialize(String.valueOf(aSelectedItems), List<String>.class);
     am_Sprint.addSprintItems(selectedItems, aSprint);
   } 
}