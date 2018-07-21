global class IssueItemsController {
  /***********************************************************************************************
    *  Written by:  David Strangward
    *  Date:  27/7/2016
    *  Modified by:
    *  Date Modified:
    *
    *  Description:  Handles the controls for the visualforce pages called from an activity and listing
    *                issues and then automatically creating a link item for between the issue and the item
    *                with an open status.
   ***********************************************************************************************/  
   
    Public List<Issue__c> selectedIssues {get;set;}
    Public List<Sprint_Items__c> selectedSprintItems {get;set;}
    Public List<Progress__c> selectedItems {get;set;}
    private ApexPages.StandardController standardController;
    Public string issue  {set; get;}
    Public String retURL {set; get;}
    List<Progress__c> projectIDs; 
    List<Issue__c> projectIssueIDs;
    List<IssueWrapper> selectedIssuesList = new List<issueWrapper>();
    List<Issue__c> selectIssues = new List<Issue__c>();
    List<ItemWrapper> selectedItemsList = new List<itemWrapper>();
    List<Progress__c> selectItems = new List<Progress__c>();
    
    public IssueItemsController(SObject callingObject, String callFrom){
    }

    public IssueItemsController(){
    }

    public void getIssue(Issue__c aIssue){
        selectIssues = [Select Id, Name, Status__c from Issue__c WHERE Title__c = :aIssue.Title__c];
    }

    public IssueItemsController(ApexPages.StandardController standardController){

      String currentObjectName = standardController.getRecord().getSObjectType().getDescribe().getName();
      retURL = ApexPages.currentPage().getParameters().get('retURL');

      //  get issues related to the activity or item selected
      if(currentObjectName == 'Activity__c' || currentObjectName == 'Progress__c'){
        if(currentObjectName == 'Activity__c'){
          Activity__c record = (Activity__c)standardController.getRecord();
          List<Sprint_Items__c> sprintItemIDs = [Select Id from Sprint_Items__c where Id IN 
                                                (Select Sprint_Item__c from Activity__c where id 
                                                = :record.Id)];
          projectIDs = [Select Project__c, Id from Progress__c where Id IN 
                       (Select Item__c from Sprint_Items__c where id in :sprintItemIDs)];
        } else {
          Progress__c record = (Progress__c)standardController.getRecord();
          projectIDs = [Select Project__c from Progress__c where id = :record.Id];
        } 
        selectedIssues  = [Select Title__c, Description__c from Issue__c 
                           WHERE Project__c = :projectIDs[0].Project__c AND (Status__c != 'Cancelled' OR Status__c != 'Closed')];
      } 
      else if (currentObjectName == 'Issue__c'){
        //  get items related to the issue selected
        Issue__c record = (Issue__c)standardController.getRecord();
        projectIssueIDs = [Select Project__c from Issue__c where id = :record.Id];
        selectedItems = [SELECT Name, Level__c, Wing__c FROM Progress__c 
                         WHERE Project__c = :projectIssueIDs[0].Project__c];
      }    
    } 


    public static List<Issue_Item__c >getIssueItems(am_UniversalSearchArguments aSearchArguments){
    List<Issue_Item__c> listIssueItems = new List<Issue_Item__c>();
    String whereClause;
    Id qid; 
    if (String.isNotBlank(aSearchArguments.project)){
      qid = Id.valueOf(aSearchArguments.project);
      whereClause = 'Item__r.Project__r.Id = :qid ';
      if (String.isNotBlank(aSearchArguments.level)){
        whereClause =+ 'AND Item__r.Level__c = :aSearchArguments.level ';
      }      
    } else if (String.isNotBlank(aSearchArguments.item)){
      qid = Id.valueOf(aSearchArguments.item);
      whereClause = 'Item__c = :qid ';
    } 

    //  query database
    if (String.isNotBlank(whereClause)){
      String query = 'SELECT Id, Item_Name__c, Title__c, Status__c, Issue_Notifications__r.Description__c, Resolution__c, Resolved__c ' +
                     'FROM Issue_Item__c ' +
                     'WHERE Issue_Notifications__r.Type__c = \'Site Issue\' AND Resolved__c = false  AND '  + 
//  3/7/17 refactored                     'WHERE Status__c = \'Open\' AND Issue_Notifications__r.Type__c = \'Site Issue\' AND Resolved__c = false  AND '  + 
                     whereClause + 'ORDER BY Item_Name__c ';  
      listIssueItems = Database.query(query); 
    } 
    return listIssueItems;
    
/*  refactored with dynamic soql    
      if (aProject != null){
      //  get open site based issues
        return [SELECT Id, Item_Name__c, Title__c, Status__c, Issue_Notifications__r.Description__c, Resolution__c, Resolved__c FROM Issue_Item__c 
                WHERE Item__r.Project__r.Id = :aProject AND Status__c = 'Open'
                AND Issue_Notifications__r.Type__c = 'Site Issue' AND Resolved__c = false ORDER BY Item_Name__c];   	
      } else if (aItem != null){
        return [SELECT Id, Item_Name__c, Title__c, Status__c, Issue_Notifications__r.Description__c, Resolution__c, Resolved__c 
                FROM Issue_Item__c 
                WHERE Item__c = :aItem AND Status__c = 'Open'
                AND Issue_Notifications__r.Type__c = 'Site Issue' AND Resolved__c = false ORDER BY Item_Name__c];   	
      	
      }  else {
        return null;
      }  
*/      
    } 

    public static void saveIssueItems(List<Issue_Item__c> aIssueItem){
      //  update open site based issues
      update aIssueItem;   	
    }

    public static void triggerAction(String callAction, List<SObject> callObject){
        //  method called from trigger
        if (callAction == 'StatusToClosed'){
            //  update the issue status to closed
            updateIssueItemStatus(callObject);    
        } 
    }

    private static void updateIssueItemStatus(List<Issue__c> selectedIssues){
        //  update all the issue items related to the identified issue to closed.
        List<Issue_Item__c> tempIssueItemList = new List<Issue_Item__c>();
        List<id> itemIDS = new List<id>();
        for(Issue__c i : selectedIssues){
            itemIDS.add(i.id);
        }  
               
        for (Issue_Item__c Items : [SELECT Id, Status__c from Issue_Item__c where Issue_Notifications__c IN :itemIDS]){
            Issue_Item__c tempIssueItem = new Issue_Item__c();
            tempIssueItem.id = Items.id;
            tempIssueItem.Status__c = 'Closed';
            tempIssueItemList.add(tempIssueItem);
        }
        update tempIssueItemList;
    }
        
    public PageReference createItemIssue(){
        //  for all of the issues selected in the wrapper, iterate through and create a junction object to each item selected.
        Ticked();

        addIssueItem();

        PageReference pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference createItemIssueFromIssue(){
        //  for all of the items selected in the wrapper, iterate through and create a junction object to each item selected.
        List<Issue_Item__c> tempIssueItemList = new List<Issue_Item__c>();
        TickedItem();

        for (Progress__c listItem : selectItems ){
            for (Issue__c issues : projectIssueIDs){
                Issue_Item__c tempIssueItem = new Issue_Item__c();
                tempIssueItem.Issue_Notifications__c = issues.Id;
                tempIssueItem.Item__c = listItem.Id;
                tempIssueItem.Status__c = 'Open';
                tempIssueItemList.add(tempIssueItem);
            }
        }  
        insert tempIssueItemList;

        PageReference pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }

    public void createItemIssueFromIssue(Id aItemID, Issue__c aIssue){
      am_IssueItem.createItemIssueFromIssue(aItemID, aIssue);
    }

    public void addIssueItem(){
        List<Issue_Item__c> tempIssueItemList = new List<Issue_Item__c>();
        for (Issue__c listIssue : selectIssues ){
            for (Progress__c items : projectIDs){
                Issue_Item__c tempIssueItem = new Issue_Item__c();
                tempIssueItem.Issue_Notifications__c = listIssue.Id;
                tempIssueItem.Item__c = items.Id;
                tempIssueItem.Status__c = 'Open';
                tempIssueItemList.add(tempIssueItem);
            }
        }  
        insert tempIssueItemList;
    }    
    public List<IssueWrapper> getIssues(){
        for (Issue__c Issue : selectedIssues )
            selectedIssuesList.add(new IssueWrapper(Issue));
            
        return selectedIssuesList;
    }    

    public List<ItemWrapper> getItems(){
        for (Progress__c Item : selectedItems )
            selectedItemsList.add(new ItemWrapper(Item));
            
        return selectedItemsList;
    }    
         
    public void Ticked(){
        selectIssues.clear();
        for (IssueWrapper IW : selectedIssuesList)
            if (IW.selected == true)
                selectIssues.add(IW.Issue);
    }

    public void TickedItem(){
        selectItems.clear();
        for (ItemWrapper IW : selectedItemsList)
            if (IW.selected == true)
                selectItems.add(IW.Item);
    }

    public class IssueWrapper{
        public Boolean selected {get; set;}
        Public Issue__c Issue {get;set;}
        public IssueWrapper(Issue__c I){
            Issue = I;
            selected = false;
        }
    }

    public class ItemWrapper{
        public Boolean selected {get; set;}
        Public Progress__c Item {get;set;}
        public ItemWrapper(Progress__c I){ 
            Item = I;
            selected = false; 
        }
    }

    // Get object name from it's ID (first 3 letters characters)
    public static string getObjectNameById(string parent_id)
    {
        Schema.DescribeSObjectResult object_desc = null;
    
        // Search every object in the getGlobalDescribe() map to check key prefixes
        for( Schema.SObjectType t : Schema.getGlobalDescribe().values() ){
              Schema.DescribeSObjectResult descr = t.getDescribe();
       
              if (descr.getKeyPrefix() != null)
              {
                   // If the Id starts with this objects prefix, then we know the type
                   if( parent_id.startsWith( descr.getKeyPrefix() ))
                   {
                       object_desc = descr;
                        break;
                   }
             }
         }
         return object_desc.getLocalName();
    }
}