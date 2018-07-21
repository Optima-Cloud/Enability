({
  doInit: function(component, event, helper) {
    // Load sprints from Salesforce and fill out select list
    // Setup the apex action to call
    var action = component.get("c.getIssues");
    action.setParams({ aProject : component.get("v.project") });

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Issue");
  },
  
  getIssueData: function(component, event, helper) {
    // Load sprints from Salesforce and fill out select list
    // Setup the apex action to call
    var action = component.get("c.getIssues");
    action.setParams({ aProject : event.getParam("projectSelected") });

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Issue");
  },
  
  setIssue: function(component, helper) {
    //  trigger event to fill issue list
    var issueEvent = $A.get("e.c:am_evtSetIssue");
    issueEvent.setParam( "issueSelected", component.find("selectIssue").get("v.value"));
    issueEvent.fire();
  },
})