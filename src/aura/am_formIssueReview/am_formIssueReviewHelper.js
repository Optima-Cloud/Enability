({
  createButtons: function(component, event, helper) {
    if (component.get("v.notModal") == true){
      //  update the screen with the item components
     //  add the save button if it has not been created   
     if(component.get("v.showSaveButton") == false){
       component.set("v.showSaveButton", true);

       $A.createComponents([["lightning:button", {"aura:id": "saveIssues",
                             "label": "Save Changes",
                             "class": "slds-button slds-button_brand",
                             "onclick": component.getReference("c.saveIssues")}]],
         function(newButton, status, errorMessage){
           //Add the new button to the body array
           if (status === "SUCCESS") {
             var body = component.get("v.body");
             body.push(newButton[0]);

             if(component.get("v.showHeader") == true && component.get("v.showSaveButton") == true){
               var divComponent = component.find("buttonsHere");
               divComponent.set("v.body", body);
             }
             if(component.get("v.showSaveButton") == true) {
               var divComponent2 = component.find("buttonsBottomHere");
               divComponent2.set("v.body", body);
             }
           }
           else {
             console.log("Error: " + errorMessage);
           }
        });
      }
    }           
  }, 
  
  getIssueItems: function(component, event, helper) {
    var action = component.get("c.getIssueItems");
    action.setParams({ aProject : component.get("v.project"),
                       aLevel : component.get("v.level"), 
                       aItem : null});

    helper.executeUpdateCallback(action, component, "getIssues");

    $A.enqueueAction(action);
  },

  getItemsAndIssues: function(component, event, helper, source) {
    var action = component.get("c.getItemsAndIssues");
    if (source == "level"){
      action.setParams({ aProject : component.get("v.project"),
                         aLevel : component.get("v.level"), 
                         aItem : null});
    } else if (source == "item"){
      action.setParams({ aItem : component.get("v.item")});
    }

    helper.executeUpdateCallback(action, component, "getItemsAndIssues");

    $A.enqueueAction(action);
  },

  executeUpdateCallback : function(action, component, callAction){
    this.toggleSpinner(component, event);

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // Alert the user with the value returned from the server
        if (callAction=="getIssues"){
          if (response.getReturnValue().length > 0){
            component.set("v.itemIssues", response.getReturnValue()); 
            this.createButtons(component);
          }
        } else if (callAction=="getItemsAndIssues"){
           component.set("v.itemsAndIssues", response.getReturnValue()); 
           if (response.getReturnValue().length > 0)
             this.createButtons(component);
        } 
      } else if (component.isValid() && state === "INCOMPLETE") {
        console.log("No response from server or client is offline.")
      } else if (component.isValid() && state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) 
            console.log("Error message: " + errors[0].message);
        } 
        else 
          console.log("Unknown error");
      }
      this.toggleSpinner(component, event);
    });
  },

  getLevels : function(component, helper) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetLevels");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.fire();
  }, 
  
  toggleSpinner: function (component, event) {
    var spinner = component.find("loadSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },
  
   
})