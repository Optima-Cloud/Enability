public class am_Sprint {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          2/6/2016
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles the adding of items to sprints and automatically creates an activity for all sprint items.
   *                 Advances an item status to the next stage if the prior stage was complete.
   ***********************************************************************************************/  
 
  public static List<Sprint__c> getSprints(String aProject){
    return [SELECT Name, Id, Date_Start__c, Date_End__c FROM Sprint__c WHERE Project__c = :Id.valueOf(aProject) ORDER BY Sequence__c DESC];
  } 

  public static void addSprintItems(List<String> selectedItems, String aSprint){
  	addSprintItems(am_Item.getItems(selectedItems), aSprint); 
  }
 
  public static void addSprintItems(List<Progress__c> selectedItems, String aSprint){
    //  create a new sprint list with the new selected items and an activity with each sprint item
    List<Sprint_Items__c> newSprintList =  new List<Sprint_Items__c>();
    List<Activity__c> newActivityList = new List<Activity__c>();
    Decimal tempEstimatedHours = 0;

    //  get set of items already in sprint
    Set<Id> sprintItemIds = new Set<Id>();
    for (Sprint_Items__c sp : [SELECT Item__c FROM Sprint_Items__c WHERE Sprint__c = :aSprint])
      sprintItemIds.add(sp.Item__c);
       
    for(Progress__c thisItem :selectedItems){
      //  create sprint item if not already in sprint
      if (!sprintItemIds.contains(thisItem.Id)){
        Sprint_Items__c tempSprintItem = new Sprint_Items__c();
        tempSprintItem.Sprint__c = aSprint;
        tempSprintItem.Item__c = thisItem.Id;
        tempSprintItem.Sprint_Hours_Earned__c = 0;
        tempSprintItem.Percent_Complete__c = 0;
        tempSprintItem.Item_Status_at_Sprint_Start__c = thisItem.Item_Status_New__c;
        tempSprintItem.Item_Stage_at_Sprint_Start__c = thisItem.Stage__c;
        if (thisItem.Item_Status_New__c == 'Finished' || thisItem.Stage__c == 'Pending' || string.isblank(thisItem.Stage__c)){
          tempSprintItem.Sprint_Item_Stage__c = am_Stage.getNextStage(thisItem.Stage_Type__c, thisItem.Stage__c);
          tempSprintItem.Sprint_Item_Status_Complete__c = 'Not Started';
        } else {
          tempSprintItem.Sprint_Item_Stage__c = thisItem.Stage__c;
          tempSprintItem.Sprint_Item_Status_Complete__c = thisItem.Item_Status_New__c;
        }
        newSprintList.add(tempSprintItem);
      }
    }

    //  insert the sprint items related to the selected sprints 
    insert newSprintList;

    //  do not continue if item is already in sprint
//  new functionality to test for audit for all items and components
    //  create a set of all components with audits for the item and sprint
    Set<Id> componentsWithAuditIds = new Set<Id>();
    for (ItemComponentUseAudi__c icua : [SELECT Item_Component_Use__c FROM ItemComponentUseAudi__c WHERE Item_Component_Use__c 
                                        IN (SELECT Id FROM Item_Component_Use__c WHERE Item__c IN :selectedItems)
                                        AND Sprint__c = :aSprint]){ 
      componentsWithAuditIds.add(icua.Item_Component_Use__c);                             	
    }
    
    //  determine which components and items do not have an audit
    List<Id> componentsWithoutAuditIds = new List<Id>();
    List<Id> itemsWithoutAuditIds = new List<Id>();
    for(Item_Component_Use__c icu :[SELECT Id, Item__c FROM Item_Component_Use__c WHERE Item__c IN :selectedItems]) {
      if (!componentsWithAuditIds.contains(icu.Id)){
        componentsWithoutAuditIds.add(icu.Id); 
        itemsWithoutAuditIds.add(icu.Item__c);
      }
    } 

    //  create audits for the components without an audit
    if (componentsWithoutAuditIds.size()>0)
      am_ItemComponentUseAudit.addItemComponentUseAudit([SELECT Quantity_Remaining__c, Stage__c, Item__c, Number_Finished__c, 
                                                         Number_Started__c, Item__r.Stage_Type__c, Quantity__c
                                                         FROM Item_Component_Use__c WHERE Id IN :componentsWithoutAuditIds], 
                                                         aSprint,
                                                         [SELECT Id, Item__c, Sprint_Item_Stage__c 
                                                          FROM Sprint_Items__c 
                                                          WHERE Item__c IN :itemsWithoutAuditIds AND Sprint__c = :aSprint]); 


      // for ItemComponentUses related to the items in the sprint set the stage and status completed
      am_ItemComponentUse.setStage(selectedItems); 
      List<Item_Component_Use__c> listItemComponentUse = [SELECT Stage__c, Item__c FROM Item_Component_Use__c WHERE Item__c IN :selectedItems];
    
      Set<String> stagesUsed = new Set<String>();
      Map<String, String> stageUsedType = new Map<String, String>();
    
      //  add a default activity when adding a new sprint item
      //  adds a default activity for each item component use stage for the sprint item
      for(Sprint_Items__c thisSprintItem :[Select Sprint_Item_Stage__c, Sprint_estimated_old__c, Item__c, Item__r.Name,
                                           Item__r.Hr_Infrastructure_Estimated_Components__c, Item__r.Hr_Install_Estimated_Components__c, Item__r.Stage_Type__c, Item_Stage__c,
                                           Item__r.Project__r.Name, Item__r.Item_Status_New__c, Sprint__r.Sequence__c, Sprint_Item_Status_Complete__c 
                                           from Sprint_Items__c where Id in :newSprintList]){
        // determine if multiple activities from item component use or create activity with no item component use for that item
        for (Item_Component_Use__c icu :listItemComponentUse) {
          if (!stagesUsed.contains(icu.Stage__c) && icu.Item__c == thisSprintItem.Item__c){
            stagesUsed.add(icu.Stage__c);
            stageUsedType.put(icu.Stage__c, 'Component Based');
          }
        }

        //  if no stage in map, indicates activity based item and create activity with stage from sprint
        if (stagesUsed.size() == 0){
          stagesUsed.add(thisSprintItem.Sprint_Item_Stage__c);
          stageUsedType.put(thisSprintItem.Sprint_Item_Stage__c, 'Activity Based');
        }
      
        //  loop through stages determined for sprint item and create activity  
        for (String stage : stageUsedType.keySet()){
          // get % of item for each activity
          Decimal activityPercent = 100 / stagesUsed.size();
          Activity__c tempActivity = new Activity__c();
      
          tempActivity.Item__c = thisSprintItem.Item__c;
          tempActivity.Sprint_Item__c = thisSprintItem.Id;
          tempActivity.Percent_of_Item_Sprint__c = string.valueof(activityPercent);
          tempActivity.Description__c = thisSprintItem.Item__r.Project__r.Name + ' - Sprint ' + thisSprintItem.Sprint__r.Sequence__c 
                                    + ': - Perform ' + stage + ' in ' + thisSprintItem.Item__r.Name;
          tempActivity.Stage__c = stage;
          tempActivity.Type__c = stageUsedType.get(stage); 
          //  if stage is sprint stage then estimate hours on actual status, otherwise estimate hours on max status of started only
          //  as a later stage cannot be completed until earlier stage is completed
          if (stage == 'Roughin')
            tempEstimatedHours = thisSprintItem.Item__r.Hr_Infrastructure_Estimated_Components__c;
          else
            tempEstimatedHours = thisSprintItem.Item__r.Hr_Install_Estimated_Components__c; 

          tempActivity.Estimated_Hours__c = am_Stage.getStageStatusPercentage(stage, thisSprintItem.Sprint_Item_Status_Complete__c, thisSprintItem.Item__r.Stage_Type__c, 'StatusBased') * tempEstimatedHours / 100;

          tempActivity.Status__c = 'Not Started';
          newActivityList.add(tempActivity);
        } 
      
        stagesUsed.clear(); 
        stageUsedType.clear();
      }   
      //  insert the activities related to the selected sprint items
      insert newActivityList;  
    }
    
    public static Decimal getCurrentLatestSprintSequence(am_UniversalSearchArguments aSearchArguments){ 
      //  get project Id
      Id projectID = aSearchArguments.getProjectID();
      Decimal currentSequence = null;
      Decimal latestSequence = 0;
      
      //  return the sequence of the lastest or the sprint in the current date
    	date todayDate = date.today();
    	for (Sprint__c s : [SELECT Date_Start__c, Date_End__c, Sequence__c FROM Sprint__c WHERE Project__c = :projectID]){
    		if (s.Date_Start__c <= todayDate && s.Date_End__c >= todayDate)
    		  currentSequence = s.Sequence__c;
    		if (s.Sequence__c > latestSequence)
    		  latestSequence = s.Sequence__c;
    	}
      if (currentSequence != null)
        return currentSequence;
      else if (latestSequence != null)
        return latestSequence;
      else
        return 0;
    }
    
    public static Decimal getCurrentSprintSequence(am_UniversalSearchArguments aSearchArguments){ 
      //  get project Id
      Id projectID = aSearchArguments.getProjectID();
      Decimal currentSequence = null;
      
      //  return the sequence of the lastest or the sprint in the current date
    	date todayDate = date.today();
    	for (Sprint__c s : [SELECT Date_Start__c, Date_End__c, Sequence__c FROM Sprint__c WHERE Project__c = :projectID]){
    		if (s.Date_Start__c <= todayDate && s.Date_End__c >= todayDate)
    		  currentSequence = s.Sequence__c;
    	}

      if (currentSequence != null)
        return currentSequence;
      else  
        return 99999;
    }
    
}