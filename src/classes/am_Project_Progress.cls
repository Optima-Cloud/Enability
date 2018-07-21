public class am_Project_Progress {
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                List<Progress__c> distinctProgress = new List<Progress__c>();
                for(AggregateResult ar : [select Level__c, Wing__c, count(Id) from Progress__c group by Level__c, Wing__c]){
                    Progress__c tempdistinctProgress = new Progress__c();
                    tempdistinctProgress.Level__c = (string) ar.get('Level__c');
                    tempdistinctProgress.Level__c = (string) ar.get('Wing__c');
                    distinctProgress.add(tempdistinctProgress);

                    }
                setCon = new ApexPages.StandardSetController(distinctProgress);
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Progress__c> getProjectProgress() {
        return (List<Progress__c>) setCon.getRecords();
    } 
    
    public static void updateProjectHoursUsed(Sprint__c listSprint){
        AggregateResult[] results = [Select Sum(Actual_Hours_Used__c) actualHours, Sum(Sprint_Hours_Earned__c) earnedHours 
                                     from Sprint__c where Project__c = :listSprint.Project__c];
        
        Project__c updateProject = [Select Id, Hours_Used__c, Hours_Earned_From_Sprints__c from Project__c where Id = :listSprint.Project__c];
        updateProject.Hours_Used__c = (decimal) results[0].get('actualHours');
        updateProject.Hours_Earned_From_Sprints__c = (decimal) results[0].get('earnedHours');
        update updateProject;
        }
        
}