public with sharing class am_Item {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          28/5/2017 
   *  Modified by:    
   *  Date Modified: 
   * 
   *  Description:   Handles business logic for items (progress__c).
   *            
   ***********************************************************************************************/  
  
  public static List<Progress__c> getItems(am_UniversalSearchArguments aSearchArguments, List<Id> aItemsExcluded){
  	//  gets items for specified components and excludes items if specified 
    List<Progress__c> listItems = new List<Progress__c>(); 

    String searchQuery; 
    String andQuery = '';
    String sid;
    Id qid;
    if (aItemsExcluded.size() > 0)
      andQuery = 'AND Id NOT IN :aItemsExcluded';
    
    if (String.isNotBlank(aSearchArguments.aggregateItem)){
        sid = aSearchArguments.aggregateItem;
        searchQuery = 'Aggregate_Item__c = :sid ';
    } else if (String.isNotBlank(aSearchArguments.item)) {
    	qid = aSearchArguments.itemId;
      searchQuery = 'Id = :qid ';
    } else if (String.isNotBlank(aSearchArguments.sprint)) { 
    	qid = aSearchArguments.sprintId;
      searchQuery = 'Id IN (SELECT Item__c FROM Sprint_Items__c WHERE Sprint__c = :qid) ';
    } else if (String.isNotBlank(aSearchArguments.project)){
    	qid = aSearchArguments.projectId;
      searchQuery = 'Project__c = :qid ';
      if (String.isNotBlank(aSearchArguments.level)){ 
      	sid = aSearchArguments.level;
        searchQuery = 'Project__c = :qid AND Level__c = :sid ';
      }    
    }
    
    //  query database
    if (String.isNotBlank(searchQuery)){
      String query = 'SELECT Id, Name, Stage__c, Build_Stage__c, Build_Stage_Index__c, Record_Type_Description__c, Aggregate_Item__c ' + 
      'FROM Progress__c WHERE ' + searchQuery + andQuery;
      listItems = Database.query(query); 
    } 
 
    return listItems; 
  }   

  public static List<Progress__c> getItems(List<String> aSelectedItems){
  	//  gets items for specified components and excludes items if specified
    List<Progress__c> listItems = new List<Progress__c>();
    List<Id> itemIds = new List<Id>();
    
    for (String s :aSelectedItems)
      itemIds.add(Id.ValueOf(s));
    
    listItems = [SELECT Id, Name, Stage__c, Item_Status_New__c, Stage_Type__c FROM Progress__c WHERE Id IN :itemIds];
  
    return listItems; 
  }   

  public static void saveItems(List<Progress__c> aSelectedItems){
    try {
    	update aSelectedItems;
    } catch (DMLException e) {
    	
    }
  }
  
  public static void updateStageIndex(List<Progress__c> aCurrentItems){
    //  get the Item Stage and Build Stage and updates the index
    for (integer i=0; i<aCurrentItems.size(); i++){
      aCurrentItems[i].Build_Stage_Index__c = am_Stage.getStageIndex(aCurrentItems[i].Record_Type_Description__c, aCurrentItems[i].Build_Stage__c);
      aCurrentItems[i].Stage_Index__c = am_Stage.getStageIndex(aCurrentItems[i].Record_Type_Description__c, aCurrentItems[i].Stage__c);
    }  
  } 
    
}