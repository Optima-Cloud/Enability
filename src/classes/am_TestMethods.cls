@isTest  
public with sharing class am_TestMethods {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          8/12/2016
   *  Modified by:   
   *  Date Modified: 
   *
   *  Description:   @TestSetup methods for the creation of standard test data
   *                
   ***********************************************************************************************/  

  /************************************************************************************
   **  test_am_BacklogQueue
   ************************************************************************************/  
 
  @isTest 
  public static void test_am_BacklogQueue(){
    
    Project__c project = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    Progress__c item = [Select Id, Name, Level__c, Project__c FROM Progress__c WHERE Name LIKE 'Test Item4%' LIMIT 1];

    List<am_BacklogQueueElement> backlog = am_BacklogQueueAURA.getBacklogQueueData(null, null, null, null); 
    System.assertEquals(0, backlog.size());

    backlog = am_BacklogQueueAURA.getBacklogQueueData(String.valueOf(project.Id), null, null, null);
    System.assertNotEquals(0, backlog.size());

    backlog = am_BacklogQueueAURA.getBacklogQueueData(null, String.valueOf(sprint.Id), null, null);
    System.assertNotEquals(0, backlog.size());

    backlog = am_BacklogQueueAURA.getBacklogQueueData(null, null, String.valueOf(item.Id), null);
    System.assertNotEquals(0, backlog.size());

    backlog = am_BacklogQueueAURA.getBacklogQueueData(String.valueOf(item.project__c), null, null, item.Level__c);
    System.assertNotEquals(0, backlog.size());

  }
  
  /************************************************************************************
   **  test_am_SiteInstruction
   ************************************************************************************/  
  @isTest 
  public static void test_am_SiteInstruction(){

    Progress__c item = [SELECT Id, Name FROM progress__c WHERE Name = 'Test Item1A' LIMIT 1];

    PageReference siteInstructionPage = new PageReference('/am_SiteInstruction');
    Test.setCurrentPage(siteInstructionPage);

    am_SiteInstructionExt siteInstructionExt = new am_SiteInstructionExt(new ApexPages.StandardController(item));
    siteInstructionExt.updateStaffActivityStatus();
  }
  
  /************************************************************************************
   **  test_am_Activity
   ************************************************************************************/  
  @isTest 
  public static void test_am_Activity(){

    String callAction = 'Started';
    List<Item_Component_Use__c> selectedItemComponentUses = [SELECT id, Item__c, Stage__c from Item_Component_Use__c];
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    Progress__c item = [SELECT Id, Name FROM progress__c WHERE Name = 'Test Item1H' LIMIT 1];
    List<Progress__c> items = [SELECT Id, Name FROM progress__c];

    List<Activity__c> selectedActivities = am_Activity.getActivities(item.Id, sprint.Id);
    System.assertEquals(False, selectedActivities.isEmpty());
    am_Activity.updateActivity(selectedActivities, callAction);
    am_Activity.updateActivity(selectedActivities, callAction, selectedItemComponentUses);
    PageReference activityPage = new PageReference('/am_ActivityUpdate');
    Test.setCurrentPage(activityPage);
    activityPage.getParameters().put('id', sprint.id);

    am_ActivityExt activityExt = new am_ActivityExt(new ApexPages.StandardController(selectedActivities[0])); 

    ApexPages.StandardSetController setController = new ApexPages.StandardSetController(selectedActivities);
    setController.setSelected(selectedActivities);
    activityExt = new am_ActivityExt(setController); 
    
    activityExt = new am_ActivityExt(Id.valueOf(sprint.id), callAction);
    
    selectedActivities = am_Activity.getActivities(sprint.Id); 
    
    am_Activity.getActivitiesLatest(items);
  }

  /************************************************************************************
   **  test_am_Issue
   ************************************************************************************/  
  @isTest 
  public static void test_am_Issue(){
    //  Test single issue
    List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 1];
    System.assertEquals(False, issues.isEmpty());
     PageReference itemPage = new PageReference('/am_IssueListOpen');
    Test.setCurrentPage(itemPage);
//    itemPage.getParameters().put('recs', issue.id);
    itemPage.getParameters().put('pagecols', '6');
 
    IssuesController issueExt = new IssuesController(new ApexPages.StandardController(issues[0])); 

    //  Test multiple issue
//    itemPage.getParameters().put('recs', issues[0].id);
    itemPage.getParameters().put('pagecols', '6');
 
    IssuesController issueExt1 = new IssuesController(new ApexPages.StandardSetController(issues)); 
    
    am_Issue newIssue = new am_Issue(new ApexPages.StandardSetController(issues));
  }
  
  /************************************************************************************
   **  test_am_ItemComponentUse
   ************************************************************************************/  
  @isTest 
  public static void test_am_ItemComponentUse(){
    List<Progress__c> selectedItems = [SELECT Id, Name, Stage_Type__c FROM progress__c WHERE Name = 'Test Item1A'];
    List<Item_Component_Use__c> selectedItemComponentUses = [SELECT id, Item__c, Stage__c, Number_Finished__c, Number_Started__c, Quantity__c 
                                                             FROM Item_Component_Use__c];

    System.assertNotEquals(0, selectedItems.size()); 

    am_ItemComponentUse.setStage( selectedItems);
    am_ItemComponentUse.determineItemComponentStatus(selectedItemComponentUses);
  }
  
  /************************************************************************************
   **  am_ItemComponentUseAudit
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ItemComponentUseAudit class
  public static void test_am_ItemComponentUseAudit(){
    List<Item_Component_Use__c> selectedItemComponentUses = [SELECT Id, Item__c, Stage__c, Number_Finished__c, Quantity__c, Quantity_Remaining__c,
                                                             Number_Started__c, Item__r.Stage_Type__c     
                                                             FROM Item_Component_Use__c WHERE Item__r.Name = 'Test Item1A'];
    List<Sprint_Items__c> sprintItems = [SELECT Id, Name, Item__c, Sprint_Item_Stage__c FROM Sprint_Items__c WHERE Sprint__r.Name = 'Test Sprint Electrical1 1'];   
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    List<Progress__c> items = [SELECT Id, Name FROM progress__c WHERE Name = 'Test Item1A'];

    System.assertNotEquals(0, selectedItemComponentUses.size());
    System.assertNotEquals(0, sprintItems.size());
    System.assertNotEquals(0, items.size());
    am_ItemComponentUseAudit.addItemComponentUseAudit(selectedItemComponentUses, String.valueOf(sprint.Id), sprintItems);
    
    am_ItemComponentUseAudit.removeItemComponentUseAudit(items, String.valueOf(sprint.Id));
  }

  /************************************************************************************
   **  test_am_Sprint
   ************************************************************************************/  
  @isTest 
  //  test methods in am_Sprint class
  public static void test_am_Sprint(){
    Project__c project = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    Project__c project1 = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical2' LIMIT 1];
    Project__c project2 = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical3' LIMIT 1];
    Project__c project3 = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical4' LIMIT 1];
    List<Progress__c> items = [SELECT Id, Name, Item_Status_New__c, Stage__c, Stage_Type__c FROM progress__c WHERE Name IN ('Test Item1A', 'Test Item2B')];
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    List<Sprint__c> sprints = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical2%'];
    Item_Component__c testItemComponent = [SELECT Id, Name FROM Item_Component__c WHERE Name = 'Test Item Component 1' LIMIT 1];
    am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();

    System.assertEquals(2, items.size());
    Map<String, Progress__c> mapItems = new Map<String, Progress__c>();
    for (Progress__c i : items)
      mapItems.put(i.Name, i);
 
    am_Sprint.getSprints(project.Id);

    am_Sprint.addSprintItems(items, String.valueOf(sprint.Id));

    //  confirm that two sprint items created
    List<Sprint_Items__c> sprintItems = [SELECT Id FROM Sprint_Items__c];
    System.assertEquals(122, sprintItems.size());
    
    //  confirm that item component use audits are created
    List<ItemComponentUseAudi__c> componentAudits = [SELECT Id FROM ItemComponentUseAudi__c];
    System.assertEquals(362, componentAudits.size());
    
    //  test that adding an item to a sprint twice that a new sprint item is not created   
    am_Sprint.addSprintItems(items, String.valueOf(sprint.Id));
    sprintItems = [SELECT Id FROM Sprint_Items__c];
    System.assertEquals(122, sprintItems.size());

    //  test that adding new component to an item will create an audit for the component when added to a sprint
    //  add component use
    insert new Item_Component_Use__c(Item__c = mapItems.get('Test Item1A').Id, Item_Component__c = testItemComponent.id, Number_Finished__c = 0, Quantity__c = 2, Stage__c = 'Pending');
    List<Item_Component_Use__c> componentUses = [SELECT Id FROM Item_Component_Use__c WHERE Item__r.Name = 'Test Item1A'];
    System.assertEquals(2, componentUses.size());
    componentAudits = [SELECT Id FROM ItemComponentUseAudi__c];
    System.assertEquals(362, componentAudits.size());

    //  re add item to sprint and test new component audit is created  
    am_Sprint.addSprintItems(items, String.valueOf(sprint.Id));
    componentAudits = [SELECT Id FROM ItemComponentUseAudi__c];
    System.assertEquals(363, componentAudits.size());
    
    //  test that returns the current or latest sprint with sprints before and after current date
    searchArguments.project = project1.Id; 
    System.assertEquals(2, am_Sprint.getCurrentLatestSprintSequence(searchArguments));

    //  test that returns the current or latest sprint with sprints before current date
    searchArguments.project = project2.Id;
    System.assertEquals(4, am_Sprint.getCurrentLatestSprintSequence(searchArguments));
   
    //  test that returns 0 when no sprints
    searchArguments.project = project3.Id;
    System.assertEquals(0, am_Sprint.getCurrentLatestSprintSequence(searchArguments));
   
    //  test that returns the current sprint 
    searchArguments.project = project.Id;
    System.assertEquals(0, am_Sprint.getCurrentSprintSequence(searchArguments));
   
    //  test that returns the current sprint 
    searchArguments.project = project1.Id;
    System.assertEquals(2, am_Sprint.getCurrentSprintSequence(searchArguments));

    //  test that returns the current sprint 
    searchArguments.project = project2.Id;
    System.assertEquals(4, am_Sprint.getCurrentSprintSequence(searchArguments));

    //  test that returns the current sprint 
    searchArguments.project = project3.Id;
    System.assertEquals(99999, am_Sprint.getCurrentSprintSequence(searchArguments));

  }
  
  /************************************************************************************
   **  am_SprintItem
   ************************************************************************************/  
  @isTest 
  //  test methods in am_SprintItem class
  public static void test_am_SprintItem(){
    List<Sprint_Items__c> sprintItems = [SELECT Id, Name, Item__c, Item_Stage_at_Sprint_Start__c, Sprint__c, Item__r.Stage_Type__c FROM Sprint_Items__c WHERE Sprint__r.Name = 'Test Sprint Electrical1 1'];   

    am_SprintItem.removeSprintItems(sprintItems);
  }
  
  /************************************************************************************
   **  test_Project_Progress
   ************************************************************************************/  
  @isTest 
  //  test methods in Project_Progress class
  public static void test_Project_Progress(){

    am_Project_Progress progress = new am_Project_Progress();
    progress.getProjectProgress();
  }

  /************************************************************************************
   **  test_Manning_schedule
   ************************************************************************************/  
  @isTest 
  //  test methods in Manning_schedule class
  public static void test_Manning_schedule(){

    Manning_schedule.Upsert_Manning_Schedules();
  }

  /************************************************************************************
   **  test_am_StaffProfiles
   ************************************************************************************/  
  @isTest 
  //  test methods in ProfileRates class
  public static void test_am_StaffProfiles(){

    am_StaffProfiles.updateProfileRates();
  }

  /************************************************************************************
   **  IssuesController
   ************************************************************************************/  
  @isTest 
  //  test methods in IssuesController class
  public static void test_IssuesController(){
   //  call aura function to create issue
   IssuesController.createIssue (new Issue__c(Description__c = 'test issue aura1', Next_Step__c = 'issue next step', Title__c = 'this is the title of the issue1',
                                              Project__c = [SELECT Id FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1].Id));
   IssuesController.createIssue (new Issue__c(Description__c = 'test issue aura2', Next_Step__c = 'issue next step', Title__c = 'this is the title of the issue2',
                                              Project__c = [SELECT Id FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1].Id));

   IssuesController.getPickValues(new Issue__c(Description__c = 'test issue aura', Next_Step__c = 'issue next step', Title__c = 'this is the title of the issue'), 'Description__c');
  }

  /************************************************************************************
   **  IssueItemsController
   ************************************************************************************/  
  @isTest 
  //  test methods in IssueItemsController class
  public static void test_IssueItemsController(){
    Issue__c testIssue1 = [SELECT Id, Title__c FROM Issue__c WHERE Title__c = 'this is the title of the issue1'];
    Issue__c testIssue2 = [SELECT Id, Title__c FROM Issue__c WHERE Title__c = 'this is the title of the issue2'];
    List<Issue__c> testIssues2 = [SELECT Id, Title__c FROM Issue__c];   
    Activity__c testActivity = [SELECT Id FROM Activity__c LIMIT 1];
    Progress__c testItem = [SELECT Id FROM Progress__c LIMIT 1];
    Progress__c testItem2 = [SELECT Id FROM Progress__c WHERE Name = 'Test Item4A' LIMIT 1];
    List<Progress__c> testItems = [SELECT Id FROM Progress__c];
    IssueItemsController issueItemCon = new IssueItemsController();

    issueItemCon.getIssue(testIssue2);
   
    // for issue
    PageReference itemPage = new PageReference('/LE_vf_IssueItem_New');
    Test.setCurrentPage(itemPage);
    itemPage.getParameters().put('recs', testIssue2.id);
    IssueItemsController issueItem = new IssueItemsController(new ApexPages.StandardController(testIssue2)); 
    
    // for activity
    itemPage.getParameters().put('recs', testActivity.id);
    IssueItemsController issueItem1 = new IssueItemsController(new ApexPages.StandardController(testActivity)); 

    // for item
    itemPage.getParameters().put('recs', testItem.id);
    IssueItemsController issueItem2 = new IssueItemsController(new ApexPages.StandardController(testItem)); 
    
    //  test triggerAction function
    IssueItemsController.triggerAction('StatusToClosed', testIssues2);
    
    issueItemCon = new IssueItemsController();
    issueItemCon.selectedItems = testItems;
    issueItemCon.retURL = '/LE_vf_IssueItem_New';
    issueItemCon.createItemIssueFromIssue();
    
    issueItemCon.createItemIssueFromIssue(testItem2.Id, testIssue1);
     
    issueItemCon.createItemIssue();
  }

  /************************************************************************************
   **  am_IssueItem
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ItemExt class
  public static void test_am_IssueItem(){
  }

  /************************************************************************************
   **  am_ItemExt
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ItemExt class
  public static void test_am_ItemExt(){
    Progress__c testItem = [SELECT Id FROM Progress__c LIMIT 1];
    List<Progress__c> testItems = [SELECT Id FROM Progress__c];
    Sprint__c sprint = [Select Id FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    String projectID = String.valueOf([Select Id FROM Project__c LIMIT 1].Id);
    
    // for set
    PageReference itemPage = new PageReference('/am_ItemsAddToSprint');
    Test.setCurrentPage(itemPage);
    itemPage.getParameters().put('recs', testItem.id);
    itemPage.getParameters().put('retURL', '/am_ItemsAddToSprint');
    am_ItemExt itemExt = new am_ItemExt(new ApexPages.StandardSetController(testItems)); 
    
    // for single
    itemPage.getParameters().put('recs', testItem.id);
    am_ItemExt itemExts = new am_ItemExt(new ApexPages.StandardController(testItem)); 

    itemExts.getSprintList();
    
    itemPage.getParameters().put('callAction', 'addSprintItems');
    itemExts.sprint = string.valueof(sprint.Id);
    itemExts.pageHandler();
    
    am_ItemExt.getLevels(projectID); 
    am_ItemExt.getItemsLevel(projectID, 'Level 01');
    am_ItemExt.getItemsAggregateItem('AggItem01');
    am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
    searchArguments.project = projectID; 
    am_ItemExt.getAggregateItems(searchArguments);
    searchArguments.sprint = String.valueOf(sprint.Id);
    am_ItemExt.getAggregateItems(searchArguments);

  }

  /************************************************************************************
   **  am_ManningScheduleExt
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ItemExt class
  public static void test_am_ManningScheduleExt(){
    List<Staff_Profile__c> staffers = new List<Staff_Profile__c>();
    Staff_Cost_Constants__c constants = [SELECT Id FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];
    RateandAllowance__c rate = [SELECT Id FROM RateandAllowance__c WHERE Domain__c = 'Staff Type' LIMIT 1];
    Staff__c staff = [SELECT Id, Staff_Type__r.Name FROM Staff__c WHERE Status__c = true LIMIT 1];
    
    staffers.add(new Staff_Profile__c(Staff_Name__c = staff.Id, Staff_Rate__c = rate.Id, Constants__c = constants.Id));
    
    am_ManningScheduleExt schExt = new am_ManningScheduleExt(new ApexPages.StandardSetController(staffers)); 
    schExt = new am_ManningScheduleExt(new ApexPages.StandardController(staffers[0])); 

//    schExt.pageHandler();

//    schExt.pageOnLoad();
  }

  /************************************************************************************
   **  am_SprintItemExt
   ************************************************************************************/  
  @isTest 
  //  test methods in am_SprintItemExt class
  public static void test_am_SprintItemExt(){
    List<Sprint_Items__c> sprintItems = [SELECT Id, Name, Item__c, Item_Stage_at_Sprint_Start__c, Sprint__c FROM Sprint_Items__c WHERE Sprint__r.Name = 'Test Sprint Electrical1 1'];   
    system.assertEquals(False, sprintItems.isEmpty());
    PageReference sprintItemPage = new PageReference('/am_SprintItemMove');
    Test.setCurrentPage(sprintItemPage);
    sprintItemPage.getParameters().put('recs', sprintItems[0].id);
    sprintItemPage.getParameters().put('retURL', '/am_SprintItemMove');
    ApexPages.StandardSetController setController = new ApexPages.StandardSetController(sprintItems);
    setController.setSelected(sprintItems);
    am_SprintItemExt sprintItemExt = new am_SprintItemExt(setController); 

    sprintItemExt.callAction = 'removeSprintItems';
    sprintItemExt.pageHandler();
    
    sprintItemExt.getSprintList();
  }
  
  /************************************************************************************
   **  am_StaffProfilesExt
   ************************************************************************************/  
  @isTest 
  //  test methods in am_StaffProfilesExt class
  public static void test_am_StaffProfilesExt(){
    List<Staff_Profile__c> staffers = new List<Staff_Profile__c>();
    Staff_Cost_Constants__c constants = [SELECT Id FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];
    RateandAllowance__c rate = [SELECT Id FROM RateandAllowance__c WHERE Domain__c = 'Staff Type' LIMIT 1];
    Staff__c staff = [SELECT Id, Staff_Type__r.Name FROM Staff__c WHERE Status__c = true LIMIT 1];
    
    staffers.add(new Staff_Profile__c(Staff_Name__c = staff.Id, Staff_Rate__c = rate.Id, Constants__c = constants.Id));
    
    am_StaffProfilesExt staffProfExt = new am_StaffProfilesExt(new ApexPages.StandardSetController(staffers)); 
    staffProfExt = new am_StaffProfilesExt(new ApexPages.StandardController(staffers[0])); 

    staffProfExt.pageHandler();

    staffProfExt.pageOnLoad();
  }

   /************************************************************************************
   **  am_ItemComponentUseExt
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ItemComponentUseExt class
  public static void test_am_ItemComponentUseExt(){
    Sprint__c tempSprintElectrical = [SELECT id, Name FROM Sprint__c WHERE Name LIKE 'Test Sprint Electrical1%' LIMIT 1];    
//    am_ItemComponentUseExt ICUExt = new am_ItemComponentUseExt(new ApexPages.StandardSetController(tempSprintElectrical)); 
    am_ItemComponentUseExt ICUExt = new am_ItemComponentUseExt(new ApexPages.StandardController(tempSprintElectrical)); 

    ICUExt.selectedItemComponentUseAudits = [SELECT Id, Item_Component_Use__r.Item__c, Item_Component_Use__r.Item_Component__c, Number_Finished__c,
                                             Number_Started__c, Sprint__c, Quantity__c, Sprint_Item__c 
                                             FROM ItemComponentUseAudi__c WHERE Sprint__c = :tempSprintElectrical.Id];
    system.assertEquals(False, ICUExt.selectedItemComponentUseAudits.isEmpty());
    ICUExt.selectedItemComponentUses = [SELECT Stage__c, Quantity_Remaining__c, Number_Finished__c, Number_Started__c, Item_Component__c, Item__c 
                                        FROM Item_Component_Use__c WHERE Item__c 
                                        IN (SELECT Item__c FROM Sprint_Items__c WHERE Sprint__c = :tempSprintElectrical.Id)];
    system.assertEquals(False, ICUExt.selectedItemComponentUses.isEmpty());
    ICUExt.callAction = 'saveRecord';
    ICUExt.pageHandler();
    ICUExt.callAction = 'updateSelectedItemsFinished'; 
    ICUExt.pageHandler();
    ICUExt.callAction = 'updateSelectedItemsStarted'; 
    ICUExt.pageHandler();
    ICUExt.callAction = 'updateSelectedItemsNotStarted'; 
    ICUExt.pageHandler();

    ICUExt.pageOnLoad();
    
//    ICUExt.callAction = 'updateAll'; 
    ICUExt.getitemList();
    
    ICUExt.refreshselectedItemComponentUses();
    ICUExt.refreshselectedItemComponentUseAudits();
  }
  
  

  /************************************************************************************
   **  am_ActivityTimeEntryLG
   ************************************************************************************/  
  @isTest 
  //  test methods in am_ActivityTimeEntryLG class 
  public static void am_ActivityTimeEntryLG(){
    Progress__c testItem = [SELECT Id FROM Progress__c LIMIT 1];
    Project__c project = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    Activity__c testActivity = [SELECT Id FROM Activity__c LIMIT 1];
    Staff_Activity__c testStaffAct = [SELECT Id FROM Staff_Activity__c LIMIT 1];
    List<Staff_Activity__c> testStaffActs = [SELECT Id FROM Staff_Activity__c LIMIT 1];

    am_ActivityTimeEntryLG.getProjects();
    
    am_ActivityTimeEntryLG.getSprints(string.valueof(project.Id));
    
    am_ActivityTimeEntryLG.getItems(string.valueof(sprint.Id));
    
    am_ActivityTimeEntryLG.getActivities(testItem.Id, sprint.Id);
    
    am_ActivityTimeEntryLG.getStaff();
    
    am_ActivityTimeEntryLG.updateStaffActivities(testStaffActs);
     
    am_ActivityTimeEntryLG.updateStaffActivity(testStaffAct);
    
  }
  
  /************************************************************************************
   **  am_SprintReviewAURA
   ************************************************************************************/  
  @isTest 
  //  test methods in am_SprintReviewAURA class
  public static void am_SprintReviewAURA(){
    Project__c project = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    System.AssertEquals(True, project != null);
    Sprint__c sprint = [Select Id, Name, Sprint_Hours_Estimated__c FROM Sprint__c WHERE Name = 'Test Sprint Electrical1 1' LIMIT 1];
    System.AssertEquals(True, sprint != null);
    Progress__c testItem = [SELECT Id FROM Progress__c LIMIT 1];
    List<Id> blankIds = new List<Id>();
    Issue__c testIssue = new Issue__c(Description__c = 'test issue ', Next_Step__c = 'issue next step', Title__c = 'this is the title of the issue',
                                      Project__c = [SELECT Id FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1].Id, Raised_by__c = 'Ernst Bloefeld');
    List<ItemComponentUseAudi__c> selectedItemComponentAudits = [SELECT Id, Item_Component_Use__r.Item__c, Item_Component_Use__r.Item_Component__c, Number_Finished__c,
                                                                 Number_Started__c, Sprint__c, Quantity__c, Sprint_Item__c
                                                                 FROM ItemComponentUseAudi__c];
    System.AssertEquals(True, selectedItemComponentAudits.size() > 0);

    am_SprintReviewAURA.getProjects();
    
    am_SprintReviewAURA.getSprints(string.valueof(project.Id));
        
    am_SprintReviewAURA.getLevels(string.valueof(project.Id));
        
    am_SprintReviewAURA.getItems(string.valueof(sprint.Id));
    
    am_SprintReviewAURA.getItemComponentAudits(string.valueof(testItem.Id), string.valueof(sprint.Id), '', '');

    am_SprintReviewAURA.getItemComponentAudits(string.valueof(testItem.Id), '', '', '');
    
    am_SprintReviewAURA.getItemsLevel(string.valueof(project.Id), 'Level 01');

    am_SprintReviewAURA.getItemsAggregateItem('AggItem01');

    am_SprintReviewAURA.getAggregateItems(string.valueof(project.Id), 'Level 01', string.valueof(sprint.Id));

    am_SprintReviewAURA.getAggItemComponentAudits(string.valueof(testItem.Id), string.valueof(sprint.Id), string.valueof(project.Id), 'AggItem01'); 

    am_SprintReviewAURA.getIssueTypes();

    am_SprintReviewAURA.saveItemComponentAudits(selectedItemComponentAudits);
   
    am_SprintReviewAURA.getUserName();
    
    am_SprintReviewAURA.createIssue(JSON.serialize(testIssue), testItem.Id, blankIds); 
    
//    am_SprintReviewAURA.createIssue(testIssue, testItem.Id, [SELECT Id FROM Issue__c]);

    am_SprintReviewAURA.getItemsSprint(string.valueof(sprint.Id));

    am_SprintReviewAURA.getIssues(string.valueof(project.Id));
	
    am_SprintReviewAURA.getItemsProject(string.valueof(project.Id)); 
   }    
  
 /************************************************************************************
   **  am_am_IssueItemExtLG
   ************************************************************************************/  
  @isTest 
  //  test methods in am_SprintReviewAURA class

  public static void am_formReviewIssueAURA(){ 
    Project__c project = [SELECT Id, Name, Company__c, Type__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    Progress__c item = [SELECT Id FROM Progress__c WHERE Project__r.Name ='TestProjectElectrical1' LIMIT 1];
    System.AssertEquals(True, project != null);

    List<Issue_Item__c> selectedIssueItem = [SELECT Id, Item_Name__c, Title__c, Status__c, Issue_Notifications__r.Description__c, Resolution__c FROM Issue_Item__c];
    System.AssertEquals(True, selectedIssueItem.size() > 0);

    am_formReviewIssueAURA.getIssueItems(string.valueof(project.Id), null, null);
    am_formReviewIssueAURA.getIssueItems(null, string.valueof(item.Id), null);
 
    am_formReviewIssueAURA.saveIssueItems(selectedIssueItem);
    
  }

  /************************************************************************************
   **  test_am_UniversalSearchArguments
   ************************************************************************************/  
  @isTest 
  //  test methods in am_Stage class
  public static void test_am_UniversalSearchArguments(){ 
    Project__c project = [SELECT Id FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];

     am_UniversalSearchArguments searchArguments = new am_UniversalSearchArguments();
     searchArguments.project = project.Id; 
     System.assertEquals(project.Id, searchArguments.getProjectID());
  	
  }

  /************************************************************************************
   **  test_am_Stage
   ************************************************************************************/  
  @isTest 
  //  test methods in am_Stage class
  public static void test_am_Stage(){ 
    //  test public methods
    System.assertEquals(0, am_Stage.getStageIndex('Construction_Stages_4', 'Pending')); 
    System.assertEquals(1, am_Stage.getStageIndex('Construction_Stages_4', 'Roughin')); 
    System.assertEquals(2, am_Stage.getStageIndex('Construction_Stages_4', 'Cutout')); 
    System.assertEquals(3, am_Stage.getStageIndex('Construction_Stages_4', 'Fitoff')); 
    System.assertEquals(4, am_Stage.getStageIndex('Construction_Stages_4', 'Commission')); 
    System.assertEquals(5, am_Stage.getStageIndex('Construction_Stages_4', 'Completed')); 
	
    System.assertEquals(6, am_Stage.getRecordTypeStageNames('Construction_Stages_4').size()); 
    System.assertEquals('Pending', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[0]); 
    System.assertEquals('Roughin', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[1]); 
    System.assertEquals('Cutout', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[2]); 
    System.assertEquals('Fitoff', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[3]); 
    System.assertEquals('Commission', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[4]); 
    System.assertEquals('Completed', am_Stage.getRecordTypeStageNames('Construction_Stages_4')[5]); 

    //  returns the next stage
    System.assertEquals('Roughin', am_Stage.getNextStage('Construction_Stages_4', 'Pending')); 
    System.assertEquals('Fitoff', am_Stage.getNextStage('Construction_Stages_4', 'Cutout')); 
    System.assertEquals('Completed', am_Stage.getNextStage('Construction_Stages_4', 'Completed')); 
	
    //  returns the last stage
    System.assertEquals('Completed', am_Stage.getLastStage('Construction_Stages_3', 'Pending')); 
    System.assertEquals('Completed', am_Stage.getLastStage('Construction_Stages_3', 'Roughin')); 
    System.assertEquals('Completed', am_Stage.getLastStage('Construction_Stages_3', 'Completed')); 
	
    //  returns the later stage
    System.assertEquals('Pending', am_Stage.getMaxStage('Pending', 'Pending', 'Construction_Stages_4')); 
    System.assertEquals('Roughin', am_Stage.getMaxStage('Pending', 'Roughin', 'Construction_Stages_4')); 
    System.assertEquals('Completed', am_Stage.getMaxStage('Commission', 'Completed', 'Construction_Stages_4')); 
    System.assertEquals('Completed', am_Stage.getMaxStage('Completed', 'Completed', 'Construction_Stages_4')); 
	
    //  returns the earlier stage
    System.assertEquals('Pending', am_Stage.getMinStage('Pending', 'Pending', 'Construction_Stages_4')); 
    System.assertEquals('Cutout', am_Stage.getMinStage('Cutout', 'Fitoff', 'Construction_Stages_4')); 
    System.assertEquals('Completed', am_Stage.getMinStage('Completed', 'Completed', 'Construction_Stages_4')); 
	
    //  returns the next or prior stage depending on the direction specified
    System.assertEquals('Roughin', am_Stage.getAdjacentStage('Pending', 'Construction_Stages_4', 'Next')); 
    System.assertEquals('Completed', am_Stage.getAdjacentStage('Completed', 'Construction_Stages_4', 'Next')); 
    System.assertEquals('Pending', am_Stage.getAdjacentStage('Pending', 'Construction_Stages_4', 'Prior')); 
    System.assertEquals('Commission', am_Stage.getAdjacentStage('Completed', 'Construction_Stages_4', 'Prior')); 
	
    //  returns the prior stage
    System.assertEquals('Pending', am_Stage.getPriorStage('Pending', 'Construction_Stages_4')); 
	
    //  returns true if first argument is < to the third
    System.assertEquals(false, am_Stage.isHigherStage('Pending', 'Construction_Stages_4', 'Pending')); 	
    System.assertEquals(true, am_Stage.isHigherStage('Pending', 'Construction_Stages_4', 'Roughin')); 	
    System.assertEquals(false, am_Stage.isHigherStage('Cutout', 'Construction_Stages_4', 'Cutout')); 	
    System.assertEquals(true, am_Stage.isHigherStage('Cutout', 'Construction_Stages_4', 'Fitoff')); 	
    System.assertEquals(false, am_Stage.isHigherStage('Fitoff', 'Construction_Stages_4', 'Cutout')); 	
    System.assertEquals(false, am_Stage.isHigherStage('Completed', 'Construction_Stages_4', 'Completed')); 	

    //  cycle through all the stages and get the maximum
    System.assertEquals('Commission', am_Stage.getMaxStage(new List<String>{'Pending', 'Cutout', 'Fitoff', 'Commission'}, 'Construction_Stages_4'));
    System.assertEquals('Commission', am_Stage.getMaxStage(new List<String>{'Fitoff', 'Commission', 'Pending', 'Cutout'}, 'Construction_Stages_4'));
    System.assertEquals('Fitoff', am_Stage.getMaxStage(new List<String>{'Pending', 'Cutout', 'Fitoff'}, 'Construction_Stages_4'));

    //  cycle through all the stages and get the minimum
    System.assertEquals('Pending', am_Stage.getMinStage(new Set<String>{'Pending', 'Cutout', 'Fitoff', 'Commission'}, 'Construction_Stages_4'));
    System.assertEquals('Pending', am_Stage.getMinStage(new Set<String>{'Fitoff', 'Commission', 'Pending', 'Cutout'}, 'Construction_Stages_4'));
    System.assertEquals('Cutout', am_Stage.getMinStage(new Set<String>{'Cutout', 'Fitoff', 'Commission'}, 'Construction_Stages_4'));

    //  return true if aStage is the first stage, else return false
    System.assertEquals(true, am_Stage.checkMinStage('Pending', 'Construction_Stages_4')); 
    System.assertEquals(false, am_Stage.checkMinStage('Cutout', 'Construction_Stages_4')); 
    System.assertEquals(false, am_Stage.checkMinStage('Completed', 'Construction_Stages_4')); 

    //  test for status only %
    System.assertEquals(0, am_Stage.getStageStatusPercentage('StatusOnly', 'Not Started', 'Construction_Stages_4', ''));
    System.assertEquals(40, am_Stage.getStageStatusPercentage('StatusOnly', 'Started', 'Construction_Stages_4', ''));
    System.assertEquals(100, am_Stage.getStageStatusPercentage('StatusOnly', 'Finished', 'Construction_Stages_4', ''));

    //  test for dual time allocation on stage and status %
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Pending', 'Not Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Pending', 'Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Pending', 'Finished', 'Construction_Stages_4', 'Cummulative'));

    //  test for dual time allocation on stage and status %
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Roughin', 'Not Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(16, am_Stage.getStageStatusPercentage('Roughin', 'Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(40, am_Stage.getStageStatusPercentage('Roughin', 'Finished', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Roughin', 'Not Started', 'Construction_Stages_4', 'Stage'));
    System.assertEquals(16, am_Stage.getStageStatusPercentage('Roughin', 'Started', 'Construction_Stages_4', 'Stage'));
    System.assertEquals(40, am_Stage.getStageStatusPercentage('Roughin', 'Finished', 'Construction_Stages_4', 'Stage'));

    //  test for dual time allocation on stage and status %
    System.assertEquals(40, am_Stage.getStageStatusPercentage('Cutout', 'Not Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(44, am_Stage.getStageStatusPercentage('Cutout', 'Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(50, am_Stage.getStageStatusPercentage('Cutout', 'Finished', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Cutout', 'Not Started', 'Construction_Stages_4', 'Stage'));
    System.assertEquals(4, am_Stage.getStageStatusPercentage('Cutout', 'Started', 'Construction_Stages_4', 'Stage'));
    System.assertEquals(10, am_Stage.getStageStatusPercentage('Cutout', 'Finished', 'Construction_Stages_4', 'Stage'));

    //  test for dual time allocation on stage and status %
    System.assertEquals(50, am_Stage.getStageStatusPercentage('Fitoff', 'Not Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(68, am_Stage.getStageStatusPercentage('Fitoff', 'Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(95, am_Stage.getStageStatusPercentage('Fitoff', 'Finished', 'Construction_Stages_4', 'Cummulative'));

    //  test for dual time allocation on stage and status %
    System.assertEquals(95, am_Stage.getStageStatusPercentage('Commission', 'Not Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(97, am_Stage.getStageStatusPercentage('Commission', 'Started', 'Construction_Stages_4', 'Cummulative'));
    System.assertEquals(100, am_Stage.getStageStatusPercentage('Commission', 'Finished', 'Construction_Stages_4', 'Cummulative'));

    //  test for dual time allocation on stage and status %
    System.assertEquals(45, am_Stage.getStageStatusPercentage('Fitoff', 'Not Started', 'Construction_Stages_3', 'Cummulative'));
    System.assertEquals(63, am_Stage.getStageStatusPercentage('Fitoff', 'Started', 'Construction_Stages_3', 'Cummulative'));
    System.assertEquals(90, am_Stage.getStageStatusPercentage('Fitoff', 'Finished', 'Construction_Stages_3', 'Cummulative'));
    System.assertEquals(0, am_Stage.getStageStatusPercentage('Fitoff', 'Not Started', 'Construction_Stages_3', 'Stage'));
    System.assertEquals(18, am_Stage.getStageStatusPercentage('Fitoff', 'Started', 'Construction_Stages_3', 'Stage'));
    System.assertEquals(45, am_Stage.getStageStatusPercentage('Fitoff', 'Finished', 'Construction_Stages_3', 'Stage'));

  } 
  
  /************************************************************************************
   **  test_ShowAllSObjectActivity()
   ************************************************************************************/ 
  @isTest 
  public static void test_am_ShowAllSObjectActivity(){
    //  test methods in ShowAllSObjectActivity() class
    Map<string,schema.Sobjecttype> gd = schema.getGlobalDescribe();
    String strKeyPrefix = gd.get('Project__c').getDescribe().getKeyPrefix();
    Project__c project = [SELECT Id FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
 
    PageReference activityPage = new pagereference('/strKeyPrefix/e');
    Test.setCurrentPage(activityPage);
    activityPage.getParameters().put('id', project.id);
    ShowAllSObjectActivity testobject = new ShowAllSObjectActivity();

  }

  /************************************************************************************
   **  test_am_TriggerHandler()
   ************************************************************************************/ 
  @isTest 
  public static void test_am_TriggerHandler(){
    am_TriggerHandler triggerHandler = new am_TriggerHandler();
    triggerHandler.isTriggerExecuting = true;
    triggerHandler.setTriggerContext('before insert', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('after insert', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('before update', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('after update', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('before delete', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('after delete', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('before undelete', true);
    triggerHandler.run();
    triggerHandler.setTriggerContext('after undelete', true);
    triggerHandler.run();
  }
 
  /***********************************************************************************************
   *  Written by:   David Strangward
   *  Date:         31/7/2016
   *  Modified by: 
   *  Date Modified:
   *
   *  Description:   @TestSetup methods for the creation of standard test data
   *                
   ***********************************************************************************************/  
   
  @testSetup 
  public static void createTestData(){
   /************************************************************************************
   **  createStagesCustomSetting
   ************************************************************************************/ 
    
   List<Picklist_Setup__c> stages = new List<Picklist_Setup__c>(); 
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Pending', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Pending', Value_Index__c = 0, Work_Contribution__c = 0));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Roughin', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Roughin', Value_Index__c = 1, Work_Contribution__c = 40));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Cutout', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Cutout', Value_Index__c = 2, Work_Contribution__c = 10));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Fitoff', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Fitoff', Value_Index__c = 3, Work_Contribution__c = 45));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Commission', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Commission', Value_Index__c = 4, Work_Contribution__c = 5));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_4Completed', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_4', Value_Name__c = 'Completed', Value_Index__c = 5, Work_Contribution__c = 100));

   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_3Pending', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_3', Value_Name__c = 'Pending', Value_Index__c = 0, Work_Contribution__c = 0));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_3Roughin', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_3', Value_Name__c = 'Roughin', Value_Index__c = 1, Work_Contribution__c = 45));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_3Fitoff', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_3', Value_Name__c = 'Fitoff', Value_Index__c = 2, Work_Contribution__c = 45));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_3Commission', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_3', Value_Name__c = 'Commission', Value_Index__c = 3, Work_Contribution__c = 10));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_3Completed', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_3', Value_Name__c = 'Completed', Value_Index__c = 4, Work_Contribution__c = 100));

   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_1Pending', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_1', Value_Name__c = 'Pending', Value_Index__c = 0, Work_Contribution__c = 0));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_1In Progress', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_1', Value_Name__c = 'In Progress', Value_Index__c = 1, Work_Contribution__c = 40));
   stages.add(new Picklist_Setup__c(Name = 'Construction_Stages_1Completed', Picklist_Name__c = 'Stages', Record_Type__c = 'Construction_Stages_1', Value_Name__c = 'Completed', Value_Index__c = 2, Work_Contribution__c = 100));

   stages.add(new Picklist_Setup__c(Name = 'IT_Stages_2Pending', Picklist_Name__c = 'Stages', Record_Type__c = 'IT_Stages_2', Value_Name__c = 'Pending', Value_Index__c = 0, Work_Contribution__c = 0));
   stages.add(new Picklist_Setup__c(Name = 'IT_Stages_2Develop', Picklist_Name__c = 'Stages', Record_Type__c = 'IT_Stages_2', Value_Name__c = 'Develop', Value_Index__c = 1, Work_Contribution__c = 40));
   stages.add(new Picklist_Setup__c(Name = 'IT_Stages_2Implement', Picklist_Name__c = 'Stages', Record_Type__c = 'IT_Stages_2', Value_Name__c = 'Implement', Value_Index__c = 2, Work_Contribution__c = 60));
   stages.add(new Picklist_Setup__c(Name = 'IT_Stages_2Completed', Picklist_Name__c = 'Stages', Record_Type__c = 'IT_Stages_2', Value_Name__c = 'Completed', Value_Index__c = 3, Work_Contribution__c = 100));

   insert stages;

   /************************************************************************************
   **  createTestProjectDaysOff
   ************************************************************************************/
    List<Contact> contacts = new List<Contact>();
    contacts.add(new Contact(FirstName = 'Ernst', LastName = 'Bloefeld'));

    insert contacts;
  
  /************************************************************************************
   **  createTestProjectDaysOff
   ************************************************************************************/
  List<Project_Days_Off__c> daysOff = new List<Project_Days_Off__c>();
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'January'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'February'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'March'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'April'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'May'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'June'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'July'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'August'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'September'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'October'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'November'));
  daysOff.add(new Project_Days_Off__c(Mandatory_Annual_Leave__c = 1, RDO_36__c = 2, RDO_38__c = 1, Public_Holiday__c = 1, Picnic_Day__c = 0, Month__c = 'December'));

    insert daysOff;
    
  /************************************************************************************
   **  createStaffConstants
   ************************************************************************************/
    // Create staff constant records
    Staff_Cost_Constants__c testStaffConstants = new Staff_Cost_Constants__c();

    testStaffConstants.Name = 'Living Electrics';
    testStaffConstants.Weeks_Per_Year__c = 52;
    testStaffConstants.Working_Hours_Per_Year__c = 2000;
    testStaffConstants.Hours_Per_Day__c = 8;
    testStaffConstants.Superannuation__c = 9.5;
    testStaffConstants.Long_Service__c = 2;
    testStaffConstants.Annual_Leave_Days__c = 20;
    testStaffConstants.Annual_Leave_Loading__c = 17.5;
    testStaffConstants.Public_Holiday_Days__c = 11;
    testStaffConstants.Sick_Leave_Days__c = 10;
    testStaffConstants.Training_Days__c = 2;
    testStaffConstants.Trade_School_Days__c = 10;
    testStaffConstants.Annual_Overhead_Amount__c = 200000;
    insert testStaffConstants;       

  /************************************************************************************
   **  createBuildingHeight
   ************************************************************************************/
    // Create staff constant records
    Building_Height__c testBuildingHeight = new Building_Height__c();

    testBuildingHeight.Name = '0 - 15 floors';

    insert testBuildingHeight;       

  /************************************************************************************
   **  createRateandAllowance
   ************************************************************************************/
    // Create Rate and Allowance records
    List<RateandAllowance__c> testRateandAllowances = new List<RateandAllowance__c>();

    RateandAllowance__c testRateandAllowance1 = new RateandAllowance__c();
    testRateandAllowance1.Name = 'Electrician A Grade';
    testRateandAllowance1.Type__c = '1. Base Rate';
    testRateandAllowance1.Frequency__c = 'Hourly';
    testRateandAllowance1.Domain__c = 'Staff Type';
    testRateandAllowance1.Amount_ETU_EBA__c = 10;
    testRateandAllowance1.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance1);      

    RateandAllowance__c testRateandAllowance2 = new RateandAllowance__c();
    testRateandAllowance2.Name = 'Electrician B Grade';
    testRateandAllowance2.Type__c = '1. Base Rate';
    testRateandAllowance2.Frequency__c = 'Hourly';
    testRateandAllowance2.Domain__c = 'Staff Type';
    testRateandAllowance2.Amount_ETU_EBA__c = 10;
    testRateandAllowance2.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance2);      
    
    RateandAllowance__c testRateandAllowance3 = new RateandAllowance__c();
    testRateandAllowance3.Name = 'Apprentice Year 1';
    testRateandAllowance3.Type__c = '1. Base Rate';
    testRateandAllowance3.Frequency__c = 'Hourly';
    testRateandAllowance3.Domain__c = 'Staff Type';
    testRateandAllowance3.Amount_ETU_EBA__c = 10;
    testRateandAllowance3.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance3);      
    
    RateandAllowance__c testRateandAllowance4 = new RateandAllowance__c();
    testRateandAllowance4.Name = 'Apprentice Year 2';
    testRateandAllowance4.Type__c = '1. Base Rate';
    testRateandAllowance4.Frequency__c = 'Hourly';
    testRateandAllowance4.Domain__c = 'Staff Type';
    testRateandAllowance4.Amount_ETU_EBA__c = 10;
    testRateandAllowance4.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance4);      
    
    RateandAllowance__c testRateandAllowance5 = new RateandAllowance__c();
    testRateandAllowance5.Name = 'Apprentice Year 3';
    testRateandAllowance5.Type__c = '1. Base Rate';
    testRateandAllowance5.Frequency__c = 'Hourly';
    testRateandAllowance5.Domain__c = 'Staff Type';
    testRateandAllowance5.Amount_ETU_EBA__c = 10;
    testRateandAllowance5.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance5);      
    
    RateandAllowance__c testRateandAllowance6 = new RateandAllowance__c();
    testRateandAllowance6.Name = 'Apprentice Year 4';
    testRateandAllowance6.Type__c = '1. Base Rate';
    testRateandAllowance6.Frequency__c = 'Hourly';
    testRateandAllowance6.Domain__c = 'Staff Type';
    testRateandAllowance6.Amount_ETU_EBA__c = 10;
    testRateandAllowance6.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance6);      
    
    RateandAllowance__c testRateandAllowance7 = new RateandAllowance__c();
    testRateandAllowance7.Name = 'Apprentice Mature Year 1';
    testRateandAllowance7.Type__c = '1. Base Rate';
    testRateandAllowance7.Frequency__c = 'Hourly';
    testRateandAllowance7.Domain__c = 'Staff Type';
    testRateandAllowance7.Amount_ETU_EBA__c = 10;
    testRateandAllowance7.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance7);      
    
    RateandAllowance__c testRateandAllowance8 = new RateandAllowance__c();
    testRateandAllowance8.Name = 'Travel Electrician A Grade';
    testRateandAllowance8.Type__c = '2. Allowances';
    testRateandAllowance8.Frequency__c = 'Daily';
    testRateandAllowance8.Amount_ETU_EBA__c = 5;
    testRateandAllowance8.Amount_LE_EBA__c = 6;
    testRateandAllowances.add(testRateandAllowance8);  

    RateandAllowance__c testRateandAllowance9 = new RateandAllowance__c();
    testRateandAllowance9.Name = 'Weekly Supervisor';
    testRateandAllowance9.Type__c = '2. Allowances';
    testRateandAllowance9.Frequency__c = 'Weekly';
    testRateandAllowance9.Domain__c = 'Supervisor Type';
    testRateandAllowance9.Amount_ETU_EBA__c = 7;
    testRateandAllowance9.Amount_LE_EBA__c = 8;
    testRateandAllowances.add(testRateandAllowance9);  

    RateandAllowance__c testRateandAllowance10 = new RateandAllowance__c();
    testRateandAllowance10.Name = 'Fares Vehicle Provided';
    testRateandAllowance10.Type__c = '2. Allowances';
    testRateandAllowance10.Frequency__c = 'Daily';
    testRateandAllowance10.Amount_ETU_EBA__c = 9;
    testRateandAllowance10.Amount_LE_EBA__c = 10;
    testRateandAllowances.add(testRateandAllowance10);  

    RateandAllowance__c testRateandAllowance11 = new RateandAllowance__c();
    testRateandAllowance11.Name = 'Fares Own Vehicle';
    testRateandAllowance11.Type__c = '2. Allowances';
    testRateandAllowance11.Frequency__c = 'Daily';
    testRateandAllowance11.Amount_ETU_EBA__c = 11;
    testRateandAllowance11.Amount_LE_EBA__c = 12;
    testRateandAllowances.add(testRateandAllowance11);  

    RateandAllowance__c testRateandAllowance18 = new RateandAllowance__c();
    testRateandAllowance18.Name = 'Travel Apprentice Year 1';
    testRateandAllowance18.Type__c = '2. Allowances';
    testRateandAllowance18.Frequency__c = 'Daily';
    testRateandAllowance18.Amount_ETU_EBA__c = 13;
    testRateandAllowance18.Amount_LE_EBA__c = 14;
    testRateandAllowances.add(testRateandAllowance18);  

    RateandAllowance__c testRateandAllowance19 = new RateandAllowance__c();
    testRateandAllowance19.Name = 'Travel Apprentice Year 2';
    testRateandAllowance19.Type__c = '2. Allowances';
    testRateandAllowance19.Frequency__c = 'Daily';
    testRateandAllowance19.Amount_ETU_EBA__c = 13;
    testRateandAllowance19.Amount_LE_EBA__c = 14;
    testRateandAllowances.add(testRateandAllowance19);  

    RateandAllowance__c testRateandAllowance20 = new RateandAllowance__c();
    testRateandAllowance20.Name = 'Travel Apprentice Year 3';
    testRateandAllowance20.Type__c = '2. Allowances';
    testRateandAllowance20.Frequency__c = 'Daily';
    testRateandAllowance20.Amount_ETU_EBA__c = 13;
    testRateandAllowance20.Amount_LE_EBA__c = 14;
    testRateandAllowances.add(testRateandAllowance20);  

    RateandAllowance__c testRateandAllowance21 = new RateandAllowance__c();
    testRateandAllowance21.Name = 'Travel Apprentice Year 4';
    testRateandAllowance21.Type__c = '2. Allowances';
    testRateandAllowance21.Frequency__c = 'Daily';
    testRateandAllowance21.Amount_ETU_EBA__c = 13;
    testRateandAllowance21.Amount_LE_EBA__c = 14;
    testRateandAllowances.add(testRateandAllowance21);  

    RateandAllowance__c testRateandAllowance12 = new RateandAllowance__c();
    testRateandAllowance12.Name = 'Superannuation';
    testRateandAllowance12.Type__c = '3. On Costs';
    testRateandAllowance12.Frequency__c = 'Percent';
    testRateandAllowances.add(testRateandAllowance12);      

    RateandAllowance__c testRateandAllowance13 = new RateandAllowance__c();
    testRateandAllowance13.Name = 'Annual Leave Loading';
    testRateandAllowance13.Type__c = '3. On Costs';
    testRateandAllowance13.Frequency__c = 'Percent';
    testRateandAllowances.add(testRateandAllowance13);      

    RateandAllowance__c testRateandAllowance14 = new RateandAllowance__c();
    testRateandAllowance14.Name = 'Long Service Leave';
    testRateandAllowance14.Type__c = '3. On Costs';
    testRateandAllowance14.Frequency__c = 'Percent';
    testRateandAllowances.add(testRateandAllowance14);      

    RateandAllowance__c testRateandAllowance15 = new RateandAllowance__c();
    testRateandAllowance15.Name = 'Hourly Rate with Allowances';
    testRateandAllowance15.Type__c = '5. Hourly Rates';
    testRateandAllowance15.Frequency__c = 'Percent';
    testRateandAllowances.add(testRateandAllowance15);      

    RateandAllowance__c testRateandAllowance16 = new RateandAllowance__c();
    testRateandAllowance16.Name = 'Hourly Rate with On Costs';
    testRateandAllowance16.Type__c = '5. Hourly Rates';
    testRateandAllowance16.Frequency__c = 'Summary';
    testRateandAllowances.add(testRateandAllowance16);     
     
    RateandAllowance__c testRateandAllowance17 = new RateandAllowance__c();
    testRateandAllowance17.Name = 'Hourly Rate Base';
    testRateandAllowance17.Type__c = '5. Hourly Rates';
    testRateandAllowance17.Frequency__c = 'Percent';
    testRateandAllowances.add(testRateandAllowance17);  

    RateandAllowance__c testRateandAllowance22 = new RateandAllowance__c();
    testRateandAllowance22.Name = '$0 - 3.0 million';
    testRateandAllowance22.Domain__c = 'Project Size';
    testRateandAllowance22.Amount_ETU_EBA__c = 15;
    testRateandAllowance22.Amount_LE_EBA__c = 16;
    testRateandAllowances.add(testRateandAllowance22);  

    RateandAllowance__c testRateandAllowance23 = new RateandAllowance__c();
    testRateandAllowance23.Name = '0 - 15 floors';
    testRateandAllowance23.Domain__c = 'Building Height';
    testRateandAllowance23.Amount_ETU_EBA__c = 17;
    testRateandAllowance23.Amount_LE_EBA__c = 18;
    testRateandAllowances.add(testRateandAllowance23);  

    RateandAllowance__c testRateandAllowance24 = new RateandAllowance__c();
    testRateandAllowance24.Name = 'CBD';
    testRateandAllowance24.Domain__c = 'Project';
    testRateandAllowance24.Frequency__c = 'Hourly';
    testRateandAllowance24.Amount_ETU_EBA__c = 19;
    testRateandAllowance24.Amount_LE_EBA__c = 20;
    testRateandAllowances.add(testRateandAllowance24);  

    RateandAllowance__c testRateandAllowance25 = new RateandAllowance__c();
    testRateandAllowance25.Name = 'Income Protection';
    testRateandAllowance25.Domain__c = 'Project';
    testRateandAllowance25.Frequency__c = 'Weekly';
    testRateandAllowance25.Amount_ETU_EBA__c = 21;
    testRateandAllowance25.Amount_LE_EBA__c = 22;
    testRateandAllowances.add(testRateandAllowance25);  

    RateandAllowance__c testRateandAllowance26 = new RateandAllowance__c();
    testRateandAllowance26.Name = 'Redundancy';
    testRateandAllowance26.Domain__c = 'Project';
    testRateandAllowance26.Frequency__c = 'Weekly';
    testRateandAllowance26.Amount_ETU_EBA__c = 23;
    testRateandAllowance26.Amount_LE_EBA__c = 24;
    testRateandAllowances.add(testRateandAllowance26);  

    insert testRateandAllowances;

  /************************************************************************************
   **  createTestProjects
   ************************************************************************************/
    // Create project records
    Staff_Cost_Constants__c company = [SELECT Id FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];
    RateandAllowance__c size = [SELECT Id FROM RateandAllowance__c WHERE Name = '$0 - 3.0 million'];
    RateandAllowance__c height = [SELECT Id FROM RateandAllowance__c WHERE Name = '0 - 15 floors'];
    
    List<Project__c> testProjects = new List<Project__c>();
    Project__c testProject1 = new Project__c();
    testProject1.Name = 'TestProjectElectrical1';
    testProject1.Company__c = company.Id;
    testProject1.Project_Type__c = 'Electrical';
    testProject1.Type__c = 'LE';
    testProject1.Project_Size__c = size.Id;
    testProject1.Building_Height__c = height.Id;
    testProject1.CBD__c = True;
    testProject1.Income_Protection__c = True;
    testProject1.Redundancy__c = True;
    testProject1.Picnic_Day__c = True;
    testProject1.Start_Date__c = system.today();
    testProject1.End_Date__c = system.today() + 100;
    testProject1.Active__c = True;
    User usr2=  [Select Id From User where Name = 'David Strangward' limit 1];
    Contact contact1 =  [Select Id From Contact limit 1];
    testProject1.LE_Technical_Resource__c = usr2.Id;
    testProject1.LE_Project_Manager__c = usr2.Id;
    testProject1.Role_Site_Supervisor__c = contact1.Id;
     
    testProjects.add(testProject1);      

    Project__c testProject2 = new Project__c();
    testProject2.Name = 'TestProjectElectrical2';
    testProject2.Company__c = company.Id;
    testProject2.Project_Type__c = 'Electrical';
    testProject2.Type__c = 'LE';
    testProject2.Project_Size__c = size.Id;
    testProject2.Building_Height__c = height.Id;
    testProject2.CBD__c = True;
    testProject2.Income_Protection__c = True;
    testProject2.Redundancy__c = True;
    testProject2.Picnic_Day__c = True;
    testProject2.Start_Date__c = system.today();
    testProject2.End_Date__c = system.today() + 100;
    testProject2.Active__c = True;
    usr2 = [Select Id From User where Name = 'David Strangward' limit 1];
    contact1 =  [Select Id From Contact limit 1];
    testProject2.LE_Technical_Resource__c = usr2.Id;
    testProject2.LE_Project_Manager__c = usr2.Id;
    testProject2.Role_Site_Supervisor__c = contact1.Id;
     
    testProjects.add(testProject2);      

    Project__c testProject3 = new Project__c();
    testProject3.Name = 'TestProjectElectrical3';
    testProject3.Company__c = company.Id;
    testProject3.Project_Type__c = 'Electrical';
    testProject3.Type__c = 'LE';
    testProject3.Project_Size__c = size.Id;
    testProject3.Building_Height__c = height.Id;
    testProject3.CBD__c = True;
    testProject3.Income_Protection__c = True;
    testProject3.Redundancy__c = True;
    testProject3.Picnic_Day__c = True;
    testProject3.Start_Date__c = system.today();
    testProject3.End_Date__c = system.today() + 100;
    testProject3.Active__c = True;
    usr2 = [Select Id From User where Name = 'David Strangward' limit 1];
    contact1 =  [Select Id From Contact limit 1];
    testProject3.LE_Technical_Resource__c = usr2.Id;
    testProject3.LE_Project_Manager__c = usr2.Id;
    testProject3.Role_Site_Supervisor__c = contact1.Id;
     
    testProjects.add(testProject3);      

    Project__c testProject4 = new Project__c();
    testProject4.Name = 'TestProjectElectrical4';
    testProject4.Company__c = company.Id;
    testProject4.Project_Type__c = 'Electrical';
    testProject4.Type__c = 'LE';
    testProject4.Project_Size__c = size.Id;
    testProject4.Building_Height__c = height.Id;
    testProject4.CBD__c = True;
    testProject4.Income_Protection__c = True;
    testProject4.Redundancy__c = True;
    testProject4.Picnic_Day__c = True;
    testProject4.Start_Date__c = system.today();
    testProject4.End_Date__c = system.today() + 100;
    testProject4.Active__c = True;
    usr2 = [Select Id From User where Name = 'David Strangward' limit 1];
    contact1 =  [Select Id From Contact limit 1];
    testProject4.LE_Technical_Resource__c = usr2.Id;
    testProject4.LE_Project_Manager__c = usr2.Id;
    testProject4.Role_Site_Supervisor__c = contact1.Id;
     
    testProjects.add(testProject4);      

    // Create project records
    Project__c testProject5 = new Project__c(); 
    testProject5.Name = 'TestProjectManagement';
    testProject5.Company__c = company.Id;
    testProject5.Project_Type__c = 'Management';
