trigger am_ItemTrigger on Progress__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              27/5/2017    
   *  Modified by:      
   *  Date Modified:  
   *
   *  Description:       Standard trigger that calls object specific handler
   *                
   ***********************************************************************************************/  
  
  if (!test.isRunningTest()) 
    new am_ItemTriggerHandler().run();  
}