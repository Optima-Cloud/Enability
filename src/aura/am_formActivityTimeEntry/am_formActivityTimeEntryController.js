({
    doInit : function(cmp, helper) {
      var today = new Date();
      cmp.set("v.workDate", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
//      cmp.set("v.activityName", "Lunch break");
//      cmp.set("v.activityHours", "0.5");
//      helper.addActivity(cmp);
    },
  
    clickAddTime : function(cmp, event, helper) {
      //  prevent page from submitting   
      event.preventDefault();
      if (cmp.get("v.selectedActivity") == true && cmp.get("v.selectedStaff") == true ){
        cmp.set("v.activityHours", (parseInt(cmp.find("selectHours").get("v.value")) * 60 + parseInt(cmp.find("selectMinutes").get("v.value")))/60);
        helper.addActivity(cmp );
      }
      helper.resetSelection(cmp);
    },

    clickSaveTime : function(cmp, event, helper) {
      //  prevent page from submitting    
      event.preventDefault();
      // Create the action
      var action = cmp.get("c.updateStaffActivities");
      action.setParams({ aStaffActivities : cmp.get("v.staffActivities") });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (cmp.isValid() && state === "SUCCESS") {
          // Alert the user with the value returned from the server
        }
        else if (cmp.isValid() && state === "INCOMPLETE") {
          console.log("No response from server or client is offline.")
        }
        else if (cmp.isValid() && state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) 
              console.log("Error message: " + errors[0].message);
          } 
          else 
            console.log("Unknown error");
        }
      });

      $A.enqueueAction(action);
      helper.resetActivity(cmp);
    },
    
    setActivity : function(cmp, event, helper) {
      // set activity detail to the one selected
      
      cmp.set("v.activityId", event.getParam("activitySelected"));
      cmp.set("v.selectedActivity", true);

      //  get selected activity details
      var action = cmp.get("c.getActivity");
      action.setParams({ aActivityId : cmp.get("v.activityId") });
      //  setup the call back function and fill the radio buttons
      helper.getActivityData(action, cmp);      
    },
    
    setStaff : function(cmp, event, helper) {
      cmp.set("v.staff", event.getParam("selectStaff"));
      cmp.set("v.selectedStaff", true);
      helper.resetActivity(cmp);
    },

    clickResetAll: function(cmp, evt, helper) {
      evt.preventDefault();
      helper.resetActivity(cmp); 
    },
    
  setProject: function(component, event, helper) {
    // Set project from list box
    component.set("v.project", event.getParam("projectSelected"));


    // fill picklists
    helper.getSprints(component, event, helper);
  },
    
  setSprint: function(component, event, helper) {
    // Set sprint from list box
    component.set("v.sprint", event.getParam("sprintSelected"));

    // fill picklists
    helper.getItems(component, event, helper, "Sprint");
  },
    
  setItem: function(component, event, helper) {
  
    component.set("v.item", event.getParam("selectedItem"));
    helper.getActivities(component, event, helper);
  },
  
})