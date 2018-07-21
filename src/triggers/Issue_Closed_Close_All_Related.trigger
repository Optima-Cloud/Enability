trigger Issue_Closed_Close_All_Related on Issue__c (after update) {
    /*
    *  Written by:  David Strangward
    *  Date:  30/7/2016
    *  Modified by:
    *  Date Modified:
    *
    *  Description:  Calls generic trigger handler in the IssueItem class to manage the update
    *                of all issue items to closed if the status of the issue is closed.
    */
 
    if(Trigger.new[0].Status__c == 'Closed')
            IssueItemsController.triggerAction('StatusToClosed', trigger.new);
}