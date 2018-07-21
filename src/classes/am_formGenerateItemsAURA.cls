public with sharing class am_formGenerateItemsAURA {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          16/09/2017
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Handles all requests to salesforce from generating project items.
   *                 
   */
   
   @AuraEnabled 
   public static Project__c getProjectDetails(String aProject){
   	  return am_ProjectExt.getProjectDetails(aProject); 
   }
    
}