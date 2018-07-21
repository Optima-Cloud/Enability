public class am_ActivityTriggerHandler extends am_TriggerHandler{ 
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              17/8/2016    
   *  Modified by:      
   *  Date Modified:     
   *
   *  Description:       Extends the generic TriggerHandler class to provide specific functionality
   *                
   ***********************************************************************************************/  

  public am_ActivityTriggerHandler() {
  }
 
  protected override void afterUpdate() {
//    am_Activity.updateActivity(Trigger.new, 'edit'); 
    am_Activity.updateStatusStage(Trigger.new); 
  }  

  protected override void afterDelete() {
//    am_Activity.updateActivity(Trigger.new, 'Remove'); 
    am_Activity.updateStatusStage(Trigger.new); 
  }
    
}