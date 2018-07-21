public with sharing class am_ItemCollection implements Comparable{
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          14/7/2017
   *  Modified by:   
   *  Date Modified: 
   *
   *  Description:   A complete colletion of objects related to items.
   *                 
   ***********************************************************************************************/  
 
  @Auraenabled 
  public String itemID {get; set;} 
  @Auraenabled
  public String itemTitle {get; set;}
  @Auraenabled
  public String aggregateItemTitle {get; set;}
  @Auraenabled
  public Progress__c item {get; set;}
  @Auraenabled
  public List<Issue_Item__c> issues {get; set;}
  @Auraenabled
  public List<Item_Component_Use__c> components {get; set;}
  @Auraenabled
  public List<ItemComponentUseAudi__c> audits {get; set;}
  @Auraenabled
  public List<String> buildStages {get; set;}


  public am_ItemCollection() {
  }
  
  public am_ItemCollection(Progress__c aItem) {
    item = aItem; 
    itemID = aItem.Id;
    itemTitle = aItem.Name;
    aggregateItemTitle = aItem.Aggregate_Item__c;
    issues = new List<Issue_Item__c>();
    components = new List<Item_Component_Use__c>();
    audits = new List<ItemComponentUseAudi__c>();
    buildStages = new List<String>();
  }

  
  public Integer compareTo(Object obj) {
     am_ItemCollection compareItem = (am_ItemCollection)(obj);

     if (this.itemTitle > compareItem.itemTitle)
       return 1;
     else if (this.itemTitle == compareItem.itemTitle)
       return 0;
     else
       return -1;
   }
	
}