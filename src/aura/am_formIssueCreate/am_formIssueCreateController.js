({
  doInit: function(component, event, helper) {
  },

  saveIssueData : function(component, event, helper) {
   var action = component.get("c.createIssue");

    action.setParams({ aIssue : JSON.stringify(component.get("v.issue")),
                       aItemId : component.get("v.item"),
                       aIssueRelatedTo: component.get("v.IssueToRelateTo")});

    // populate issue with default values
    component.set("v.issue.Raised_By__c", component.get("v.userName"));
    component.set("v.issue.Project__c", component.get("v.project"));
    component.set("v.issue.Type__c", 'Site Issue');

    helper.executeUpdateCallback(action, component, "saveIssue");

    $A.enqueueAction(action);
  },

  setItem : function(component, event, helper) {
    // Set the item
    component.set("v.item", event.getParam("selectedItem"));

    // show the input form if not displayed
    if (!component.get("v.showIssueInput")) {
      component.set("v.showIssueInput", true);

      //  create issue checkbox
      $A.createComponent("c:am_cboxIssues", {"project": component.get("v.project")},
       function(newCheckbox, status, errorMessage){
         if (status === "SUCCESS") {
           //   buttons
           var divButtonComponent = component.find("existingIssuesHere");
           var divButtonBody = component.find("existingIssuesHere").get("v.body");
           divButtonBody.push(newCheckbox);
           divButtonComponent.set("v.body", divButtonBody);
           //Add text area and new button to the body array
         }
         else if (status === "INCOMPLETE") {
           console.log("No response from server or client is offline.")
           // Show offline error
         }
         else if (status === "ERROR") {
           console.log("Error: " + errorMessage);
           // Show error message 
         }
       }
     );
   }
   
   var issueEvent = $A.get("e.c:am_evtGetIssues");
   issueEvent.setParam( "projectSelected", component.get("v.project"));
   issueEvent.fire();
   
        
  },

  setIssueToRelateTo: function(component, event, helper) {
    // Set project from list box to parameter
    component.set("v.IssueToRelateTo", event.getParam("issuesSelected"));
  },

  setProject: function(component, event, helper) {
    //  save component data
//    helper.saveItems(component);
    
    // Set project from list box
    component.set("v.project", event.getParam("projectSelected"));
    
    // show the input form
    component.set("v.showIssueInput", false);
    
    // fill picklists
    helper.getItems(component, helper, "Project"); 
  }
		
})