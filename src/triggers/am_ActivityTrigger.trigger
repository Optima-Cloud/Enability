trigger am_ActivityTrigger on Activity__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              17/8/2016    
   *  Modified by:      
   *  Date Modified:  
   *
   *  Description:       Standard trigger that calls object specific handler
   *                
   ***********************************************************************************************/  
/*  
  if (!test.isRunningTest()) 
    new am_ActivityTriggerHandler().run();    
*/
}