public class am_ItemComponentUseExt { 
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          2/6/2016 
   *  Modified by:   David Strangward
   *  Date Modified: 23/4/17
   * 
   *  Description:   Fills out dropdown to select item for the sprint.
   *            
   ***********************************************************************************************/  
     
  public List<Item_Component_Use__c> selectedItemComponentUses {set; get;}
  public List<ItemComponentUseAudi__c> selectedItemComponentUseAudits {set; get;}
  public List<sprintItemWrap> sprintItemsWrapper {get; set;}
  public String item {set; get;}
  public String sprint {set; get;}
  public String sprintName {set; get;}
  public String callAction {set; get;}
  private ApexPages.StandardController standardController;
  private ApexPages.StandardSetController standardSetController;
  public Boolean SetCalled;
  private PageReference retPage;
  
    
  public am_ItemComponentUseExt(ApexPages.StandardController Controller){
    sprint = Controller.getRecord().Id;
    sprintName = [SELECT Name FROM Sprint__c WHERE Id = :sprint LIMIT 1].Name;
    loadSprintItemsWrap();
    standardController = Controller;
    retPage = Controller.cancel();
    SetCalled = False;
  }  

  public am_ItemComponentUseExt(ApexPages.StandardSetController SetController){
    sprint = ApexPages.currentPage().getParameters().get('id');
    standardSetController = SetController;
    loadSprintItemsWrap();
    retPage = SetController.cancel();
    SetCalled = True;
  }

  public class sprintItemWrap {
	public Sprint_Items__c sprintItem {get; set;} 
	public Boolean selected {
		get; 
		set { selected = value; }
	}

	//This is the contructor method. 
	public sprintItemWrap(Sprint_Items__c i) {
	  sprintItem = i;
	  selected = false;
	}
	
	public sprintItemWrap() {
	  selected = false;
	} 
  }

  public PageReference pageOnLoad(){
    if (SetCalled == True)
       return standardSetController.save();   
    else
      return standardController.save(); 
  }
 

  @AuraEnabled 
  public static List<ItemComponentUseAudi__c> getItemComponentAuditUses(am_UniversalSearchArguments aSearchArguments){ 
    return am_ItemComponentUseAudit.getItemComponentAuditUsesSprint(aSearchArguments);
/*  moved to audits
    //  gets the list of ItemComponentAudits once an item is selected in the dropdown item list
    List<ItemComponentUseAudi__c> listAudits = new List<ItemComponentUseAudi__c>();
    List<ItemComponentUseAudi__c> returnAudits = new List<ItemComponentUseAudi__c>();
    Boolean sprintAuditGroup;
    String query;
    String whereClause;
    String sid;
    Id qid; Id iid;

    if (String.isNotBlank(aSearchArguments.sprint) && String.isNotBlank(aSearchArguments.itemId)){
      sprintAuditGroup = true;
      qid = aSearchArguments.sprintId;
      iid = aSearchArguments.itemId;
      whereClause = 'WHERE Sprint_Item__r.Item__c = :iid AND Sprint__c = :qid ';
  	} else if (String.isNotBlank(aSearchArguments.sprint) && String.isNotBlank(aSearchArguments.aggregateItem)){
      sprintAuditGroup = true;
      sid = aSearchArguments.aggregateItem;
      qid = aSearchArguments.sprintId;
       whereClause = 'WHERE Sprint_Item__r.Item__r.Aggregate_Item__c = :sid AND Sprint__c = :qid ';
  	} else if (String.isNotBlank(aSearchArguments.aggregateItem)){
      sprintAuditGroup = false;
      sid = aSearchArguments.aggregateItem;
      whereClause = 'WHERE Sprint_Item__r.Item__r.Aggregate_Item__c = :sid ';
  	} else {
      sprintAuditGroup = false;
      qid = aSearchArguments.itemId;
      whereClause = 'WHERE Sprint_Item__r.Item__c = :qid ';
    } 

    query = 'SELECT Item_Component_Name__c, Quantity_Remaining__c, Number_Finished__c, Number_Started__c, Stage__c, Quantity__c,  ' +
            'Item_Component_Use__c, Sprint_Item__c, Item_Component_Use__r.Item__c, ' +
            'Item_Component_Use__r.Item_Component__c, Item_Component_Use__r.Item__r.Name, Sprint__r.Sequence__c, ' +
            'Item_Component_Use__r.Item__r.Record_Type_Description__c, Item_Component_Use__r.Item__r.Build_Stage_Index__c ' +
            'FROM ItemComponentUseAudi__c ' + whereClause + 'ORDER BY Item_Component_Use__r.Item__r.Name, Item_Component_Name__c';
    listAudits = Database.query(query); 

    //  if the selection is item or aggregate only, filter out all but the latest audits
    if (!sprintAuditGroup){
      //  get the latest audits only
      ItemComponentUseAudi__c latestAudit;
      Map<Id, ItemComponentUseAudi__c> listLatestAudits = new Map<Id, ItemComponentUseAudi__c>();
      List<ItemComponentUseAudi__c> templistAudits = new List<ItemComponentUseAudi__c>();
      for (ItemComponentUseAudi__c icu1 : listAudits){
        if (listLatestAudits.get(icu1.Item_Component_Use__c) == null){
          for (ItemComponentUseAudi__c icu2 : listAudits){
            if(icu1.Item_Component_Use__c == icu2.Item_Component_Use__c)
              templistAudits.add(icu2);
          }
          for (ItemComponentUseAudi__c icu3 : templistAudits){
            if (latestAudit == null)
              latestAudit = icu3;
            else if  (latestAudit.Sprint__r.Sequence__c < icu3.Sprint__r.Sequence__c)
              latestAudit = icu3;
          }
          listLatestAudits.put(latestAudit.Item_Component_Use__c, latestAudit); 
          latestAudit = null;
          templistAudits.clear();
        }
      }
        	
      for (ItemComponentUseAudi__c icu4 : listLatestAudits.values()){
          returnAudits.add(icu4);
      }
    }  else
      returnAudits = listAudits;


    //  filter out audits at a stage later than the build stage
    List<ItemComponentUseAudi__c> currentAudits = returnAudits.clone();
    for (Integer i=currentAudits.size() - 1; i >= 0; i--){
     if (am_Stage.getStageIndex(currentAudits[i].Item_Component_Use__r.Item__r.Record_Type_Description__c, currentAudits[i].Stage__c) > 
        currentAudits[i].Item_Component_Use__r.Item__r.Build_Stage_Index__c){
        returnAudits.remove(i);
     }   
    }
                
    return returnAudits;
*/
  } 

