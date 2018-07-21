public class am_UniversalSearchArguments {
  /***********************************************************************************************
   *  Written by:    David Strangward
   *  Date:          10/06/2017
   *  Modified by:  
   *  Date Modified: 
   *
   *  Description:   Contains a range of elements to provide multiple fields to search for objects
   *                 across.
   *                 
   ***********************************************************************************************/  

   Public Id sprintId {
   	 get;
   	 set;
   } 

   Public Id projectId {
   	 get; 
   	 set;
   } 

   Public Id itemId {
   	 get; 
   	 set;
   } 

   Public String project {
   	 get; 
   	 set { 
   	 	 if (String.isNotBlank(value))
   	 	   projectId = Id.valueOf(value);
   	 	 project = value;
   	 }
   } 

   Public String sprint {
   	 get;
   	 set { 
   	 	 if (String.isNotBlank(value))
   	 	   sprintId = Id.valueOf(value);
   	 	 sprint = value;
   	 }
   } 

   Public String item {
   	 get; 
   	 set { 
   	 	 if (String.isNotBlank(value))
   	 	   itemId = Id.valueOf(value);
   	 	 item = value;
   	 }
   } 

   Public String level { get; set; } 

   Public String aggregateItem { get; set; } 

   Public am_UniversalSearchArguments(){
   }

   Public am_UniversalSearchArguments(String aAggregateItem, String aItem, String aSprint, String aProject){
   	 aggregateItem = aAggregateItem; 
   	 item = aItem; 
   	 sprint = aSprint;
   	 project = aProject;
   }
   
   
   Public Id getProjectID() {
     //  checks through the class properties and returns the project Id
     String query = '';
     Id pid = null;
     sObject queryResult;
     if (project != null)
       pid = project;
     else if (sprint != null)
       query = 'SELECT Project__c FROM Sprint__c WHERE Id = :sprint LIMIT 1';
     else if (item != null)
       query = 'SELECT Project__c FROM Progress__c WHERE Id = :item LIMIT 1';

     if (pid == null && String.isNotBlank(query)){ 
       queryResult = Database.query(query); 
       if (queryResult != null)
         pid = queryResult.Id;
     }
      
     return pid;
   } 
     
}