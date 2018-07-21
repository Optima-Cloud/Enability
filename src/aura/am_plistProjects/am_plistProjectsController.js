({
  doInit: function(component, event, helper) {
    // Load projects from Salesforce and fill out select list and get user name
  
    // Setup the apex action to call
    var action = component.get("c.getProjects");

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Project");
    
  },
  
  setProject: function(component, event, helper) {
    var projectparam = component.find("selectProject").get("v.value");
    var projectEvent = $A.get("e.c:am_evtSetProject");
    projectEvent.setParam( "projectSelected", projectparam);
    projectEvent.fire();
  },
})