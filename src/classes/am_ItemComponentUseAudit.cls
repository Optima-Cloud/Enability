public class am_ItemComponentUseAudit {
  /***********************************************************************************************
   *  Written by:   David Strangward 
   *  Date:         17/8/2016
   *  Modified by:
   *  Date Modified: 
   *
   *  Description:  Handles everything related to component use audits.
   *                The Item Component Use only contains the current count and status
   *                All history is contained in the audit log which is used to generate ITPs.
   *                Method to add audit records related item component use.
   ***********************************************************************************************/  

  public static List<ItemComponentUseAudi__c> getItemComponentAuditUsesSprint(am_UniversalSearchArguments aSearchArguments){ 
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
      //  selection is not sprint based
      //  get the latest audits only if not sprint based
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
    } else {
      //  selection is sprint based
      returnAudits = listAudits;

      //  filter out audits at a stage later than the build stage
      List<ItemComponentUseAudi__c> currentAudits = returnAudits.clone();
      for (Integer i=currentAudits.size() - 1; i >= 0; i--){
        if (am_Stage.getStageIndex(currentAudits[i].Item_Component_Use__r.Item__r.Record_Type_Description__c, currentAudits[i].Stage__c) > 
          currentAudits[i].Item_Component_Use__r.Item__r.Build_Stage_Index__c){
          returnAudits.remove(i);
        }   
      }
    }
                
    return returnAudits;
  } 
 
  public static void addItemComponentUseAudit(List<Item_Component_Use__c> aitemComponentUses, String aSprint,
                                              List<Sprint_Items__c> aSprintItems){ 
    //  add an audit record for the passed ItemComponentUse

    Map<Id, Sprint_Items__c> sprintItems = new Map<Id, Sprint_Items__c>();
    for (Sprint_Items__c sp :aSprintItems)
        sprintItems.put(sp.Item__c, sp); 

    //  update status audit file with latest changes
    List<ItemComponentUseAudi__c> tempItemComponentUseAudits = new List<ItemComponentUseAudi__c>();
    For (Item_Component_Use__c icu :aitemComponentUses){
      ItemComponentUseAudi__c tempItemComponentUseAudit = new ItemComponentUseAudi__c();
      tempItemComponentUseAudit.Item_Component_Use__c = icu.Id;
      tempItemComponentUseAudit.Sprint__c = Id.valueOf(aSprint); 
      tempItemComponentUseAudit.Sprint_Item__c = sprintItems.get(icu.Item__c).Id;
      tempItemComponentUseAudit.Sprint_Start_Stage__c = icu.Stage__c;
      tempItemComponentUseAudit.Sprint_Start_Number_Started__c = icu.Number_Started__c;
      tempItemComponentUseAudit.Sprint_Start_Number_Finished__c = icu.Number_Finished__c;
      //  if the starting stage, progress to miniumu stage
      if (am_Stage.checkMinStage(icu.Stage__c, icu.Item__r.Stage_Type__c)) 
        tempItemComponentUseAudit.Stage__c = am_Stage.getNextStage(icu.Item__r.Stage_Type__c, icu.Stage__c);
      else
        tempItemComponentUseAudit.Stage__c = icu.Stage__c;
      //  if new stage, reset counter if not finished
      if (icu.Quantity_Remaining__c == 0 && tempItemComponentUseAudit.Stage__c != 'Completed'){
        tempItemComponentUseAudit.Quantity_Remaining__c = icu.Number_Finished__c;
        tempItemComponentUseAudit.Number_Finished__c = 0; 
        tempItemComponentUseAudit.Number_Started__c = 0; 
        tempItemComponentUseAudit.Stage__c = am_Stage.getNextStage(icu.Item__r.Stage_Type__c, tempItemComponentUseAudit.Stage__c);
      } else if (tempItemComponentUseAudit.Stage__c == 'Completed'){
      	//  do nothing
      } else {
        tempItemComponentUseAudit.Quantity_Remaining__c = icu.Quantity_Remaining__c;
        tempItemComponentUseAudit.Number_Started__c = icu.Number_Started__c; 
        tempItemComponentUseAudit.Number_Finished__c = icu.Number_Finished__c; 
      }

      //  if completed set 0 all counters (for new audits and if just moved to completed)
      if (tempItemComponentUseAudit.Stage__c == 'Completed'){
        tempItemComponentUseAudit.Quantity_Remaining__c = 0;
        tempItemComponentUseAudit.Number_Started__c = 0; 
        tempItemComponentUseAudit.Number_Finished__c = icu.Quantity__c; 
      }
            
      tempItemComponentUseAudits.add(tempItemComponentUseAudit);
    }     
    insert tempItemComponentUseAudits;
  }   

  public static void removeItemComponentUseAudit(List<Progress__c> aItems, String aSprint){ 
    //  removes all audit records associated with a sprint for an item
    List<ItemComponentUseAudi__c> tempItemComponentUseAudits = [SELECT Id FROM ItemComponentUseAudi__c
                                                                WHERE Item_Component_Use__r.Item__c IN :aItems
                                                                AND Sprint__c = :aSprint];
    delete tempItemComponentUseAudits;
  }   
  
  public static List<ItemComponentUseAudi__c> getItemComponentAuditUses(am_UniversalSearchArguments aSearchArguments){ 
    //  gets the list of ItemComponentAudits once an item is selected in the dropdown item list
    List<ItemComponentUseAudi__c> listItemComponentAudits = new List<ItemComponentUseAudi__c>();
    List<ItemComponentUseAudi__c> listLatestAudits = new List<ItemComponentUseAudi__c>();
    //  create where clause based on arguments
    String whereClause;
    String sid;
    Id qid;
    if (String.isNotBlank(aSearchArguments.sprint)){
      qid = aSearchArguments.sprintId;
      whereClause = 'WHERE Sprint__c = :qid ';
    } else if (String.isNotBlank(aSearchArguments.project)){
      qid = aSearchArguments.projectId;
      if (String.isNotBlank(aSearchArguments.level)){
        sid = aSearchArguments.level;
        whereClause = 'WHERE Sprint__r.Project__c = :qid AND Sprint_Item__r.Item__r.Level__c = :sid ';
      } else
        whereClause = 'WHERE Sprint__r.Project__c = :qid ';     
    } else if (String.isNotBlank(aSearchArguments.aggregateItem)){
        sid = aSearchArguments.aggregateItem;
        whereClause = 'WHERE Sprint__r.Project__c = :qid AND Sprint_Item__r.Item__r.Aggregate_Item__c = :sid ';
    } else if (String.isNotBlank(aSearchArguments.item)){
      qid = aSearchArguments.itemId;
      whereClause = 'WHERE Sprint_Item__r.Item__c = :qid ';
    } 

    //  query database
    if (String.isNotBlank(whereClause)){
      String query = 'SELECT Item_Component_Name__c, Quantity_Remaining__c, Number_Finished__c, Sprint_Item__c,  ' +
              'Number_Started__c, Stage__c, Quantity__c, Item_Component_Use__r.Item__c, Item_Component_Use__c, ' +
              'Item_Component_Use__r.Item_Component__c, Item_Component_Use__r.Item__r.Name, ' +
              'Item_Component_Use__r.Item__r.Build_Stage__c, Item_Component_Use__r.Item__r.Stage_Index__c, ' + 
              'Item_Component_Use__r.Item__r.Build_Stage_Index__c, Item_Component_Use__r.Item__r.Aggregate_Item__c, ' +
              'Item_Component_Use__r.Item__r.Record_Type_Description__c, Item_Component_Use__r.Item__r.Project__c, ' + 
              'Sprint__r.Sequence__c ' +
              'FROM ItemComponentUseAudi__c ' + whereClause + 'ORDER BY Item_Component_Name__c';
      listItemComponentAudits = Database.query(query); 
    } 

    //  create map of components with list of audits to manipulate
    //  create the map without audits
    Map<Id, List<ItemComponentUseAudi__c>> mapAudits = new Map<Id, List<ItemComponentUseAudi__c>>();
    List<ItemComponentUseAudi__c> listTempAudit = new List<ItemComponentUseAudi__c>();
    for (ItemComponentUseAudi__c icua : listItemComponentAudits)
      mapAudits.put(icua.Item_Component_Use__c, listTempAudit); 

    //  add audits to map list for each component
    List<ItemComponentUseAudi__c> tempAudit;
    for (ItemComponentUseAudi__c icua : listItemComponentAudits){
      tempAudit = new List<ItemComponentUseAudi__c>(mapAudits.get(icua.Item_Component_Use__c));
      tempAudit.add(icua);
      mapAudits.put(icua.Item_Component_Use__c, tempAudit);
    }
      
    //  cycle through map and keep only the latest audit
    ItemComponentUseAudi__c latestAudit;
    for (Id cmpId : mapAudits.keySet()){
      //  check component not already process
      for (ItemComponentUseAudi__c icua : mapAudits.get(cmpId)){
        if (latestAudit == null)
       	  latestAudit = icua;
        else if (icua.Sprint__r.Sequence__c > latestAudit.Sprint__r.Sequence__c)
          latestAudit = icua;
      }
      listLatestAudits.add(latestAudit);
      latestAudit = null;
    }
    return listLatestAudits;
  } 
 
 
  
