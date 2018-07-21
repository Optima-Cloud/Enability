trigger am_ItemComponentUseTrigger on Item_Component_Use__c (before insert, before update, after insert, after update) {
  /***********************************************************************************************
   *  Written by:  David Strangward
   *  Date:  17/8/2016
   *  Modified by:
   *  Date Modified:
   *
   *  Description:  Standard trigger that calls object specific handler
   *                
   ***********************************************************************************************/  
   
  if (!test.isRunningTest()) 
    new am_ItemComponentUseTriggerHandler().run();
}