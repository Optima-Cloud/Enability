({
  fillCheckbox : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        // update checkbox list
        component.set("v.issues", response.getReturnValue()); 
      } else
        this.handleActionError(state, response.getError(), 'am_cboxIssue.fillCheckbox');
    });

    //  call the apex action
    $A.enqueueAction(action);
    
  },
  
  
})