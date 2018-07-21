public class am_StaffProfilesExt { 
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          12/10/2016 
   *  Modified by:
   *  Date Modified:  
   * 
   *  Description:   Handles page functionality for Staff Profiles.
   *            
   ***********************************************************************************************/  
     
  private ApexPages.StandardController standardController;
  private ApexPages.StandardSetController standardSetController;
  public Boolean SetCalled;
  
    
  public am_StaffProfilesExt(ApexPages.StandardController Controller){
    standardController = Controller;
    SetCalled = False;
  }  

  public am_StaffProfilesExt(ApexPages.StandardSetController SetController){
    standardSetController = SetController;
    SetCalled = True;
  }

  public PageReference pageOnLoad(){
    am_StaffProfiles.updateProfileRates();
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