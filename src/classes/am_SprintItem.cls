public class am_SprintItem {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          2/9/2016 
   *  Modified by:
   *  Date Modified: 
   * 
   *  Description:   Handles .
   *            
   ***********************************************************************************************/  
 
   public static void removeSprintItems(List<Sprint_Items__c> selectedSprintItems){
    //  invoked to set leave status unchanged and remove from sprint
    List<Progress__c> tempItemList =  new List<Progress__c>();
 
    for(Sprint_Items__c selectedSprintItem :selectedSprintItems){
      Progress__c tempItem = new Progress__c();        
      tempItem.Id = selectedSprintItem.Item__c; 
      tempItem.Item_Status_New__c = '';
      tempItem.Stage__c = selectedSprintItem.Item_Stage_at_Sprint_Start__c;
      tempItemList.add(tempItem);
    }  

    //  reset item component use records associated with the sprint
    am_ItemComponentUse.resetItemComponentUse(selectedSprintItems); 

    delete selectedSprintItems;

    //  update the items related to the selected sprint items if status changed in sprint
    update tempItemList;

    //  remove any audit records associated with the sprint
    am_ItemComponentUseAudit.removeItemComponentUseAudit(tempItemList, selectedSprintItems[0].Sprint__c);
            
  }

/*     
     public static void updateSprintItemHoursEstimated(List<Sprint_Items__c> sprintItemTrigger){
        // Estimated hours of work to move the item from current status to completed.

        Map<Id, Sprint_Items__c> tempSprintItem = new Map<Id, Sprint_Items__c>([Select Id, Name, Item__r.Project__r.Project_Type__c,Item__r.Hours_Estimated__c, 
                Item__r.Project__r.Start__c, Item__r.Project__r.Stage_Develop__c, Item__r.Project__r.Stage_Implement__c,
                Item__r.Project__r.Roughin__c, Item__r.Project__r.Cutout__c, Item__r.Project__r.Fitoff__c, Item__r.Project__r.Commission__c, 
                Item__r.Hours_Earned__c 
                from Sprint_Items__c where Id IN :sprintItemTrigger]);
        List<Sprint_Items__c> listSprintItemsToUpdate = new List<Sprint_Items__c>();

        For (Sprint_Items__c sprintItem : sprintItemTrigger ){
            Sprint_Items__c sprintItemsToUpdate = new Sprint_Items__c();
            sprintItemsToUpdate = tempSprintItem.get(sprintItem.Id);
            if(sprintItemsToUpdate.Item__r.Project__r.Project_Type__c == 'Electrical'){
                if (sprintItem.Sprint_Item_Stage__c == 'Roughin'){ 
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Roughin__c
                         * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000; 
                    else
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Roughin__c / 100;
                } 

                if (sprintItem.Sprint_Item_Stage__c == 'Cutout'){  
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Cutout__c
                        * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000;
                    else       
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Cutout__c / 100; 
                }
            
                if (sprintItem.Sprint_Item_Stage__c == 'Fitoff'){ 
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Fitoff__c 
                        * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000;
                    else       
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Fitoff__c / 100;
                } 

                if (sprintItem.Sprint_Item_Stage__c == 'Commission'){
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Commission__c
                         * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000;
                    else
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Commission__c / 100; 
                }
                if (sprintItem.Sprint_Item_Stage__c == 'In Progress'){
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Start__c / 100;
                    else
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c; 
                }
            }

            else { 
                if (sprintItem.Sprint_Item_Stage__c == 'Develop'){
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Stage_Develop__c
                         * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000; 
                    else
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Stage_Develop__c / 100; 
                }

                if (sprintItem.Sprint_Item_Stage__c == 'Implement'){ 
                    if (sprintItem.Item_Status_at_Sprint_Start__c == 'Started')
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Stage_Implement__c
                         * sprintItemsToUpdate.Item__r.Project__r.Start__c / 10000;
                    else    
                        sprintItemsToUpdate.Sprint_Hours_Estimated__c = sprintItemsToUpdate.Item__r.Hours_Estimated__c * sprintItemsToUpdate.Item__r.Project__r.Stage_Implement__c / 100;
                } 
            }
            
            listSprintItemsToUpdate.add(sprintItemsToUpdate);
        } 
        update listSprintItemsToUpdate;
    }    
*/
}