  @AuraEnabled 
  public static void saveItemComponentAudits(List<ItemComponentUseAudi__c> aSelectedItemComponentUseAudits){
    //  gets the list of ItemComponents once an item is selected in the dropdown item list 
    List<Id> itemCompIds = new List<Id>();
    Set<Id> sprintItemIds = new Set<Id>();
    for (ItemComponentUseAudi__c icua:aSelectedItemComponentUseAudits){
      sprintItemIds.add(icua.Sprint_Item__c);
      itemCompIds.add(icua.Item_Component_Use__c);
    }
    List<Item_Component_Use__c> itemComponentUses = [SELECT Item__c, Item_Component__c, Quantity__c, Number_Finished__c, Number_Started__c, Stage__c 
                                                     FROM Item_Component_Use__c 
                                                     WHERE Id IN :itemCompIds];
                                                     
    List<Activity__c> selectedActivities = am_Activity.getActivities(sprintItemIds);
    saveUpdateItemComponentAudits(aSelectedItemComponentUseAudits, itemComponentUses, selectedActivities);                                                       
  } 
 
  public void refreshselectedItemComponentUses(){
    //  gets the list of ItemComponents once an item is selected in the dropdown item list
    selectedItemComponentUses = [SELECT Item__c, Item_Component__c, Quantity__c, Number_Finished__c, Number_Started__c, Stage__c, 
                                 Item__r.Variation__c  
                                 FROM Item_Component_Use__c WHERE Item__c = :item];
  }

	

  public void refreshselectedItemComponentUseAudits(){
    //  gets the list of ItemComponentAuditUses once an item is selected in the dropdown item list

    selectedItemComponentUseAudits = [SELECT Item_Component_Use__r.Id, Item_Component_Use__r.Item_Component__r.Name, Quantity_Remaining__c, Number_Finished__c, Number_Started__c,
                                      Stage__c, Quantity__c, Item_Component_Use__r.Item__r.Variation__c, Sprint_Item__c 
                                      FROM ItemComponentUseAudi__c
                                      WHERE (Item_Component_Use__r.Item__r.Name = :item OR Item_Component_Use__r.Item__r.Variation_Item__r.Name = :item)
                                      AND Sprint__c = :sprint];

    selectedItemComponentUses = [SELECT Item__c, Item_Component__c, Quantity__c, Number_Finished__c, Number_Started__c, Stage__c, 
                                 Item__r.Variation__c
                                 FROM Item_Component_Use__c WHERE (Item__r.Name = :item OR Item__r.Variation_Item__r.Name = :item)];
  }
 
