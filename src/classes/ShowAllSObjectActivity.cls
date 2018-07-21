public class ShowAllSObjectActivity {
  Id sObjectId;

  
  public list<Task> tasklist{get;set;}
  
  public ShowAllSobjectActivity(){
   sObjectId = ApexPages.currentPage().getParameters().get('Id');
   String sObjectType = sObjectId.getSObjectType().getDescribe().getName();
   String selectClause = '';
   
   if(sObjectId !=null ){
      Set<Id> ItemSet = new Set<Id>();

      for(Progress__c item :[Select Id from Progress__c WHERE Project__c=:sObjectId])
      {
        ItemSet.add(item.Id);
      } 

      if(sObjectType =='Project__c' ){
        selectClause = 'SELECT id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,LastModifiedDate,Owner.Name ' + 
                 'FROM Task WHERE WhatID=:sObjectId OR whoId=:sObjectId ' +
                 'OR WhatID IN :ItemSet OR whoId IN :ItemSet ' +
                 'ORDER BY Status ASC, ActivityDate DESC';
      }
      else {
        selectClause = 'SELECT id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,LastModifiedDate,Owner.Name ' +
                 'FROM Task WHERE WhatID=:sObjectId OR whoId=:sObjectId ' +
                 'OR WhatID IN :ItemSet OR whoId IN :ItemSet ' +
                 'ORDER BY Status ASC, ActivityDate DESC';
      }   
      
      tasklist= Database.query(selectClause);
    }
  }

  public PageReference cancel() {
    PageReference ldPage = new PageReference('/'+sObjectId);
    ldPage.setRedirect(true);
    return ldPage;
  }
}