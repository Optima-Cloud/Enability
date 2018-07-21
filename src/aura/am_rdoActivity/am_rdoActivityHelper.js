({
  fillRadio : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // update activities

	    response.getReturnValue().forEach(function (act) {
          if (act.Name != ''){
            component.set('v.activities', act); 
          }
        })
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
        else {
          console.log("Unknown error");
        }
      }
    });
    
    //  call the apex action
    $A.enqueueAction(action);    
  },
  
  resetActivity: function(cmp) {
    //  clear radio button
    cmp.set('v.activities', []);        
  },
  

})