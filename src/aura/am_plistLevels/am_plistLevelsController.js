({
  doInit: function(component, event, helper) {
    //  set disable at initiation
    component.find("selectLevel").set('v.disabled', true);                   
  },

  getLevelsData: function(component, event, helper) {
    // Load levels from Salesforce and fill out select list
    var project = event.getParam("projectSelected");
    component.set("v.project", project);
    // Setup the apex action to call
    var action = component.get("c.getLevels");
    action.setParams({ aProject : project });

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Sprint");
  },

  setLevel: function(component, event, helper) {
    //  trigger event to fill item list
    helper.broadcastLevel(component);
  },

})