public with sharing class am_Issue {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          14/5/2017
   *  Modified by:   
   *  Date Modified:
   *
   *  Description:   Handles everything related to Issues.
   ***********************************************************************************************/  

    private ApexPages.StandardSetController standardSetController;
    private ApexPages.StandardController standardController;
    public List<Issue__c> selectedIssues {set; get;}
    String callAction;
    
    //controls how many issues are displayed on page 1
    //  default for 5 columns
    private static Integer FIRST_BREAK = 19;
    //controls how many issues are displayed on subsequent pages
    private static Integer SUBSEQ_BREAKS = 20;
    private static Integer WIDTH_OF_TITLE = 35;
    private static Integer WIDTH_OF_DESCRIPTION = 60;

    public List<List<Issue__c>> paginatedIssues {get; private set; }

    public static void saveItems(List<Progress__c> aItems){
      update aItems;
    }

    @InvocableMethod(label='closeIssues' description='Closes site issues with no open issue items')
    public static void closeIssues() {
  	  //  checks that all issue items are closed and closes the issue
  	  List<Issue__c> issuesToClose = new List<Issue__c>();
  	  List<Issue_Item__c> openIssueItems = [SELECT Id, Issue_Notifications__c, Status__c,  Issue_Title__c 
  	                                        FROM Issue_Item__c 
  	                                        WHERE Resolved__c = false];
  	  
      //  get list of open issues to close
  	  Integer openCount = 0;  	  	
  	  Boolean itemRelated = false;
  	  for (Issue__c is : [SELECT Id, Status__c, Date_Closed__c, Title__c 
  	                      FROM Issue__c WHERE am_Standard__c = false AND Type__c = 'Site Issue' AND Status__c != 'Closed']){
        for (Integer i=0; i < openIssueItems.size(); i++){
          if (openIssueItems[i].Issue_Notifications__c == is.Id){
          	itemRelated = true;
            openCount =+ 1;
          }
        }
        if (openCount <= 0 && itemRelated == true)
          issuesToClose.add(is);

        itemRelated = false; 
        openCount = 0;             	        
  	  }

      // update fields in issue records
      for (Integer i=0; i<issuesToClose.size(); i++){
      	issuesToClose[i].Status__c = 'Closed';
      	issuesToClose[i].Date_Closed__c = Date.today();
      }
      
      update issuesToClose;
    }

   @AuraEnabled 
    public static void createIssue (Issue__c aIssue){
      aIssue.Responsible_Person1__c = [SELECT Id FROM Contact WHERE Id IN 
                                       (SELECT Role_Site_Supervisor__c FROM Project__c WHERE Id = :aIssue.Project__c) LIMIT 1].Id;
      aIssue.Raised_by1__c = [SELECT Id FROM Contact WHERE Name LIKE :aIssue.Raised_by__c LIMIT 1].Id;
      insert aIssue; 
    }
    
    public am_Issue(ApexPages.StandardSetController SetController){
      List<Issue__c> issueIds = SetController.getSelected();    
        selectedIssues = [Select Id, Name, Title__c, Description__c, Next_Step__c, Responsible_Person__c, Resolution__c, 
                          Date_Closed__c, Date_Created__c 
                          from Issue__c where id in :issueIds];
        String numColumns = ApexPages.currentPage().getParameters().get('pagecols');
        prepareIssueLinesForPrinting(numColumns);
        standardSetController = SetController;
    } 

    public am_Issue(ApexPages.StandardController Controller){
        selectedIssues = [Select Id, Name, Title__c, Next_Step__c, Responsible_Person__c, Resolution__c, 
                          Date_Closed__c, Date_Created__c 
                          from Issue__c where id = :Controller.getId()];
        standardController = Controller;
    }


    //splits the issues into an approximate number of rows that can be displayed per page
    private void prepareIssueLinesForPrinting(String numColumns)
    {
      if(numColumns == '6'){
        //controls how many issues are displayed on page 1
        FIRST_BREAK = 11;
        //controls how many issues are displayed on subsequent pages
        SUBSEQ_BREAKS = 15;
        WIDTH_OF_TITLE = 20;
        WIDTH_OF_DESCRIPTION = 35;
      }
        
        paginatedIssues = new List<List<Issue__c>>();
        List<Issue__c> pageOfIssues = new List<Issue__c>();
    
        Integer counter = 0;
        Integer totalCounter = 0;
        Integer tempCounter = 0;

        boolean firstBreakFound = false;
        boolean setSubSeqBreak = false;        
        Integer breakPoint = FIRST_BREAK;

        for(Issue__c i : selectedIssues)
        {
          if(counter <= breakPoint)
            {
                pageOfIssues.add(i);
                //  check for number of rows in issue
                if (!String.isBlank(i.Title__c)) 
                      if(i.Title__c.length() / WIDTH_OF_TITLE > 0)
                          tempCounter += (i.Title__c.length() / WIDTH_OF_TITLE) ;                
                if (!String.isBlank(i.Next_Step__c)) 
                      if(i.Next_Step__c.length() / WIDTH_OF_DESCRIPTION > tempCounter) {
                          tempCounter = (i.Next_Step__c.length() / WIDTH_OF_DESCRIPTION);                 
                      }
                counter += tempCounter;
                counter++; 
                totalCounter++;
                tempCounter = 0;
            }

            if(counter >= breakPoint)
            {
                //  set up indicator to change lines per page after first
                if (!firstBreakFound) 
                {
                    firstBreakFound = true;
                    setSubSeqBreak  = true;
                }
                counter = 0;
                paginatedIssues.add(pageOfIssues);
                pageOfIssues = new List<Issue__c>();
            }
            
            if(setSubSeqBreak) 
            {
                breakPoint = SUBSEQ_BREAKS;
                setSubSeqBreak = false;
            }
            
            // on the last page add to the list
            if (selectedIssues.size() == totalCounter){
                paginatedIssues.add(pageOfIssues);
            }
        }
    }
    
}