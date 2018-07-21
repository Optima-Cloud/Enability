public class am_BacklogQueue {
 /***********************************************************************************************
  *  Written by:    David Strangward
  *  Date:          24/5/2017
  *  Modified by:   
  *  Date Modified: 
  *
  *  Description:   Handles everything related to creation of backlog queue.
  *                 
  ***********************************************************************************************/  
  public static List<am_BacklogQueueElement> getBacklog(am_UniversalSearchArguments searchArguments, String aBasis){
    //  aBasis determines whether the queue is based on individual item components and audits or on items 
    //  adds items to backlog wrapper
    List<am_BacklogQueueElement> queue = new List<am_BacklogQueueElement>();
    List<Id> listIdItemsWithAuditsUses = new List<Id>(); 

    //  get sequence number of current sprint for the project
//      Decimal currentSprint = am_Sprint.getCurrentLatestSprintSequence(searchArguments);
    Decimal currentSprint = am_Sprint.getCurrentSprintSequence(searchArguments);
     
    if (String.isBlank(aBasis) || aBasis != 'level') {     
	  //  get latest item component use audits and show ones not in current sprint or completed
      List<ItemComponentUseAudi__c> latestAudits = am_ItemComponentUseAudit.getItemComponentAuditUses(searchArguments);

      Set<Id> idItemsWithAuditsUses = new Set<Id>(); 

      //  conditions are: not the last stage; less than current build stage; not in the current sprint; 
      //  not finished if in same build stage
      for (ItemComponentUseAudi__c icua : latestAudits){
        idItemsWithAuditsUses.add(icua.Item_Component_Use__r.Item__c);
        if (am_Stage.getStageIndex(icua.Item_Component_Use__r.Item__r.Record_Type_Description__c, icua.Stage__c) != am_Stage.getLastStageIndex(icua.Item_Component_Use__r.Item__r.Record_Type_Description__c) && 
              am_Stage.getStageIndex(icua.Item_Component_Use__r.Item__r.Record_Type_Description__c, icua.Stage__c) <= icua.Item_Component_Use__r.Item__r.Build_Stage_Index__c &&
              icua.Sprint__r.Sequence__c < currentSprint){ 
          //  if current stage is build stage only add if incomplete
          if (am_Stage.getStageIndex(icua.Item_Component_Use__r.Item__r.Record_Type_Description__c, icua.Stage__c) == icua.Item_Component_Use__r.Item__r.Build_Stage_Index__c){
            if (icua.Quantity_Remaining__c != 0 ){
              queue.add(new am_BacklogQueueElement(icua));
            }
          } else {
            queue.add(new am_BacklogQueueElement(icua));
          }
      	}
      } 
      
	  //  transfer set to list
  	  for (Id ids : idItemsWithAuditsUses)
   		listIdItemsWithAuditsUses.add(ids);

	   	//  get item component uses for items with no audits
  	  List<Id> idItemsWithoutAudits = new List<Id>();
 	  List<Item_Component_Use__c> componentUses = am_ItemComponentUse.getItemComponentUseNotIn(searchArguments, listIdItemsWithAuditsUses);
	  for (Item_Component_Use__c icu : componentUses){
  	   	idItemsWithAuditsUses.add(icu.Item__c); 
    	if (am_Stage.getStageIndex(icu.Item__r.Record_Type_Description__c, icu.Stage__c) != am_Stage.getLastStageIndex(icu.Item__r.Record_Type_Description__c) && 
    	  am_Stage.getStageIndex(icu.Item__r.Record_Type_Description__c, icu.Stage__c) <= icu.Item__r.Build_Stage_Index__c){
 	      queue.add(new am_BacklogQueueElement(icu));
   	  	}
	  } 
     
  	  for (Id ids : idItemsWithAuditsUses)
 	  	 listIdItemsWithAuditsUses.add(ids);
	}
    
	//  setup conditions if item based backlog and processing above skipped
    
  	//  get item without components
  	List<Progress__c> items = am_Item.getItems(searchArguments, listIdItemsWithAuditsUses);
  	List<Activity__c> activities = am_Activity.getActivitiesLatest(items);
  	
    //  create map to test activities for items
    Map<Id, Activity__c> mapActivities = new Map<Id, Activity__c>();
    for (Activity__c act : activities){
      mapActivities.put(act.Item__c, act); 
    }
    
  	for (Progress__c i : am_Item.getItems(searchArguments, listIdItemsWithAuditsUses)){
      //  conditions are: not the last stage; less than current build stage; not in the current sprint; 
      //  not finished if in same build stage
      if (aBasis == 'level'){
          queue.add(new am_BacklogQueueElement(i)); 	
      } else if (mapActivities.get(i.Id) != null){
        if (am_Stage.getStageIndex(mapActivities.get(i.Id).Item__r.Record_Type_Description__c, mapActivities.get(i.Id).Stage__c) != 
        am_Stage.getLastStageIndex(mapActivities.get(i.Id).Item__r.Record_Type_Description__c) 
        && am_Stage.getStageIndex(mapActivities.get(i.Id).Item__r.Record_Type_Description__c, mapActivities.get(i.Id).Stage__c) <= mapActivities.get(i.Id).Item__r.Build_Stage_Index__c 
//        && mapActivities.get(i.Id).Sprint_Item__r.Sprint__r.Sequence__c < currentSprint
        ){ 
          //  if current stage is build stage only add if not finished
          if (am_Stage.getStageIndex(mapActivities.get(i.Id).Item__r.Record_Type_Description__c, mapActivities.get(i.Id).Stage__c) == mapActivities.get(i.Id).Item__r.Build_Stage_Index__c){
            if (mapActivities.get(i.Id).Status__c != 'Finished' ){ 
              queue.add(new am_BacklogQueueElement(i));
            } 
          } else {
            queue.add(new am_BacklogQueueElement(i));
          }
        }
      } else if (am_Stage.getStageIndex(i.Record_Type_Description__c, i.Stage__c) != am_Stage.getLastStageIndex(i.Record_Type_Description__c) && 
    	am_Stage.getStageIndex(i.Record_Type_Description__c, i.Stage__c) <= i.Build_Stage_Index__c){ 
          queue.add(new am_BacklogQueueElement(i)); 
      }
  	}


  	//  get unresolved issue items 
  	for (Issue_Item__c ii : am_IssueItem.getIssueItemsOpen(searchArguments)){
      for (am_BacklogQueueElement bi : queue){
        //  add issue to record
        if (bi.itemID == ii.Item__c){
          bi.issueTitle.add(ii.Issue_Title__c);
          bi.issue.add(ii);
        }  
      } 
    }

    queue.sort();

    return queue;
  }
}