({
  doInit: function(component, event, helper) {
    //  set disable at initiation
    component.find("selectSprint").set('v.disabled', true);                   
  },

  getSprintsData: function(component, event, helper) {
    // Load sprints from Salesforce and fill out select list
    var project = event.getParam("projectSelected");
    // Setup the apex action to call
    var action = component.get("c.getSprints");
    action.setParams({ aProject : project });

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Sprint");
  },
  
  setSprint: function(component, helper) {
    //  trigger event to fill item list
    var sprintEvent = $A.get("e.c:am_evtSetSprint");
    sprintEvent.setParam( "sprintSelected", component.find("selectSprint").get("v.value"));
    sprintEvent.fire();
  },
  
})