   public void loadSprintItemsWrap(){ 	
     sprintItemsWrapper = new List<sprintItemWrap>();
 
     for (Sprint_Items__c a :[SELECT Item__r.Name, Sprint_Item_Stage__c, Sprint_Item_Status_Complete__c, Item__r.Variation__c, Item__c, 
                              Item__r.Stage_Type__c, Item_Stage_at_Sprint_Start__c, Sprint__c
                              FROM Sprint_Items__c 
                              WHERE Sprint__c = :sprint ORDER BY Item__r.Name]){
    	sprintItemsWrapper.add(new sprintItemWrap(a));
     }
   } 
    
  public PageReference pageHandler(){
    Boolean noError = True;
    //  Provide function to direct all page actions 
    if (callAction == 'saveRecord'){
      Set<Id> sprintItemIds = new Set<Id>();
      for (ItemComponentUseAudi__c icua:selectedItemComponentUseAudits)
        sprintItemIds.add(icua.Sprint_Item__c);
        
      List<Activity__c> selectedActivities = am_Activity.getActivities(sprintItemIds);

      noError = saveUpdateItemComponentAudits(selectedItemComponentUseAudits, selectedItemComponentUses, selectedActivities);

    }  else if (callAction == 'updateSelectedItemsFinished' || callAction == 'updateSelectedItemsStarted'  || callAction == 'updateSelectedItemsNotStarted'){
      //set the quantity finished to the quantity for all the selected items in the sprint
      //  extract only the selected items from the wrapper
      List<Id> itemIds = new List<Id>();
      for (sprintItemWrap aw :sprintItemsWrapper){
        if(aw.selected == true){
          itemIds.add(aw.sprintItem.Item__c);    
        }
      }
       List<String> itemNames = new List<String>();
       for (Progress__c a :[SELECT Name FROM Progress__c WHERE Id IN :itemIds]){
          String itemName = a.Name;
          itemNames.add(itemName);    
       }
       
       //  get the item component use audits for all items that are not already completed
      selectedItemComponentUseAudits = [SELECT Item__c, Item_Component_Use__c, Quantity__c, Number_Started__c, Number_Finished__c, Stage__c, Sprint_Item__c 
                                        FROM ItemComponentUseAudi__c WHERE Item__c IN :itemNames];
 
      for (Integer i=0; i < selectedItemComponentUseAudits.size(); i++){
      	if (callAction == 'updateSelectedItemsFinished') {
          selectedItemComponentUseAudits[i].Number_Finished__c = selectedItemComponentUseAudits[i].Quantity__c;
          selectedItemComponentUseAudits[i].Number_Started__c = 0;
          selectedItemComponentUseAudits[i].Quantity_Remaining__c = 0;     
      	} else if (callAction == 'updateSelectedItemsStarted'){
          selectedItemComponentUseAudits[i].Number_Finished__c = 0;
          selectedItemComponentUseAudits[i].Number_Started__c = selectedItemComponentUseAudits[i].Quantity__c;
          selectedItemComponentUseAudits[i].Quantity_Remaining__c = selectedItemComponentUseAudits[i].Quantity__c; 
       	} else if (callAction == 'updateSelectedItemsNotStarted'){
          selectedItemComponentUseAudits[i].Number_Finished__c = 0;
          selectedItemComponentUseAudits[i].Number_Started__c = 0;
          selectedItemComponentUseAudits[i].Quantity_Remaining__c = selectedItemComponentUseAudits[i].Quantity__c; 
    	}       
      } 
      
      //  get the item component uses for all items that are not already completed
      selectedItemComponentUses = [SELECT Item__c, Item_Component__c, Quantity__c, Number_Started__c, Number_Finished__c, Stage__c, Item__r.Variation__c 
                                 FROM Item_Component_Use__c WHERE Item__c IN :itemIds];
        
      for (Integer i=0; i < selectedItemComponentUses.size(); i++){
      	if (callAction == 'updateSelectedItemsFinished') {
          selectedItemComponentUses[i].Number_Finished__c = selectedItemComponentUses[i].Quantity__c;
          selectedItemComponentUses[i].Number_Started__c = 0;
      	} else if (callAction == 'updateSelectedItemsStarted'){
          selectedItemComponentUses[i].Number_Finished__c = 0;
          selectedItemComponentUses[i].Number_Started__c = selectedItemComponentUses[i].Quantity__c;
      	} else if (callAction == 'updateSelectedItemsNotStarted'){
          selectedItemComponentUses[i].Number_Finished__c = 0;
          selectedItemComponentUses[i].Number_Started__c = 0;
      	}    
      }

      update selectedItemComponentUses; 
      update selectedItemComponentUseAudits;

      //  update activities 
      Set<Id> sprintItemIds = new Set<Id>();
      for (Sprint_Items__c si :[SELECT Id FROM Sprint_Items__c WHERE Item__c IN :itemIds AND Sprint__c = :sprint])
        sprintItemIds.add(si.Id);

      if (callAction == 'updateSelectedItemsFinished') 
        callAction = 'Finished';
      else if (callAction == 'updateSelectedItemsStarted')
        callAction = 'Started';
      else if (callAction == 'updateSelectedItemsNotStarted')
        callAction = 'Not Started';           

      am_Activity.updateActivity(am_Activity.getActivities(sprintItemIds), callAction, selectedItemComponentUses);

    } else if (callAction == 'removeSprintItems'){
      //  create list of sprint items
      List<Sprint_Items__c> sprintItems = new List<Sprint_Items__c>();
      for (sprintItemWrap aw :sprintItemsWrapper){
        if(aw.selected == true)
          sprintItems.add(aw.sprintItem);    
      }
      
      am_SprintItem.removeSprintItems(sprintItems);
    }
    //  control page behaviour depending on error
    if (noError) 
      return retPage;
    else 
      return ApexPages.CurrentPage();
  }
  
