({
  executeUpdateCallback : function(action, component, callAction){
    // Create a callback that is executed after 
    // the server-side action returns
    action.setCallback(this, function(response) { 
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // Alert the user with the value returned from the server
        if (callAction="saveIssue"){
          this.removeIssueForm(component);
          component.set("v.issue", {'sobjectType': 'Issue__c',
                        'Description__c': '', 'Project__c': '' });
        }
      }
      else if (component.isValid() && state === "INCOMPLETE") {
        console.log("No response from server or client is offline.")
      }
      else if (component.isValid() && state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) 
            console.log("Error message: " + errors[0].message);
        } 
        else 
          console.log("Unknown error");
      }
    });
  }, 
  
  removeIssueForm :function(component){
      component.set("v.showIssueInput", false);
  },
  
  getItems : function(component, helper, source) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetItems");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.setParam( "requestSource", source);
    levelEvent.fire();    
  },
		
})