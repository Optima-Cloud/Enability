public class am_ItemExt {
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              19/8/16    
   *  Modified by:      
   *  Date Modified:   
   *
   *  Description:       Handles all aspects of Visualforce pages associated with Items
   *                
   ***********************************************************************************************/  

  private ApexPages.StandardSetController standardSetController;
  private ApexPages.StandardController standardController;
  public Progress__c selectedItem {set; get;} 
  public String selectedItemName {set; get;} 
  public List<Progress__c> selectedItems {set; get;}
  public string sprint  {set; get;}
  private Boolean SetCalled;
  private PageReference retPage;
  
  public am_ItemExt(ApexPages.StandardSetController SetController){
    selectedItems = [SELECT Id, Name, Level__c, Wing__c, Item_Status_New__c, Stage__c, Stage_Type__c, Project__c 
                       FROM Progress__c WHERE id in :SetController.getSelected()];
    if (selectedItems.size() <=0){
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Select at least 1 item on the previous screen');
      ApexPages.addMessage(myMsg);
    }
    
    retPage = SetController.cancel();
    standardSetController = SetController;
    SetCalled = True;
  }  

  public static List<String> getLevels(String aProject){
  	List<Progress__c> listItems = [SELECT Level__c FROM Progress__c WHERE Project__c = :aProject ORDER BY Level__c];
  	Set<String> setLevels = new Set<String>();
  	for (Progress__c p :listItems) {
  	  setLevels.add(p.Level__c);
  	}

  	List<String> listLevels = new List<String>();
  	for (String s :setLevels) {
  	  listLevels.add(s);
  	}

  	return new List<String>(setLevels);
  }
 
  public static List<Progress__c> getItemsLevel(String aProject, String aLevel){
    //  return items for the level that have audit records
    Set<Id> itemIds = new Set<Id>();

  	for (ItemComponentUseAudi__c ids :[SELECT Sprint_Item__r.Item__c, Sprint_Item__r.Item__r.Name 
  	                                   FROM ItemComponentUseAudi__c 
  	                                   WHERE Sprint_Item__r.Item__r.Project__c = :aProject AND Sprint_Item__r.Item__r.Level__c = :aLevel])
  	  itemIds.add(ids.Sprint_Item__r.Item__c);

    return [SELECT Id, Name, Aggregate_Item__c FROM Progress__c WHERE Id IN :itemIds ORDER BY Name]; 

  }
  
  public static List<Progress__c> getItemsAggregateItem(String aAggregateItem){
    //  return items for the level that have audit records
    Set<Id> itemIds = new Set<Id>();

  	for (ItemComponentUseAudi__c ids :[SELECT Sprint_Item__r.Item__c, Sprint_Item__r.Item__r.Name 
  	                                   FROM ItemComponentUseAudi__c 
  	                                   WHERE Sprint_Item__r.Item__r.Aggregate_Item__c = :aAggregateItem])
  	  itemIds.add(ids.Sprint_Item__r.Item__c);

    return [SELECT Id, Name, Aggregate_Item__c FROM Progress__c WHERE Id IN :itemIds ORDER BY Name]; 

  }
  
   public static List<String> getAggregateItems(am_UniversalSearchArguments aSearchArguments){
     Set<String> aggItems = new Set<String>();
     List<Progress__c> items;
    if (String.isNotBlank(aSearchArguments.sprint)){
      items = am_SprintItemExt.getItemsInSprint(aSearchArguments.sprint);
    } else if (String.isNotBlank(aSearchArguments.project)){
      if (String.isNotBlank(aSearchArguments.level)){
        items = getItemsLevel(aSearchArguments.project, aSearchArguments.level);
      } else
        items = am_SprintItemExt.getItemsProject(aSearchArguments.project);     
    } 

   	 for (Progress__c p : items)
   	   aggItems.add(p.Aggregate_Item__c);
   	 return new List<String>(aggItems);
   }
  
 
  public am_ItemExt(ApexPages.StandardController SController){
    string s = ApexPages.currentPage().getParameters().get('recs');
    selectedItem = [SELECT Id, Name, Level__c, Wing__c, Item_Status_New__c, Stage__c, Stage_Type__c, Project__c 
                    FROM Progress__c WHERE id = :SController.getId()];
    selectedItemName = [SELECT Name FROM Progress__c WHERE Id = :selectedItem.Id LIMIT 1].Name;
    retPage = SController.cancel();
    selectedItems = new List<Progress__c>();
    selectedItems.add(selectedItem);
    standardController = SController;
    SetCalled = False; 
  } 
  
  public PageReference pageHandler(){
    //  Provide function to direct all page actions
    String callAction = ApexPages.CurrentPage().getParameters().get('callAction');
    if (callAction == 'addSprintItems')
      am_Sprint.addSprintItems(selectedItems, sprint);
    return retPage;
  } 

  
  public List<SelectOption> getSprintList(){
    //  returns a list of the last months project sprints associated with the items selected
    List<Sprint__c> sprintList;
    if (selectedItems.size() >0)
      sprintList =  [SELECT Id, Name FROM Sprint__c WHERE Project__c = :selectedItems[0].Project__c
                     AND Date_Start__c > :(system.Today()-121) Order BY Sequence__c ];
    else 
        sprintList =  [SELECT Id, Name FROM Sprint__c Where Date_Start__c > :(system.Today()-31) Order by Sequence__c ];
        
    List<SelectOption> SprintOptionList = new List<SelectOption>();
    SprintOptionList.add(new SelectOption( ' ' ,'---Select Sprint from list---'));
    for(Sprint__c s : sprintList ){
      SprintOptionList.add(new SelectOption(s.Id , s.Name));
    }
    return SprintOptionList ;
  }    
}