  public static Boolean saveUpdateItemComponentAudits(List<ItemComponentUseAudi__c> aSelectedItemComponentUseAudits,
                                                   List<Item_Component_Use__c> aSelectedItemComponentUses, List<Activity__c> aSelectedActivities){

      // create map of the ItemComponentAudits to use for updating the item component use record
      Map<Id, ItemComponentUseAudi__c> audits = new Map<Id, ItemComponentUseAudi__c>();
      List<ItemComponentUseAudi__c> auditsUpdated = new List<ItemComponentUseAudi__c>();
      for (ItemComponentUseAudi__c a :aSelectedItemComponentUseAudits){
        // adjust number started if number started and number finished exceeds quantity
        if (a.Number_Finished__c + a.Number_Started__c > a.Quantity__c) 
          a.Number_Started__c = a.Quantity__c - a.Number_Finished__c;
        
        a.Quantity_Remaining__c = a.Quantity__c - a.Number_Finished__c;

        audits.put(a.Item_Component_Use__c, a);
      } 

      for (Integer i=0; i < aSelectedItemComponentUses.size(); i++){
        aSelectedItemComponentUses[i].Number_Finished__c = audits.get(aSelectedItemComponentUses[i].Id).Number_Finished__c;
        aSelectedItemComponentUses[i].Number_Started__c = audits.get(aSelectedItemComponentUses[i].Id).Number_Started__c;            	  
      }
      try {
        update aSelectedItemComponentUses; 
      } catch (dmlexception e) {
        //  DS 23/4/17 this does not work correctly in displaying message
//        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Number Finished cannot exceed Quantity');
//        ApexPages.addMessage(myMsg);
        return False;
      } 
       
      am_Activity.updateActivity(aSelectedActivities, 'update', aSelectedItemComponentUses);
      for (Id key : audits.keySet()){
      	auditsUpdated.add(audits.get(key));
      }
      update auditsUpdated; 
      
      return True;
    
  }
  
  public List<SelectOption> getitemList(){
    //  returns a list of the last months project sprints associated with the items selected
    List<Sprint_Items__c> items;
    try { 
      items =  [SELECT Item__r.Name, Item__c FROM Sprint_Items__c WHERE Sprint__c = :sprint 
                AND Id IN (SELECT Sprint_Item__c FROM Activity__c WHERE Sprint_Item__r.Sprint__c = :sprint AND Type__c = 'Component Based')
                AND Item__r.Variation__c = false];
    }
      catch (System.NullPointerException e) {
        items =  [SELECT Id, Name FROM Sprint_Items__c  ];
    }       
        
    List<SelectOption> ItemOptionList = new List<SelectOption>();
    ItemOptionList.add(new SelectOption( ' ' ,'---Select Item from list---'));
    for(Sprint_Items__c i : items ){ 
      ItemOptionList.add(new SelectOption(i.Item__c, i.Item__r.Name));
    }
    return ItemOptionList ;
  }
  
}