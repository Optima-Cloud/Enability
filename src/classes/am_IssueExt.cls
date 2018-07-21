public with sharing class am_IssueExt {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          14/1/2017 
   *  Modified by:   David Strangward
   *  Date Modified: 
   *                 Add method to get issues for project
   *  Description:   Handles .
   *            
   ***********************************************************************************************/  

  @AuraEnabled 
  public static List<Issue__c> getIssues(String aProject){
    //  gets the list of Issues once a project is selected in the dropdown item list
    return [SELECT Name, Id, Title__c, Description__c, Next_Step__c FROM Issue__c WHERE Project__c = :Id.valueOf(aProject)];
  } 


}