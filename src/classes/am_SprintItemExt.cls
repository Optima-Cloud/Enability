public class am_SprintItemExt {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          2/9/2016 
   *  Modified by:   David Strangward
   *  Date Modified: 9/9/2016
   *                 Add page handler for remove sprint items
   *  Description:   Handles .
   *            
   ***********************************************************************************************/  
    
  private ApexPages.StandardSetController standardSetController;
  public List<Sprint_Items__c> selectedSprintItems {set; get;}
  public string sprint  {set; get;}
  public String callAction {set; get;}
  private PageReference retPage;
 
  public am_SprintItemExt(ApexPages.StandardSetController SetController){
    selectedSprintItems = [SELECT Id, Name, Level__c, Wing__c, Item_Status__c, Item__c, Item__r.Stage_Type__c, Sprint__c, Sprint_Item_Status_Complete__c, 
                           Sprint_Item_Stage__c, Sprint__r.Project__r.Project_Type__c, Sprint__r.Project__c, Item_Status_at_Sprint_Start__c, Item_Stage_at_Sprint_Start__c 
                           FROM Sprint_Items__c WHERE id in :SetController.getSelected()];
    standardSetController = SetController;
    retPage = standardSetController.cancel();
  }
 
  public PageReference pageHandler(){
    //  Provide function to direct all page actions

    if (callAction == 'moveSprintItems'){
//  functionality removed   
//      moveSprintItems();
    } else if (callAction == 'removeSprintItems'){
      am_SprintItem.removeSprintItems(selectedSprintItems);
    }
    return retPage; 
  }

  @AuraEnabled 
  public static List<Sprint_Items__c> getItems(String aSprint){
    //  gets the list of Items once a sprint is selected in the dropdown item list

    return [SELECT Item__r.Name, Item__r.Id, Item__c FROM Sprint_Items__c WHERE Sprint__c = :Id.valueOf(aSprint) 
            AND Id IN (SELECT Sprint_Item__c FROM Activity__c 
            WHERE Sprint_Item__r.Sprint__c = :Id.valueOf(aSprint)) 
            AND Id IN (SELECT Sprint_Item__c FROM ItemComponentUseAudi__c 
            WHERE Sprint__c = :Id.valueOf(aSprint))
            ORDER BY Item__r.Name ASC];
  } 

  @AuraEnabled 
  public static List<Progress__c> getItemsInSprint(String aSprint){
    //  gets the list of Items once a sprint is selected in the dropdown item list

    Set<Id> itemIds = new Set<Id>();

  	for (Sprint_Items__c ids :[SELECT Item__r.Name, Item__r.Id, Item__c FROM Sprint_Items__c WHERE Sprint__c = :Id.valueOf(aSprint) 
                               AND Id IN (SELECT Sprint_Item__c FROM Activity__c 
                               WHERE Sprint_Item__r.Sprint__c = :Id.valueOf(aSprint)) 
                               AND Id IN (SELECT Sprint_Item__c FROM ItemComponentUseAudi__c 
                               WHERE Sprint__c = :Id.valueOf(aSprint))
                               ORDER BY Item__r.Name ASC])
  	  itemIds.add(ids.Item__r.Id);

    return [SELECT Id, Name, Aggregate_Item__c FROM Progress__c WHERE Id IN :itemIds ORDER BY Name]; 
  } 
  
  @AuraEnabled 
  public static List<Sprint_Items__c> getItemsSprint(String aSprint){
    //  gets the list of Items once a sprint is selected in the dropdown item list
    return [SELECT Item__r.Name, Item__r.Id, Item__c FROM Sprint_Items__c WHERE Sprint__c = :Id.valueOf(aSprint) 
            AND Id IN (SELECT Sprint_Item__c FROM Activity__c 
            WHERE Sprint_Item__r.Sprint__c = :Id.valueOf(aSprint)) 
            AND Id IN (SELECT Sprint_Item__c FROM ItemComponentUseAudi__c 
            WHERE Sprint__c = :Id.valueOf(aSprint)) ORDER BY Item__r.Name ASC];
  } 

  @AuraEnabled 
  public static List<Progress__c> getItemsProject(String aProject){
    //  gets the list of Items once a sprint is selected in the dropdown item list
    return [SELECT Name, Id, Aggregate_Item__c FROM Progress__c WHERE Project__c = :aProject ORDER BY Name ASC];
  } 

/*  not currently working 20/9/2016
  public void moveSprintItems(){
    //  if the sprint item is already started the item is copied
    //  set the sprint item to a new sprint
    List<Sprint_Items__c> tempSprintList =  new List<Sprint_Items__c>();
        
    //  update selected items with the select sprint (use normal loop so can delete from list)
    for ( Integer i = selectedSprintItems.size() - 1; i >= 0; --i )
    {
      Sprint_Items__c tempSprint = new Sprint_Items__c();
      tempSprint.Sprint_Item_Stage__c = selectedSprintItems[i].Sprint_Item_Stage__c;
      tempSprint.Sprint_Item_Status_Complete__c = selectedSprintItems[i].Sprint_Item_Status_Complete__c;
      tempSprint.Sprint__c = sprint;
      tempSprint.Item__c = selectedSprintItems[i].Item__c;
      tempSprint.Item_Status_at_Sprint_Start__c = selectedSprintItems[i].Sprint_Item_Status_Complete__c;
      tempSprintList.add(tempSprint);
      if (selectedSprintItems[i].Sprint_Item_Status_Complete__c != null)
        selectedSprintItems.remove(i);
      }
system.debug('tempSprintList = ' + tempSprintList);
    //  Delete the sprint items record if the item is not started
    delete selectedSprintItems;

    //  update the items related to the selected sprint items
    insert tempSprintList;
  } 
*/
//  redundant when status controlled by item component use and activity
/* 
    public PageReference  startSprintItems(){
        //  invoked to set sprint item to started       

        //  Update the sprint items record 
        for(Sprint_Items__c selectedSprintItem :selectedSprintItems){
            selectedSprintItem.Sprint_Item_Status_Complete__c = 'Started';
        }  
        //  Update the sprint items record
        update selectedSprintItems;
        
        // Call StandardSetController 'save' method to update 
        return standardSetController.save();  
    } 
    
  public PageReference  completeSprintItems(){
    //  invoked to set item stage and status to sprint stage and finished       
    List<Progress__c> tempItemList =  new List<Progress__c>();
 
    //  Loop through each selected sprint item and update tempitem and tempitemList with status and id
    //  Update the sprint items record 
    for(Sprint_Items__c selectedSprintItem :selectedSprintItems){
      Progress__c tempItem = new Progress__c();        
      tempItem.Stage__c = selectedSprintItem.Sprint_Item_Stage__c;
      tempItem.Id = selectedSprintItem.Item__c;
      tempItem.Item_Status_New__c = 'Finished';
      tempItemList.add(tempItem);
            
      selectedSprintItem.Sprint_Item_Status_Complete__c = 'Finished';
    }  
    
    //  Update the sprint items record
    update selectedSprintItems;
        
    //  update the items related to the selected sprint items
    update tempItemList;

    // Call StandardSetController 'save' method to update 
    return standardSetController.save();  
  }
*/


  public List<SelectOption> getSprintList(){
    List<Sprint__c> sprintList =  [SELECT Id, Name FROM Sprint__c WHERE Project__c = :selectedSprintItems[0].Sprint__r.Project__c
                                   AND Date_Start__c > :(system.Today()-31) Order BY Sequence__c ];
    List<SelectOption> SprintOptionList = new List<SelectOption>();
    SprintOptionList.add(new SelectOption( ' ' ,'---Select Sprint from list---'));
    for (Sprint__c s : sprintList ){
      SprintOptionList.add(new SelectOption(s.Id , s.Name));
    }
    
    return SprintOptionList ;
  }
}