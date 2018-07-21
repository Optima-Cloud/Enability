public with sharing class am_BacklogQueueElement implements Comparable{
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          24/5/2017
   *  Modified by:   
   *  Date Modified: 
   *
   *  Description:   Handles everything related to elements of backlog queue.
   *                 
   ***********************************************************************************************/  

  @Auraenabled
  public String itemID {get; set;} 
  @Auraenabled
  public String itemTitle {get; set;}
  @Auraenabled
  public String aggregateItemTitle {get; set;}
  @Auraenabled
  public String componentTitle {get; set;} 
  @Auraenabled
  public List<String> issueTitle {get; set;}
  @Auraenabled
  public List<Issue_Item__c> issue {get; set;}
  @Auraenabled
  public Decimal numberStarted {get; set;}
  @Auraenabled
  public Decimal numberFinished {get; set;}
  @Auraenabled
  public Decimal numberIncomplete {get; set;}
  @Auraenabled
  public Decimal quantity {get; set;}
  @Auraenabled
  public String lastStage {get; set;}
  @Auraenabled
  public String buildStage {get; set;}
  @Auraenabled
  public List<String> buildStages {get; set;}

  public am_BacklogQueueElement(ItemComponentUseAudi__c aAudit) {
    itemID = aAudit.Item_Component_Use__r.Item__c; 
  	itemTitle = aAudit.Item_Component_Use__r.Item__r.Name;
    aggregateItemTitle = aAudit.Item_Component_Use__r.Item__r.Aggregate_Item__c;
  	componentTitle = aAudit.Item_Component_Name__c;
	numberIncomplete = aAudit.Quantity_Remaining__c;
  	numberStarted = aAudit.Number_Started__c;
  	numberFinished = aAudit.Number_Finished__c;
  	quantity = aAudit.Quantity__c;
	  lastStage = aAudit.Stage__c;
	  buildStage = aAudit.Item_Component_Use__r.Item__r.Build_Stage__c; 
  	issueTitle = new List<String>();
	  issue = new List<Issue_Item__c>();	
	  buildStages = am_Stage.getRecordTypeStageNames(aAudit.Item_Component_Use__r.Item__r.Record_Type_Description__c); 
  }
	
  public am_BacklogQueueElement(Item_Component_Use__c aUse) {
  	itemID = aUse.Item__c; 
  	itemTitle = aUse.Item__r.Name; 
    aggregateItemTitle = aUse.Item__r.Aggregate_Item__c;
	componentTitle = aUse.Item_Component__r.Name;
	numberStarted = aUse.Number_Started__c;
	numberFinished = aUse.Number_Finished__c;
	quantity = aUse.Quantity__c;
	lastStage = aUse.Stage__c;
	buildStage = aUse.Item__r.Build_Stage__c; 
	issueTitle = new List<String>();
	issue = new List<Issue_Item__c>();	
	buildStages = am_Stage.getRecordTypeStageNames(aUse.Item__r.Record_Type_Description__c); 
  }

  public am_BacklogQueueElement(Progress__c aItem) {
  	itemID = aItem.Id; 
	itemTitle = aItem.Name;
  	issueTitle = new List<String>();
    aggregateItemTitle = aItem.Aggregate_Item__c;
	issue = new List<Issue_Item__c>();	
	lastStage = aItem.Stage__c;
	buildStage = aItem.Build_Stage__c;
	buildStages = am_Stage.getRecordTypeStageNames(aItem.Record_Type_Description__c); 
  }
  
   public Integer compareTo(Object obj) {
     am_BacklogQueueElement queueItem = (am_BacklogQueueElement)(obj);

     if (this.itemTitle > queueItem.itemTitle)
       return 1;
     else if (this.itemTitle == queueItem.itemTitle)
       return 0;
     else
       return -1;
   }
   
   public static List<Progress__c> getItemsFromBacklog(List<am_BacklogQueueElement> aBacklogElements){
     //  returns the items in the backlog queue as item objects
   	 List<Progress__c> items = new List<Progress__c>();
   	 for (am_BacklogQueueElement bq : aBacklogElements){
   	 	 Progress__c newItem = new Progress__c();
   	 	 newItem.Id = bq.itemID;
   	 	 newItem.Build_Stage__c = bq.buildStage;
   	 	 items.add(newItem);   	 	   	 	
   	 }
   	 return items;
   }
}