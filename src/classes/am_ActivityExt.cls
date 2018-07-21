public class am_ActivityExt {
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              17/8/2016    
   *  Modified by:      
   *  Date Modified:      
   * 
   *  Description:       Handles all aspects of Visualforce pages associated with Activites
   *                
   ***********************************************************************************************/  
  private ApexPages.StandardSetController standardSetController;
  private ApexPages.StandardController standardController;
  public Activity__c selectedActivity;
  public List<Activity__c> sprintActivities {set; get;}
  public Progress__c selectedItem {set; get;} 
  public List<activityWrapper> selectedActivityWrapper {get; set;}
  private List<Sprint__c> sprintIds;
  private List<Activity__c> activityIds;
  private String sprintId;
  public String callActionActivity {set; get;}
  public Boolean SetCalled;

  public am_ActivityExt(ApexPages.StandardController StandardController){
    callActionActivity = ApexPages.currentPage().getParameters().get('callAction');
    sprintActivities = [Select Id, Name, Status__c, Description__c, Due_By__c from Activity__c where Sprint_Item__c 
                          IN (Select Id FROM Sprint_Items__c where Sprint__c = :ApexPages.currentPage().getParameters().get('id'))];
    sprintId = StandardController.getId();
    loadActivityWrap();
    this.standardController = StandardController;
    SetCalled = False;
  }

  public am_ActivityExt(ApexPages.StandardSetController SetController){
    String type = SetController.getRecord().getSObjectType().getDescribe().getName();    
    if(type == 'Sprint__c'){
      sprintIds = SetController.getSelected();  	
      sprintId = sprintIds[0].Id;
    } else if (type == 'Activity__c'){ 
      activityIds = SetController.getSelected();  	
      sprintId = activityIds[0].Sprint_Item__c;
    }
    
    loadActivityWrap();
     
    callActionActivity = ApexPages.currentPage().getParameters().get('callAction');
    this.standardSetController = SetController;
    SetCalled = True;
  }
  
   public void loadActivityWrap(){ 
  	String fromClause = '';
  	//  create select string for whether working on list of activities or in the sprint review

    //  sprint review only include non item component activities
    fromClause = 'FROM Activity__c WHERE Sprint_Item__c ' +
                 'IN (Select Id FROM Sprint_Items__c where Sprint__c = \'' + sprintId + '\') AND Type__c = \'Activity Based\'' ;
 	
  	String selectClause = 'Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__r.Item__c, Description__c, Stage__c, Item__c, ' +
                          'Stage_Type__c, Sprint_Item__r.Sprint_Item_Stage__c, ' + 
                          'Sprint_Item__r.Sprint__r.Project__r.Roughin__c, Sprint_Item__r.Sprint__r.Project__r.Cutout__c, ' +
                          'Sprint_Item__r.Sprint__r.Project__r.Fitoff__c, Sprint_Item__r.Sprint__r.Project__r.Commission__c, ' + 
                          'Sprint_Item__r.Sprint__r.Project__r.Stage_Develop__c, Sprint_Item__r.Sprint__r.Project__r.Stage_Implement__c, ' + 
                          'Sprint_Item__r.Item__r.Project__r.Start__c, Sprint_Item__r.Item__r.Project__r.Finish__c ' + fromClause;
                          
    sprintActivities = Database.query(selectClause);

    selectedActivityWrapper = new List<activityWrapper>();
    
    for (Activity__c a :sprintActivities){	
    	selectedActivityWrapper.add(new activityWrapper(a));
    }
  }
  

 public List<activityWrapper> getselectedActivityWrap(){ 

    return selectedActivityWrapper;
  }
  
  public am_ActivityExt(Id sprintId, String callFrom){
    sprintActivities = [Select Id, Name, Status__c, Percent_of_Item_Sprint__c, Sprint_Item__r.Item__c, 
                          Stage_Type__c, Sprint_Item__r.Sprint_Item_Stage__c, 
                          Sprint_Item__r.Sprint__r.Project__r.Roughin__c, Sprint_Item__r.Sprint__r.Project__r.Cutout__c,
                          Sprint_Item__r.Sprint__r.Project__r.Fitoff__c, Sprint_Item__r.Sprint__r.Project__r.Commission__c, 
                          Sprint_Item__r.Sprint__r.Project__r.Stage_Develop__c, Sprint_Item__r.Sprint__r.Project__r.Stage_Implement__c, 
                          Sprint_Item__r.Item__r.Project__r.Start__c, Sprint_Item__r.Item__r.Project__r.Finish__c         
                          from Activity__c where Sprint_Item__r.Id = :sprintId];
    callActionActivity = callFrom;
    SetCalled = False;
  }
     
  public PageReference  pageOnLoad(){ 
    PageReference returnPage = pageHandler(); 
    return returnPage;        
  }

  public PageReference pageHandler(){
    //  Provide function to direct all page actions
system.debug('selectedActivityWrapper = ' + selectedActivityWrapper);

    //  extract only the selected activities from the wrapper
    List<Activity__c> selectedActivities = new List<Activity__c>();
    for (activityWrapper aw :selectedActivityWrapper){
      if(aw.selected == true){
      	selectedActivity = new 	Activity__c();
        selectedActivity = aw.activity; 
        selectedActivities.add(selectedActivity);
      }
    }

   //  update activity status of the selected items
    if (callActionActivity == 'updateActivityStatus')
      am_Activity.updateActivity(selectedActivities, 'Update');
    else if (callActionActivity == 'Started' || callActionActivity == 'Not Started' || callActionActivity == 'Finished')
      am_Activity.updateActivity(selectedActivities, callActionActivity);
      
    //  reset the selected flag to false
    for (activityWrapper aw :selectedActivityWrapper)
      aw.selected = false;
      
    if (SetCalled == True)
      return standardSetController.save();   
    else
      return standardController.save();

  }
  
  public PageReference pageHandlerActivity(){
    //  Method to deal with multiple extensions on sprint review page
system.debug('pageHandlerActivity');
    pageHandler();
    return null;   
  }

  // This is the wrapper/container class to identify if an items is selected on the page. 
  public class activityWrapper {
	public Activity__c activity {get; set;} 
	public Boolean selected {
		get; 
		set { selected = value; }
	}

	//This is the contructor method. 
	public activityWrapper(Activity__c a) {
	  activity = a;
	  selected = false;
	}
	
	public activityWrapper() {
	  selected = false;
	} 
  }
}