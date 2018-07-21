public class am_ItemTriggerHandler extends am_TriggerHandler{ 
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              17/8/2016    
   *  Modified by:      
   *  Date Modified:     
   *
   *  Description:       Extends the generic TriggerHandler class to provide specific functionality
   *                
   ***********************************************************************************************/  

  public am_ItemTriggerHandler() {
  }
 
  protected override void afterUpdate() {
  }  

  protected override void beforeUpdate() {
    am_item.updateStageIndex(Trigger.new);
  }

  protected override void beforeInsert() {
    am_item.updateStageIndex(Trigger.new);
  }
  protected override void afterDelete() {
  }
    
}