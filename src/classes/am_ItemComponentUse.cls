public class am_ItemComponentUse {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          14/8/2016
   *  Modified by:   
   *  Date Modified:
   *
   *  Description:   Handles everything related to component uses.
   *                 The Item Component Use only contains the current count and status
   *                 All history is contained in the audit log which is used to generate ITPs.
   *                 Method to advance to next stage and reset counters if required.
   ***********************************************************************************************/  
 
  public static void setStage(List<Progress__c> selectedItems){
    //  takes the items, looks up the component use audits to determine the status, if all the items audits are completed, 
    //  advances it to the next stage and resets remaining to zero, always advances pending to next stage   
    //  update status audit file with latest changes
    if (selectedItems.size() > 0){
      List<ItemComponentUseAudi__c> itemComponentUseAudits = [SELECT Item_Component_Use__r.Id, Stage__c, Quantity_Remaining__c, Number_Finished__c, 
                                                              Number_Started__c
                                                              FROM ItemComponentUseAudi__c 
                                                              WHERE Item_Component_Use__r.Item__r.Id IN :selectedItems ORDER BY Id ASC];
      String stageType = selectedItems[0].Stage_Type__c;  
      Map<Id, Item_Component_Use__c> tempItemComponentUses = new Map<Id, Item_Component_Use__c>();  
      List<Item_Component_Use__c> tempItemComponentUsesUnique = new List<Item_Component_Use__c>();  
      //  If the item has been added to a sprint and the stage has progressed update the item component use to new stage
      For (ItemComponentUseAudi__c icu :itemComponentUseAudits){
          Item_Component_Use__c tempItemComponentUse = new Item_Component_Use__c();   
          tempItemComponentUse.Id = icu.Item_Component_Use__r.Id;
          tempItemComponentUse.Stage__c = icu.Stage__c;
          tempItemComponentUse.Number_Finished__c = icu.Number_Finished__c;
          tempItemComponentUse.Number_Started__c = icu.Number_Started__c;
          tempItemComponentUses.put(tempItemComponentUse.Id, tempItemComponentUse); 
      }

      // put deduplicated map into list to update records
      for (Id recordId :tempItemComponentUses.keySet())
      tempItemComponentUsesUnique.add(tempItemComponentUses.get(recordId)); 
      
      update tempItemComponentUsesUnique;
    }
  }
 
   public static void resetItemComponentUse(List<Sprint_Items__c> selectedSprintItems){
    //  resets item component use stage to start of sprint
    List<Item_Component_Use__c> tempItemComponentList =  new List<Item_Component_Use__c>();
    Map<Id, Sprint_Items__c> tempItemAuditList =  new Map<Id, Sprint_Items__c>();
    
    //  get item ids
    List<Id> itemIds = new List<Id>();
    List<Id> sprintItemIds = new List<Id>();
    for (Sprint_Items__c si : selectedSprintItems){
      itemIds.add(si.Item__c);
      sprintItemIds.add(si.Id);
      tempItemAuditList.put(si.Id, si);
    }  
    for(ItemComponentUseAudi__c ic : [SELECT Id, Item_Component_Use__c, Sprint_Item__c,
                                      Sprint_Start_Number_Started__c, Sprint_Start_Number_Finished__c, Sprint_Start_Stage__c
                                      FROM ItemComponentUseAudi__c 
                                      WHERE ItemID__c IN :itemIds AND Sprint_Item__c IN :sprintItemIds]){
        Item_Component_Use__c tempItemComponentUse = new Item_Component_Use__c();        
        tempItemComponentUse.Id = ic.Item_Component_Use__c; 
        tempItemComponentUse.Stage__c = ic.Sprint_Start_Stage__c;
        tempItemComponentUse.Number_Started__c = ic.Sprint_Start_Number_Started__c;
        tempItemComponentUse.Number_Finished__c = ic.Sprint_Start_Number_Finished__c;
        tempItemComponentList.add(tempItemComponentUse); 
    }

    //  update the items related to the selected sprint items if status changed in sprint
    update tempItemComponentList;

  }


  public static List<Item_Component_Use__c> getItemComponentUseNotIn(am_UniversalSearchArguments aSearchArguments, List<Id> aItemIds){
    //  get item components for the given type excluding ones in the aItemIds list
    List<Item_Component_Use__c> listItemComponents = new List<Item_Component_Use__c>();
    String whereClause;
    String sid;
    Id qid;
    if (String.isNotBlank(aSearchArguments.project)){
      qid = aSearchArguments.projectId;
      if (String.isNotBlank(aSearchArguments.level)){
        sid = aSearchArguments.level;
        whereClause = 'Item__r.Project__c = :qid AND Item__r.Level__c = :sid ';
      } else
        whereClause = 'Item__r.Project__c = :qid ';
    } else if (String.isNotBlank(aSearchArguments.aggregateItem)){
        sid = aSearchArguments.aggregateItem;
        whereClause = 'WHERE Sprint__r.Project__c = :qid AND Sprint_Item__r.Item__r.Aggregate_Item__c = :sid ';
    } else if (String.isNotBlank(aSearchArguments.item)){
      qid = aSearchArguments.itemId;
      whereClause = 'Item__c = :qid ';
    } 

    //  query database
    if (String.isNotBlank(whereClause)){
      String query = 'SELECT Id, Item__c, Item__r.Name, Item_Component__r.Name, Stage__c, Number_Started__c, Number_Finished__c, Quantity__c, ' +
                     'Item__r.Stage_Index__c, Item__r.Build_Stage_Index__c, Item__r.Build_Stage__c, ' + 
                     'Item__r.Record_Type_Description__c, Item__r.Aggregate_Item__c ' +
                     'FROM Item_Component_Use__c WHERE Item__c NOT IN :aItemIds AND ' + whereClause + 'ORDER BY Item__r.Name';
      listItemComponents = Database.query(query); 
    }
 
    return listItemComponents;
  }


  public static String determineItemComponentStatus(List<Item_Component_Use__c> selectedItemComponentUses){
    //  if all the item components are completed, status = Finished, if some started = Started, otherwise Not Started.
    //  get the lowest status of all the item component uses for the component 
    String  statusSoFar = '';
    for (Item_Component_Use__c tempICU :selectedItemComponentUses){
      if((tempICU.Number_Finished__c == tempICU.Quantity__c) && (statusSoFar == 'Finished' || statusSoFar == ''))
        statusSoFar = 'Finished';
      else if (tempICU.Number_Finished__c > 0  || tempICU.Number_Started__c > 0 ){
        statusSoFar = 'Started';
        break;
      } else if ((tempICU.Number_Finished__c == 0 || tempICU.Number_Finished__c == null) && (statusSoFar == 'Finished' || statusSoFar == 'Started')) {
        statusSoFar = 'Started';
        break;
      }
      else if ((tempICU.Number_Finished__c == 0 || tempICU.Number_Finished__c == null)) 
        statusSoFar = 'Not Started';
    } 
    return statusSoFar;
  } 
 
    public static String getItemComponentMinStage(Map<Id, Item_Component_Use__c> itemComponentUses, Id itemComponentKey){ 
    //  for the item passed searches through all the component uses and returns the lowest stage found 
    String minStage = 'Commission';

    for(ID aID :itemComponentUses.keySet()){ 
      if (aID == itemComponentKey) 
       minStage = am_Stage.getMinStage(minStage, itemComponentUses.get(aID).Stage__c, itemComponentUses.get(aID).Item__r.Stage_Type__c);
    }  
    return minStage;
  } 
  
}