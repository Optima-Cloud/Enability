({
  doInit: function(component, event, helper) {
    // Load projects from Salesforce and fill out select list and get user name
  
    // Setup the apex action to call
    var action = component.get("c.getStaff");

    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component, "Staff");
  },
    
    onSelect: function(cmp, evt) {
      var newEvent = $A.get("e.c:am_evtSetStaff");
      newEvent.setParam( "selectStaff", cmp.find("selectStaff").get("v.value"));
      newEvent.fire(); 
    },
  })