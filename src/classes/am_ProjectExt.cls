public with sharing class am_ProjectExt {
  /***********************************************************************************************
   *  Written by:        David Strangward
   *  Date:              31/10/2016    
   *  Modified by:      
   *  Date Modified:      
   * 
   *  Description:       Handles all aspects of Visualforce and lightning component 
   *                     pages associated with Activites
   *                
   ***********************************************************************************************/  
    
   @AuraEnabled 
   public static List<Project__c> getProjects(){ 
    //  gets the list of projects for the dropdown project list
    return [SELECT Name, Id FROM Project__c WHERE Active__c = true ORDER BY Name];
  } 

   public static Project__c getProjectDetails(string aProjectId){ 
    //  gets the details of projects for the project item creation 
    return [SELECT Levels__c, Basements__c FROM Project__c WHERE Id = :aProjectId LIMIT 1];
  } 
   
}