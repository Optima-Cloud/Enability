public class am_Activity { 
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          1/8/2016 
   *  Modified by: 
   *  Date Modified: 
   *
   *  Description:   Handles all the activities methods
   *                 Currently contains page handlers and trigger handlers which need to be moved
   *            
   ***********************************************************************************************/  
  public static List<Activity__c> getActivitiesLatest(List<Progress__c> aItems){
  	//  gets activities for passed items and filter out all but the latest 
    List<Activity__c> listActivities = new List<Activity__c>(); 
    List<Activity__c> listLatestActivities = new List<Activity__c>(); 
    List<Id> itemIds = new List<Id>();
   
    for (Progress__c i :aItems)
      itemIds.add(Id.ValueOf(i.Id));
     
    listActivities = [SELECT Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__c, Stage__c, 
                      Description__c, Item__c, Sprint_Item__r.Sprint__r.Sequence__c, 
                      Item__r.Record_Type_Description__c, Item__r.Build_Stage_Index__c          
                      FROM Activity__c WHERE Item__c IN :itemIds]; 
   
    //  create map of items with list of activities to manipulate
    Map<Id, List<Activity__c>> mapActivities = new Map<Id, List<Activity__c>>();
    List<Activity__c> listTempActivity = new List<Activity__c>();
    for (Activity__c act : listActivities)
      mapActivities.put(act.Item__c, listTempActivity); 

    //  add activities to map list for each component
    List<Activity__c> tempActivity;
    for (Activity__c tact : listActivities){
      tempActivity = new List<Activity__c>(mapActivities.get(tact.Item__c));
      tempActivity.add(tact);
      mapActivities.put(tact.Item__c, tempActivity);
    }
      
    //  cycle through map and keep only the latest audit
    Activity__c latestActivity;
    for (Id cmpId : mapActivities.keySet()){
      for (Activity__c act : mapActivities.get(cmpId)){
        if (latestActivity == null)
       	  latestActivity = act;
        else if (act.Sprint_Item__r.Sprint__r.Sequence__c > latestActivity.Sprint_Item__r.Sprint__r.Sequence__c)
          latestActivity = act;
      }
      listLatestActivities.add(latestActivity);
      latestActivity = null;
    }
    return listLatestActivities; 

  }   

  public static List<Activity__c> getActivities(Id item, Id sprint){
    return [Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__c, Description__c, Item__c         
            FROM Activity__c WHERE Sprint_Item__c 
            IN (SELECT Id FROM Sprint_Items__c WHERE Sprint__c = :sprint AND (Item__c = :item OR Item__r.Variation_Item__c = :item))];
  }  

  public static Activity__c getActivity(String aActivityId){
    return [Select Id, Description__c FROM Activity__c WHERE Id = :aActivityId];
  }  

  public static List<Activity__c> getActivities(Id sprint){
    return [Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__c, Description__c, Item__c         
            FROM Activity__c WHERE Sprint_Item__c 
            IN (SELECT Id FROM Sprint_Items__c WHERE Sprint__c = :sprint)];
  }  

  public static List<Activity__c> getActivities(Set<Id> sprintItemIds){
    return [Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__c, Description__c, Item__c         
            FROM Activity__c WHERE Sprint_Item__c 
            IN :sprintItemIds];
  }  

  public static void updateActivity(List<Activity__c> selectedActivities, String callAction){
    //  invoked to update an activity not based on item component use       
    List<Item_Component_Use__c> selectedItemComponentUses = new List<Item_Component_Use__c>();
    updateActivity(selectedActivities, callAction, selectedItemComponentUses);
  }

  public static void updateActivity(List<Activity__c> selectedActivities, String callAction, List<Item_Component_Use__c> selectedItemComponentUses){
    //  invoked to set item stage and activity status to finished sprint stage and finished       

    //  used to determine if an activity or item component use based update
    Set<Id> itemComponentIds = new Set<Id>();
    for (Item_Component_Use__c icu :selectedItemComponentUses)
      itemComponentIds.add(icu.Item__c);
      
    //  Update the activity record for Item Component Use or passed activity
    List<Item_Component_Use__c> tempICUList = new List<Item_Component_Use__c>();
    
    for(Integer i = 0; i < selectedActivities.size(); i++){ 
      // for each activity, check the stage and update the status based on the status of Item Components at that stage
      if (itemComponentIds.contains(selectedActivities[i].Item__c)){
        Activity__c newActivity = new Activity__c();
        for ( Item_Component_Use__c icu:selectedItemComponentUses) {
          if (icu.Item__c == selectedActivities[i].Item__c){    
            Item_Component_Use__c tempICU = new Item_Component_Use__c();
            if (selectedActivities[i].Description__c.contains(icu.Stage__c))
              tempICUList.add(icu);
          }
        }        
        selectedActivities[i].Status__c = am_ItemComponentUse.determineItemComponentStatus(tempICUList);
        tempICUList.clear();
      }
      else
        selectedActivities[i].Status__c = callAction;
    }

    //  remove or update the activity record
    if (callAction == 'Remove')
      delete selectedActivities;          
    else
      update selectedActivities;
    //  update the Item and sprint item status and stage based on the status of the activities
    updateStatusStage(selectedActivities); 
  }

  public static void updateStatusStage(List<Activity__c> selectedActivities){ 
    List<Sprint_Items__c> selectedSprintItems = [Select Id, Name, Item__c, Level__c, Percent_Complete__c, Item__r.Stage_Type__c,
                                                 Sprint_Hours_Earned__c, Sprint_Hours_Estimated__c, Sprint_Item_Stage__c,
                                                 Item_Status_at_Sprint_Start__c, Item_Stage_at_Sprint_Start__c, Sprint_Item_Status_Complete__c
                                                 FROM Sprint_Items__c where Id IN 
                                                 (SELECT Sprint_Item__c FROM Activity__c WHERE Id IN :selectedActivities)];

    List<Activity__c> sprintActivities = [SELECT Sprint_Item__c, Id, Name, Status__c, Percent_of_Item_Sprint__c, Stage__c, Stage_Type__c,
                                        Sprint_Item__r.Item__r.Id, Sprint_Item__r.Item__r.Name, Sprint_Item__r.Item__r.Project__r.Start__c, 
                                        Sprint_Item__r.Item__c, Sprint_Item__r.Item__r.Project__r.Finish__c, Sprint_Item__r.Sprint_Item_Stage__c
                                        FROM Activity__c WHERE Sprint_Item__c 
                                        IN :selectedSprintItems];
         
   List<Activity__c> selectedActivityDetails =  [Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__r.Item__c, 
            Stage_Type__c, Sprint_Item__r.Sprint_Item_Stage__c, 
            Sprint_Item__r.Sprint__r.Project__r.Roughin__c, Sprint_Item__r.Sprint__r.Project__r.Cutout__c,
            Sprint_Item__r.Sprint__r.Project__r.Fitoff__c, Sprint_Item__r.Sprint__r.Project__r.Commission__c, 
            Sprint_Item__r.Sprint__r.Project__r.Stage_Develop__c, Sprint_Item__r.Sprint__r.Project__r.Stage_Implement__c, 
            Sprint_Item__r.Item__r.Project__r.Start__c, Sprint_Item__r.Item__r.Project__r.Finish__c         
            FROM Activity__c WHERE Id IN : selectedActivities];

    List<Item_Component_Use__c> relatedItemComponentUses = [SELECT Id, Stage__c, Quantity__c, Quantity_Remaining__c, Number_Finished__c,
                                                            Item__r.Project__r.Project_Type__c, Item__r.Id, Item__c
                                                            FROM Item_Component_Use__c
                                                            WHERE Item__c IN (Select Item__c FROM Sprint_Items__c where ID IN :selectedSprintItems)];


   Map<Id, Item_Component_Use__c> itemComponentUseKeyedByItem = new Map<Id, Item_Component_Use__c>();
   for (Item_Component_Use__c icu :relatedItemComponentUses)
     itemComponentUseKeyedByItem.put(icu.Item__c, icu);

    Map<Id, Progress__c> selectedItems = new Map<Id, Progress__c>([SELECT Id, Name, Item_Status_New__c, Percent_Complete__c, Stage__c, Stage_Type__c
                                                                  FROM Progress__c WHERE Id IN 
                                                                  (SELECT Item__c FROM Sprint_Items__c WHERE ID IN :selectedSprintItems)]);
    Progress__c selectedItem;  
                        
    List<Progress__c> listItemsToUpdate = new List<Progress__c>();
    List<Sprint_Items__c> listSprintItemsToUpdate = new List<Sprint_Items__c>();
    List<Activity__c> targetActivity = new List<Activity__c>();
    String stageType;
    //  loop through all activities and calculate % for item related activities and sprint related activities separately
    For (Sprint_Items__c sprintItem : selectedSprintItems){
      for (Activity__c a :sprintActivities)
        if (a.Sprint_Item__r.Item__r.Id == sprintItem.Item__c)
          targetActivity.add(a);

      //  calculate Item stage, status and %complete based on activities related to the Item
      selectedItem = selectedItems.get(sprintItem.Item__c); 
      selectedItem.Stage__c = getActivityStage(targetActivity);
      selectedItem.Item_Status_New__c = getActivityStatus(targetActivity, selectedItem.Stage__c); 
      //  if there is an activity with a later stage set the status to 'started' as the lower stage must have started
      for (Activity__c a :targetActivity){
        stageType = a.Stage_Type__c;
        if (am_Stage.isHigherStage(selectedItem.Stage__c, a.Stage_Type__c, a.Stage__c)){
          selectedItem.Item_Status_New__c = 'Started';
          break;
        }
      }
      //  if maxStage is the last stage and finished, set stage to completed
      if ((selectedItem.Stage__c == am_Stage.getLastStage(stageType, selectedItem.Stage__c)) && selectedItem.Item_Status_New__c == 'Finished')
        selectedItem.Stage__c = 'Completed';

      
      selectedItem.Percent_Complete__c = getPercentageEarned(targetActivity);          
      listItemsToUpdate.add(selectedItem); 
      targetActivity.clear();

      //  calculate Sprint Item stage, status and %complete based on activities related only to the Sprint Item
      for (Activity__c a :sprintActivities)
        if (a.Sprint_Item__r.Item__r.Id == sprintItem.Item__c && a.Sprint_Item__c == sprintItem.Id)
          targetActivity.add(a);
      sprintItem.Sprint_Item_Stage__c = getActivityStage(targetActivity);
      sprintItem.Sprint_Item_Status_Complete__c = getActivityStatus(targetActivity, sprintItem.Sprint_Item_Stage__c); 
      sprintItem.Percent_Complete__c = am_Stage.getStageStatusPercentage('StatusOnly', sprintItem.Sprint_Item_Status_Complete__c, 
                                                                    selectedItem.Stage_Type__c, 'Cummulative');         
      sprintItem.Sprint_Hours_Earned__c = sprintItem.Sprint_Hours_Estimated__c  * sprintItem.Percent_Complete__c / 100;
      listSprintItemsToUpdate.add(sprintItem);
      
      targetActivity.clear();
    }       
            
    //  Update the items and sprint record
    update listItemsToUpdate;
    update listSprintItemsToUpdate;
  }

  private static Decimal getPercentageEarned(List<Activity__c> activitiesToAggregate){
    //  loops through the activities and aggreagates the percent earned for each activity
    Decimal aggregateEarned=0;
    //  loop through the map of activities and determine and aggregate the %earned for those that match the activityKey argument
    for(Activity__c a :activitiesToAggregate){
        aggregateEarned += am_stage.getStageStatusPercentage(a.Stage__c, a.Status__c, a.Stage_Type__c, 'Cummulative') 
                           * Decimal.valueOf(a.Percent_of_Item_Sprint__c);                  
    } 
    return aggregateEarned / 100;
  }
  
  
  private static String getActivityStage(List<Activity__c> activitiesToAggregate){
    //  loops through the activities and return the highest started stage or the highest finished stage if lower stage is completed
    String stageType = activitiesToAggregate[0].Stage_Type__c;
    List<String> stages = new List<String>();
    String maxStage = null;
    //  create list of all activity stages
    for(Activity__c a :activitiesToAggregate){
      stages.add(a.Stage__c);
    }

    //  get max stage started then loop through all other stages and check they are all finished
    integer j = stages.size();
    for (Integer s = 0; s < j; s++){
      maxStage = am_Stage.getMaxStage(stages, stageType);
      Integer maxStageIndex = 999999;
      //  get the index of max stage
      for (Integer i = 0; i < stages.size(); i++){
        if (stages.get(i) == maxStage) {
          maxStageIndex = i;
          break;
        }
      }

      //  check all other stages are finished
      for (Activity__c a :activitiesToAggregate){
        if ((a.Stage__c != maxStage && a.Status__c != 'Finished')  || (a.Stage__c == maxStage && a.Status__c == 'Not Started')){
          if(maxStageIndex <> 999999)
            stages.remove(maxStageIndex);
          break;
        }
      }
    }

    return maxStage;
  } 
 
  private static String getActivityStatus(List<Activity__c> activitiesToAggregate, String aStage){
    //  loops through the activities for the stage and return the lowest status, return 'started' if a later stage commenced
    String status = 'Not Started';
    //  loop through the map of activities and determine status
    for(Activity__c a :activitiesToAggregate){
      if (aStage == a.Stage__c){
        if (a.Status__c == 'Started'){
          Status = a.Status__c;
          break;
        } else if (a.Status__c == 'Finished' && status != 'Started') 
          Status = a.Status__c;
      } 
    }
      return Status;
  }
}