/*  
  public static void addComponent(){
//  temporary utility to migrate to single sprint audit records per item component use
    List<ItemComponentUseAudi__c> tempItemComponentUseAudits = new List<ItemComponentUseAudi__c>();

    List<Item_Component_Use__c> allComponents = [select id, Current_Stage__c, Item__c, Number_Finished__c,
                                       Quantity__c, Quantity_Remaining__c from Item_Component_Use__c];

    for(Sprint_Items__c si :[select Sprint__c, Id, Item__c,Sprint_Item_Stage__c from Sprint_Items__c]){
      for (Item_Component_Use__c icu :allComponents){
        if (icu.Item__c == si.Item__c){
          ItemComponentUseAudi__c tempItemComponentUseAudit = new ItemComponentUseAudi__c();
          tempItemComponentUseAudit.Item_Component_Use__c = icu.Id; 
          tempItemComponentUseAudit.Sprint__c = si.Sprint__c; 
          tempItemComponentUseAudit.Sprint_Item__c = si.Id;
          tempItemComponentUseAudit.Stage__c = si.Sprint_Item_Stage__c;
          tempItemComponentUseAudit.Number_Finished__c = 0;
          tempItemComponentUseAudit.Number_Finished__c = icu.Number_Finished__c;
          tempItemComponentUseAudit.Quantity_Remaining__c = icu.Quantity__c - tempItemComponentUseAudit.Number_Finished__c;
          tempItemComponentUseAudits.add(tempItemComponentUseAudit);
        }
        
      }
    }
    insert tempItemComponentUseAudits;
    List<ItemComponentUseAudi__c> ItemComponentUseAudits = [select id, Stage__c, Quantity_Remaining__c,Item_Component_Use__c, Number_Finished__c from ItemComponentUseAudi__c];
//    delete ItemComponentUseAudits;
    
  }
*/  
}