//    testProject5.Type__c = 'LE';
    testProject5.Start_Date__c = system.today();
    testProject5.End_Date__c = system.today() + 100;
    testProjects.add(testProject5);       

    insert testProjects;       

    // Verify that test account created by test setup method is unaltered.
    Project__c project = [SELECT Name, Company__c, Type__c, LE_Technical_Resource__c FROM Project__c WHERE Name='TestProjectElectrical1' LIMIT 1];
    System.assertEquals('LE', project.Type__c);
    System.assertEquals(usr2.Id, project.LE_Technical_Resource__c);

  /************************************************************************************
   **  createTestItems
   ************************************************************************************/
    //  get appropriate ids
    List<Project__c> tempProjectsElectrical = [SELECT id, Name FROM Project__c WHERE name LIKE 'TestProjectElectrical%'];    
    Project__c tempProjectManagement = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectManagement'];    
    Id TypeId = Schema.SObjectType.Progress__c.getRecordTypeInfosByName().get('Construction Stages 4').getRecordTypeId();    

    // Create item records
    // Electrical Items
    List<Progress__c> testItems = new List<Progress__c>();
    Integer j = 1;
    for (Project__c p : tempProjectsElectrical){
      testItems.add(new Progress__c(Name = 'Test Item' + j + 'A', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Not Started', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 01', Stage_Index__c = 0, Build_Stage_Index__c=0, Aggregate_Item__c='AggItem01'));
      testItems.add(new Progress__c(Name = 'Test Item' + j + 'B', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Started', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 01', Build_Stage__c = 'Pending', Stage_Index__c = 0, Build_Stage_Index__c=0, Aggregate_Item__c='AggItem01'));
	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'C', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Finished', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 01', Build_Stage__c = 'Cutout', Stage_Index__c = 0, Build_Stage_Index__c=2, Aggregate_Item__c='AggItem01'));
  	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'D', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Not Started', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 01', Build_Stage__c = 'Cutout', Stage_Index__c = 0, Build_Stage_Index__c=2));
      testItems.add(new Progress__c(Name = 'Test Item' + j + 'E', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Started', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 01', Build_Stage__c = 'Cutout', Stage_Index__c = 0, Build_Stage_Index__c=2));
	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'F', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Finished', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Commission', Stage_Index__c = 0, Build_Stage_Index__c=4));
  	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'G', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Finished', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Fitoff', Stage_Index__c = 0, Build_Stage_Index__c=4));
      testItems.add(new Progress__c(Name = 'Test Item' + j + 'H', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Not Started', Stage__c = 'Fitoff', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Fitoff', Stage_Index__c = 0, Build_Stage_Index__c=4));
	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'I', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Started', Stage__c = 'Commission', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Fitoff', Stage_Index__c = 0, Build_Stage_Index__c=4));
  	  testItems.add(new Progress__c(Name = 'Test Item' + j + 'J', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Finished', Stage__c = 'Commission', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Fitoff', Stage_Index__c = 0, Build_Stage_Index__c=4));
      testItems.add(new Progress__c(Name = 'Test Item' + j + 'K', Project__c = p.Id, RecordTypeId = TypeId, Item_Status_New__c = 'Started', Stage__c = 'Pending', Company_Cost_Centre__c = 'Electrical', Level__c = 'Level 02', Build_Stage__c = 'Pending', Stage_Index__c = 0, Build_Stage_Index__c=0));
      j++;
    }
    insert testItems;
    

  /************************************************************************************
   **  createTestSprints
   ************************************************************************************/
     //  get appropriate ids
    Project__c tempProjectElectrical1 = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectElectrical1'];    
    Project__c tempProjectElectrical2 = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectElectrical2'];    
    Project__c tempProjectElectrical3 = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectElectrical3'];    
    Project__c tempProjectManagement1 = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectManagement'];    
   
    // Create sprint records
    //  Project 1
    //  1 current sprint only 
    List<Sprint__c> testSprints = new List<Sprint__c>();
    Sprint__c testSprint;
    testSprint = new Sprint__c();
    testSprint.Name = 'Test Sprint Electrical1 1';
    testSprint.Date_Start__c = system.today();
    testSprint.Date_End__c = system.today() + 7;
    testSprint.Sequence__c = 0;
    testSprint.Project__c = tempProjectElectrical1.Id;
    testSprints.add(testSprint);

    //  Project 2
    //  create multiple sprints before and after current date
    for (Integer i = -2; i < 3; i++){
      testSprint = new Sprint__c();
      testSprint.Name = 'Test Sprint Electrical2 ' + (i + 2);
      testSprint.Date_Start__c = system.today() + (7 * i);
      testSprint.Date_End__c = system.today() + (7 * i * 2);
      testSprint.Sequence__c = i + 2;
      testSprint.Project__c = tempProjectElectrical2.Id;
      testSprints.add(testSprint);
    }

    //  Project 3
    //  create sprints before current date
    for (Integer i = -4; i < 1; i++){
      testSprint = new Sprint__c();
      testSprint.Name = 'Test Sprint Electrical3 ' + (i + 4);
      testSprint.Date_Start__c = system.today() + (7 * i);
      testSprint.Date_End__c = system.today() + (7 * i * 2);
      testSprint.Sequence__c = i + 4;
      testSprint.Project__c = tempProjectElectrical3.Id;
      testSprints.add(testSprint);
    }

    //  Project 4
    //  no sprints
    
    //  Project Management
    for (Integer i = 1; i < 4; i++){
      testSprint = new Sprint__c();
      testSprint.Name = 'Test Sprint Management ' + i;
      testSprint.Date_Start__c = system.today();
      testSprint.Date_End__c = system.today() + 7;
      testSprint.Sequence__c = i;
      testSprint.Project__c = tempProjectManagement1.Id;
      testSprints.add(testSprint);
    }
    
    insert testSprints;     
