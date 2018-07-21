public with sharing class am_SprintReviewAURA {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          1/11/2016
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles all requests to salesforce from SprintReview component.
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
   public static List<String> getLevels(String aProject){
   	  return am_ItemExt.getLevels(aProject);
   }

   @AuraEnabled 
   public static List<Sprint_Items__c> getItems(String aSprint){
   	  return am_SprintItemExt.getItems(aSprint);
   }

   @AuraEnabled 
   public static List<Sprint_Items__c> getItemsSprint(String aSprint){
   	  return am_SprintItemExt.getItemsSprint(aSprint);
   }

   @AuraEnabled 
   public static List<Progress__c> getItemsLevel(String aProject, String aLevel){
   	  return am_ItemExt.getItemsLevel(aProject, aLevel);
   }

   @AuraEnabled 
   public static List<Progress__c> getItemsAggregateItem(String aAggregateItem){
   	  return am_ItemExt.getItemsAggregateItem(aAggregateItem); 
   }

   @AuraEnabled 
   public static List<Issue__c> getIssues(String aProject){ 
   	  return IssuesController.getIssues(aProject);
   }

   @AuraEnabled 
   public static List<Progress__c> getItemsProject(String aProject){
   	  return am_SprintItemExt.getItemsProject(aProject);
   }

   @AuraEnabled 
   public static List<String> getAggregateItems(String aProject, String aLevel, String aSprint){
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.project = aProject; 
     searchArguments.level = aLevel; 
     searchArguments.sprint = aSprint;

  	 return am_ItemExt.getAggregateItems(searchArguments); 
   }

   @AuraEnabled 
   public static List<ItemComponentUseAudi__c> getItemComponentAudits(String aItem, String aSprint, String aProject, String aAggregateItem){ 
     //  returns a list of Audits by Item to enable grouping on form
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.item = aItem; 
     searchArguments.sprint = aSprint;
     searchArguments.aggregateItem = aAggregateItem;
     searchArguments.project = aProject; 
     return am_ItemComponentUseExt.getItemComponentAuditUses(searchArguments); 
   }

   @AuraEnabled 
   public static Map<String, am_ItemCollection> getAggItemComponentAudits(String aItem, String aSprint, String aProject, String aAggregateItem){ 
     //  returns a map of Audits by Item to enable grouping on form
     Map<String, am_ItemCollection> mapItemCollections = new Map<String, am_ItemCollection>();
     Map<String, Progress__c> mapItems = new Map<String, Progress__c>();
     List<Id> ids = new List<Id>();     
     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments(aAggregateItem, aItem, aSprint, aProject); 

     //  load map with items
  	 for (Progress__c i : am_Item.getItems(searchArguments, ids)){
       Progress__c temp = new Progress__c();
       temp = i;
       mapItems.put(i.Name, temp);
     }

     for (ItemComponentUseAudi__c ic : am_ItemComponentUseExt.getItemComponentAuditUses(searchArguments)){
       if(mapItemCollections.containsKey(ic.Item_Component_Use__r.Item__r.Name)){
         // add the audit to an existing itemCollection list 
         mapItemCollections.get(ic.Item_Component_Use__r.Item__r.Name).audits.add(ic);
       } else { 
         //  add the item key and item list audits 
         am_ItemCollection newItemCollection = new am_ItemCollection(mapItems.get(ic.Item_Component_Use__r.Item__r.Name)); 
         List<ItemComponentUseAudi__c> newList = new List<ItemComponentUseAudi__c>(); 
         newList.add(ic);
         newItemCollection.audits = newList;
          
         mapItemCollections.put(ic.Item_Component_Use__r.Item__r.Name, newItemCollection);
       }
     }
     
   	 //  get unresolved issue items 
  	 for (Issue_Item__c ii : am_IssueItem.getIssueItemsOpen(searchArguments)){
       if(mapItemCollections.containsKey(ii.Item__r.Name)){
         // add the issue item to an existing itemCollection list 
         mapItemCollections.get(ii.Item__r.Name).issues.add(ii);
       } else { 
         //  add the item key and issue item list  
//         am_ItemCollection newItemCollection = new am_ItemCollection(); 
//         List<Issue_Item__c> newList = new List<Issue_Item__c>(); 
//         newList.add(ii);
//         newItemCollection.Issues = newList;
          
//         mapItemCollections.put(ii.Item__r.Name, newItemCollection);
       }
     }

     
     //  get build stages for item
     for (String key :mapItemCollections.keySet()){       
       mapItemCollections.get(key).buildStages = am_Stage.getRecordTypeStageNames(mapItemCollections.get(key).item.Record_Type_Description__c); 
     }
     return mapItemCollections;     
   }

   @AuraEnabled 
   public static List<String> getIssueTypes(){
   	  return IssuesController.getPickValues(new Issue__c(), 'Type__c');
   }

   @AuraEnabled 
   public static void saveItemData(List<Progress__c> aSelectedItems){
   	  am_Item.saveItems(aSelectedItems); 
   	  system.debug('aSelectedItems = ' + aSelectedItems);
   }

   @AuraEnabled 
   public static void saveItemComponentAudits(ItemComponentUseAudi__c[] aSelectedItemComponentUseAudits){
   	  am_ItemComponentUseExt.saveItemComponentAudits(aSelectedItemComponentUseAudits); 
   }

   @AuraEnabled
   public static String getUserName() { 
     return userinfo.getName();
  }
   
   @AuraEnabled 
   public static void createIssue(String aIssue, Id aItemId, List<Id> aIssueRelatedTo) {
     //  work around for bug in apex parameter passing
     Issue__c selectedIssue = (Issue__c) system.JSON.deserialize(aIssue, Issue__c.class);
     //  determine if related to existing issue or new issue entered in the issue form
     if (String.isNotBlank(selectedIssue.Title__c)){
       //  create new issue and issue item	
       am_Issue.createIssue(selectedIssue);
       am_IssueItem.createItemIssueFromIssue(aItemId, selectedIssue);
     }
     if (aIssueRelatedTo.size() != 0){
       //  create new issue item to link to existing issue(s)
       List<Issue__c> itemList = [SELECT Id, Description__c, Project__c, Title__c FROM Issue__c WHERE Id = :aIssueRelatedTo];
       for (Issue__c item :itemList){
         am_IssueItem.createItemIssueFromIssue(aItemId, item);
       }
     }     
   }    
}