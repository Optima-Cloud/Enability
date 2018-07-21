public class IssuesController {
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

    @AuraEnabled 
    public static void createIssue (Issue__c aIssue){
      insert aIssue; 
    }
    
    @AuraEnabled 
    public static List<String> getPickValues(Sobject object_name, String field_name) {
      List<String> options = new List<String>(); //new list for holding all of the picklist options

      Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
        options.add(a.getValue()); //add the value and label to our final list
      }
      return options;
    }

    public static List<Issue__c> getIssues(String aProject) {
      // used to populate issue list for site application 
      List<Issue__c> issuesAll = [SELECT Id, Name, Title__c, am_Standard__c FROM Issue__c 
                               WHERE Project__c = :aProject AND Status__c != 'Cancelled' AND Status__c != 'Closed' AND Type__c = 'Site Issue' 
                               ORDER BY am_Standard__c, Title__c ASC ]; 
      List<Issue__c> issuesStandard = new List<Issue__c>();
      List<Issue__c> issuesSpecific = new List<Issue__c>();
       
      //  sort list so standard issues are at the top
      for (Integer i=0; i<issuesAll.size(); i++){
      	if (issuesAll[i].am_Standard__c == true)
      	  issuesStandard.add(issuesAll[i]);
      	else
      	  issuesSpecific.add(issuesAll[i]);
      }
      
      for (Issue__c is :issuesSpecific){
      	issuesStandard.add(is);
      }
      
      return issuesStandard;
    }  
     
    public IssuesController(ApexPages.StandardSetController SetController){
        List<Issue__c> issueIds = SetController.getSelected();
        selectedIssues = [Select Id, Name, Title__c, Description__c, Next_Step__c, Responsible_Person__c, Resolution__c, 
                          Date_Closed__c, Date_Created__c, Our_Quote_Number__c 
                          from Issue__c where id in :issueIds ORDER BY Our_Quote_Number__c];

        String numColumns = ApexPages.currentPage().getParameters().get('pagecols');
        prepareIssueLinesForPrinting(numColumns);
        standardSetController = SetController;
    } 

    public IssuesController(ApexPages.StandardController Controller){
        selectedIssues = [Select Id, Name, Title__c, Next_Step__c, Responsible_Person__c, Resolution__c, 
                          Date_Closed__c, Date_Created__c, Our_Quote_Number__c 
                          from Issue__c where id = :Controller.getId() ORDER BY Our_Quote_Number__c];

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