system.debug('Sprints = ' + [SELECT Name FROM Sprint__c]);    

  /************************************************************************************
   **  createTestSprintItem
   ************************************************************************************/
    //  get appropriate ids
    List<Project__c> tempProject = [SELECT Id, Name FROM Project__c]; 
    List<Sprint_Items__c> sprintItems = new List<Sprint_Items__c>();

    //  create sprint map
    Map <Id, List<Sprint__c>> sprintMapByProject = new Map <Id, List<Sprint__c>>();
    for (Sprint__c s : [SELECT Id, Name, Project__c, Project__r.Name, Sequence__c FROM Sprint__c WHERE name LIKE 'Test Sprint Electrical%']){
    	if (s.Project__r.Name != 'TestProjectElectrical4'){
        if(sprintMapByProject.containsKey(s.Project__c)){
          // add the stage to an existing recordtype
          sprintMapByProject.get(s.Project__c).add(s);
        } else {
          //  add the record type key and list of stages 
          List<Sprint__c> newList = new List<Sprint__c>(); 
          newList.add(s); 
          sprintMapByProject.put(s.Project__c, newList);
        }
    	}
    }    

    //  create item map
    Map <Id, List<Progress__c>> itemMapByProject = new Map <Id, List<Progress__c>>();
    for (Progress__c p : [SELECT Id, Name, Project__c, Project__r.Name FROM Progress__c]){
    	if (p.Project__r.Name != 'TestProjectElectrical4'){
        if(itemMapByProject.containsKey(p.Project__c)){
          // add the stage to an existing recordtype
          itemMapByProject.get(p.Project__c).add(p);
        } else {
          //  add the record type key and list of stages 
          List<Progress__c> newList = new List<Progress__c>(); 
          newList.add(p); 
          itemMapByProject.put(p.Project__c, newList);
        }
    	}
    }    

    // Create sprint item records
    //  cycle through project and sprints
    Integer i;
    for (Id p : itemMapByProject.keySet()){
      for (Sprint__c s : sprintMapByProject.get(p)){
//    	if (p.Name != 'TestProjectManagement'){
        for (Progress__c pi : itemMapByProject.get(p)){
          Sprint_Items__c SprintItem = new Sprint_Items__c(Sprint__c = s.Id, Item__c = pi.Id, Sprint_Item_Stage__c = 'Pending'); 
          sprintItems.add(SprintItem);
        } 
    	} 
    }

    insert sprintItems; 
    
    //  create sprint items map
    Map <Id, List<Sprint_Items__c>> sprintItemMapByProject = new Map <Id, List<Sprint_Items__c>>();
    for (Sprint_Items__c p : [SELECT Name, Sprint__r.Project__c, Sprint__r.Project__r.Name, Item__r.Name, Item__r.Item_Status_New__c, Item__r.Stage__c FROM Sprint_Items__c]){
    	if (p.Sprint__r.Project__r.Name != 'TestProjectElectrical4'){
        if(sprintItemMapByProject.containsKey(p.Sprint__r.Project__c)){
          // add the stage to an existing recordtype
          sprintItemMapByProject.get(p.Sprint__r.Project__c).add(p);
        } else {
          //  add the record type key and list of stages 
          List<Sprint_Items__c> newList = new List<Sprint_Items__c>(); 
          newList.add(p); 
          sprintItemMapByProject.put(p.Sprint__r.Project__c, newList);
        }
    	}
    }    

