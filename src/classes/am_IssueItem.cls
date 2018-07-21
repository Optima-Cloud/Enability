public with sharing class am_IssueItem {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          14/5/2017
   *  Modified by:   
   *  Date Modified:
   *
   *  Description:   Handles everything related to Issue Items uses.
   ***********************************************************************************************/  

  public static List<Issue_Item__c> getIssueItemsOpen(am_UniversalSearchArguments aSearchArguments){
  	//  gets items for specified components and excludes items if specified
    List<Issue_Item__c> listIssueItems = new List<Issue_Item__c>();
    Id qid;
    String qstring;

    String searchClause;
    if (String.isNotBlank(aSearchArguments.aggregateItem)){
        qstring = aSearchArguments.aggregateItem;
        searchClause = 'Item__r.Aggregate_Item__c = :qstring ';
    } else if (String.isNotBlank(aSearchArguments.item)){ 
      qid = aSearchArguments.item;
      searchClause = 'Item__c = :qid';
    } else if (String.isNotBlank(aSearchArguments.sprint)) {
      qid = aSearchArguments.sprint;
      searchClause = 'Item__c IN (SELECT Item__c FROM Sprint_Items__c WHERE Sprint__c = :qid)'; 
    } else if (String.isNotBlank(aSearchArguments.project)){
      qid = aSearchArguments.project;
      if (String.isNotBlank(aSearchArguments.level)) { 
        qstring = aSearchArguments.level;
        searchClause = 'Item__r.Project__c = :qid AND Item__r.Level__c = :qstring';
      } else {
        searchClause = 'Item__r.Project__c = :qid';
      }
    }
     
     //  query database
    if (String.isNotBlank(searchClause)){
      String query = 'SELECT Id, Issue_Title__c, Item__c, Resolved__c, Item__r.Name FROM Issue_Item__c WHERE Resolved__c = false AND ' + searchClause;
      listIssueItems = Database.query(query); 
    } 
 
    return listIssueItems;  	
  }   
    
  public static void createItemIssueFromIssue(Id aItemID, Issue__c aIssue){
    //  for item create a wrapper object and add junction object for creation from app
    Issue__c selectIssue = [Select Id, Name, Status__c from Issue__c WHERE Title__c = :aIssue.Title__c LIMIT 1];
    Issue_Item__c tempIssueItem = new Issue_Item__c();
    tempIssueItem.Issue_Notifications__c = selectIssue.Id;
    tempIssueItem.Item__c = aItemID; 
    tempIssueItem.Status__c = 'Open';
    try{
      insert tempIssueItem;
    } catch (DmlException e){}
    
  }    
   
}