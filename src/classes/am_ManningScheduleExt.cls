public class am_ManningScheduleExt { 
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          12/10/2016 
   *  Modified by:
   *  Date Modified:  
   * 
   *  Description:   Handles page functionality for Manning Schedule.
   *            
   ***********************************************************************************************/  
     
  private ApexPages.StandardController standardController;
  private ApexPages.StandardSetController standardSetController;
  public Boolean SetCalled;
  
    
  public am_ManningScheduleExt(ApexPages.StandardController Controller){
    standardController = Controller;
    SetCalled = False;
  }  

  public am_ManningScheduleExt(ApexPages.StandardSetController SetController){
    standardSetController = SetController;
    SetCalled = True;
  }

  public PageReference pageOnLoad(){
    Manning_schedule.Upsert_Manning_Schedules();
    if (SetCalled == True)
      return standardSetController.save();   
    else
      return standardController.save();   
  }

  public PageReference pageHandler(){
    //  Provide function to direct all page actions 
     

    return null;
  }

}