system.debug('Sprint Items = ' + [SELECT Name, Item__r.Item_Status_New__c, Item__r.Stage__c FROM Sprint_Items__c]);    

  /************************************************************************************
   **  createTestItemComponents
   ************************************************************************************/
   // Create ItemComponent records
   List<Item_Component__c> testItemComponents = new List<Item_Component__c>();
   for ( i = 1; i <= 60; i++){ 
     Item_Component__c testItemComponent1 = new Item_Component__c();
     testItemComponent1.Name = 'Test Item Component ' + i;
     testItemComponent1.Type__c = 'Bakelite';
    testItemComponents.add(testItemComponent1);
   }
   insert testItemComponents;       
    
    // test that ItemComponents created
    AggregateResult res = [select count(id) from Item_Component__c ];
    System.assertEquals(60, integer.valueof(res.get('expr0')));

  /***********************************************************
   **  create Activity__c
   ************************************************************************************/
    //  get appropriate ids
    List<Activity__c> activities = new List<Activity__c>();
    
    // Create item records for all projects on items H, I, J, K
    //  cycle through items by project
    for (Id projectKey : sprintItemMapByProject.keySet()){
      i = 1;
      for (Sprint_Items__c p : sprintItemMapByProject.get(projectKey)){
      	if (p.Item__r.Name.right(1) == 'H' || p.Item__r.Name.right(1) == 'I' || p.Item__r.Name.right(1) == 'J' || p.Item__r.Name.right(1) == 'K'){
          activities.add(new Activity__c(Sprint_Item__c = p.Id, Item__c = p.Item__c, Description__c = 'Test Sprint Item Activity ' + i, Status__c = p.Item__r.Item_Status_New__c, Stage__c = p.Item__r.Stage__c));
          i++;
      	}
    	} 
    }
          
    insert activities;
