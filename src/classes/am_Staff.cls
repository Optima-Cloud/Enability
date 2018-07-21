public with sharing class am_Staff {

  @AuraEnabled 
  public static List<Staff__c> getStaff(){
    //  gets the list of ItemComponents once an item is selected in the dropdown item list 
    return [SELECT Name, Id FROM Staff__c WHERE Status__c = true];

  } 
    
}