system.debug('activities = ' + activities);    

  /************************************************************************************
   **  createTestItemComponentUses
   ************************************************************************************/
   //  get required data
   List<Item_Component_Use__c> listICU = new List<Item_Component_Use__c>();
   Id activityId = [SELECT Id FROM Activity__c LIMIT 1].Id;
   String stage;
      
    Map<String, Item_Component__c> itemComponents = new Map<String, Item_Component__c>();
    for (Item_Component__c tic : [SELECT Id, Name FROM Item_Component__c])
      itemComponents.put(tic.Name, tic);

    // Create item records for all projects on items H, I, J, K
    //  cycle through items by project
    for (Id projectKey : sprintItemMapByProject.keySet()){
      i = 0;
      for (Sprint_Items__c p : sprintItemMapByProject.get(projectKey)){
      	if (p.Item__r.Name.right(1) != 'H' && p.Item__r.Name.right(1) != 'I' && p.Item__r.Name.right(1) != 'J' && p.Item__r.Name.right(1) != 'K'){
          if (i==0) stage = 'Pending'; else if (i==1) stage = 'Roughin'; else if (i==2) stage = 'Cutout'; else stage = 'Fitoff';
          listICU.add(new Item_Component_Use__c(Item__c = p.Item__c, Item_Component__c = itemComponents.get('Test Item Component ' + (i+1)).id, Number_Finished__c = 0*i, Quantity__c = 2*i, Stage__c = stage));
          i++; 
      	}
    	} 
    }

    insert listICU;

    //  create item component use map
    Map <Id, List<Item_Component_Use__c>> itemUseMapByItem = new Map <Id, List<Item_Component_Use__c>>();
    for (Item_Component_Use__c p : [SELECT Id, Item__c FROM Item_Component_Use__c]){
      if(itemUseMapByItem.containsKey(p.Item__c)){
        // add the stage to an existing recordtype
        itemUseMapByItem.get(p.Item__c).add(p);
      } else {
        //  add the record type key and list of stages 
        List<Item_Component_Use__c> newList = new List<Item_Component_Use__c>(); 
        newList.add(p); 
        itemUseMapByItem.put(p.Item__c, newList);
      }
    }    
system.debug('itemUseMapByItem = ' + itemUseMapByItem);    
    
    // test that ItemComponentUses created
    AggregateResult res1 = [select count(id) from Item_Component_Use__c];
    System.assertNotEquals(0, integer.valueof(res1.get('expr0')));      

    //  Need to query the data in order to get the formula fields to update
    List<Item_Component_Use__c> queryitems = [select Stage__c, Quantity_Remaining__c from Item_Component_Use__c];
    Item_Component_Use__c item = [select Stage__c, Quantity_Remaining__c from Item_Component_Use__c WHERE Item_Component__c = :testItemComponents[2].id LIMIT 1];

  /************************************************************************************
   **  createTestItemComponentAudits
   ************************************************************************************/
   //  get required data
   List<ItemComponentUseAudi__c> listICUA = new List<ItemComponentUseAudi__c>();

    for (Id siKey : sprintItemMapByProject.keySet()){
    	for (Sprint_Items__c si : sprintItemMapByProject.get(siKey)){
	      //  exclude activity based items
      	if (si.Item__r.Name.right(1) != 'H' && si.Item__r.Name.right(1) != 'I' && si.Item__r.Name.right(1) != 'J' && si.Item__r.Name.right(1) != 'K'){
       		for(Item_Component_Use__c icu : itemUseMapByItem.get(si.Item__c)){
       			ItemComponentUseAudi__c tempICUA = new ItemComponentUseAudi__c(Item_Component_Use__c = icu.Id, Sprint__c = si.Sprint__c, Sprint_Item__c = si.Id);
       			listICUA.add(tempICUA);
     	  	}
      	}
     	}
    } 

    insert listICUA;


  /************************************************************************************
   **  createTestStaff
   ************************************************************************************/
    // Create staff  records
    List<RateandAllowance__c> rates = [SELECT Id FROM RateandAllowance__c WHERE Domain__c = 'Staff Type'];
    List<Staff__c> testStaffers = new List<Staff__c>();
    i = 0;
    for (RateandAllowance__c rate : rates){
      Staff__c testStaff = new Staff__c();
      testStaff.Name = 'Test Staff ' + i;
      testStaff.Staff_Type__c = rate.Id;
      testStaff.Status__c = true;
      if (i < 4){
        testStaff.Vehicle_Provide__c = true;
      }
      testStaffers.add(testStaff);      
      i++; 
    }

     insert testStaffers;       


  /************************************************************************************
   **  createTestProjectRoles
   ************************************************************************************/
    // Create staff profile records
    List<Staff__c> staff = [SELECT Id, Staff_Type__r.Name FROM Staff__c WHERE Status__c = true];
    Project__c tempProjectElectrical = [SELECT id, Name FROM Project__c WHERE name = 'TestProjectElectrical1'];    
    RateandAllowance__c supervisorId = [SELECT Id FROM RateandAllowance__c WHERE Domain__c = 'Supervisor Type'];

    List<Project_Role__c> testProjectRoles = new List<Project_Role__c>();
    for (Staff__c s : staff){
      Project_Role__c testRole = new Project_Role__c();
      testRole.Active__c = True;
      testRole.Project__c = tempProjectElectrical.Id; 
      testRole.Staff__c = s.Id;
      if (s.Staff_Type__r.Name == 'Electrician A Grade'){
        testRole.Supervisor__c = supervisorId.Id;
      }
      testRole.Start_Date__c = system.today();
      testRole.End_Date__c = system.today() + 100;
      testProjectRoles.add(testRole);      
    }

     insert testProjectRoles;       

  /************************************************************************************
   **  Upsert_Manning_Schedules_Rates
   ************************************************************************************/
    RateandAllowance__c testRateandAllowance = [SELECT Amount_ETU_EBA__c FROM RateandAllowance__c WHERE Name = 'Redundancy'];
    testRateandAllowance26.Amount_ETU_EBA__c = 25;

    update testRateandAllowance;

  /************************************************************************************
   **  Upsert_Manning_Schedules
   ************************************************************************************/
    Staff_Cost_Constants__c testStaffConstant = [SELECT Working_Hours_Per_Year__c FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];

    testStaffConstant.Working_Hours_Per_Year__c = 2010;

    update testStaffConstant;

  /************************************************************************************
   **  Upsert_Manning_Schedules
   ************************************************************************************/
    Staff_Cost_Constants__c testStaffConstant1 = [SELECT Working_Hours_Per_Year__c FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];

    testStaffConstant1.Working_Hours_Per_Year__c = 2010;

    update testStaffConstant1;

 /************************************************************************************
   **  Upsert_Manning_Schedules_Staff
   ************************************************************************************/
   Staff__c testStaff = [SELECT Vehicle_Provide__c FROM Staff__c WHERE Name = 'Test Staff 0'];

   testStaff.Vehicle_Provide__c = false;
   update testStaff;    

 /************************************************************************************
   **  Upsert_Manning_Schedules_Days
   ************************************************************************************/
   Project_Days_Off__c day = [SELECT Mandatory_Annual_Leave__c FROM Project_Days_Off__c WHERE Month__c = 'January'];

   day.Mandatory_Annual_Leave__c = 2;

   update day;    

 /************************************************************************************
   **  Upsert_Manning_Schedules_Roles
   ************************************************************************************/
   List<Project_Role__c> testRoles = [SELECT End_Date__c FROM Project_Role__c];

   testRoles[0].End_Date__c = system.today() + 80;

   update testRoles[0];    

 /************************************************************************************
   **  Create issue
   ************************************************************************************/
   List<Issue__c> issues = new List<Issue__c>();

   for (Integer a = 1; a <= 30; a++){
     issues.add(new Issue__c(Description__c = 'test issue ' + a, Next_Step__c = 'issue next step', Title__c = 'this is the title of the issue' + a, Type__c = 'Technical Query',
                             Project__c = tempProjectElectrical.Id));
   }
   insert issues; 
   

   
 /************************************************************************************
   **  Update issue
   ************************************************************************************/
   Issue__c testIssue1 = [SELECT Next_Step__c FROM Issue__c LIMIT 1];

   testIssue1.Next_Step__c = 'another next step';
   
   update testIssue1;    
   
 /************************************************************************************
   **  Create Staff_Activity__c
   ************************************************************************************/

   Staff__c staff1 = [SELECT Id FROM Staff__c LIMIT 1];
   Staff_Activity__c staffAct = new Staff_Activity__c();
   staffAct.Staff__c = staff1.Id;
   insert staffAct;

  /************************************************************************************
   **  createTestIssueItems
   ************************************************************************************/
    //  get appropriate ids
    Progress__c item1 = [SELECT Id, Name FROM progress__c WHERE Name = 'Test Item1A' LIMIT 1];
    Issue__c issue1 = [SELECT Id FROM Issue__c WHERE Project__c = :tempProjectElectrical.Id LIMIT 1];
    
    // Create issue item record
    Issue_Item__c IssueItem = new Issue_Item__c(Issue_Notifications__c = issue1.Id, Item__c = item1.Id);

    insert IssueItem;
   }  
  
}