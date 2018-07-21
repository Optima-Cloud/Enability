({
  actionCallback : function(action, component, callAction){
    // Create a callback that is executed after 
    // the server-side action returns
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // Alert the user with the value returned from the server
        if (callAction == "backlog") {
          if (response.getReturnValue().length != 0){
            var tempAggBacklogs = response.getReturnValue();
            var tempBacklogs = [];
            var mapKeys = [];
            var aggBacklogs = {};
            
            for (var key in tempAggBacklogs) {
              if (key != '' > 0 && key != 'null'){ 
                mapKeys.push(key);
                aggBacklogs[key] = tempAggBacklogs[key]; 
                aggBacklogs[key].push(tempAggBacklogs[key]);
                aggBacklogs[key].splice(-1);
              } else {
                tempBacklogs.push(tempAggBacklogs[key]);
                tempBacklogs = tempAggBacklogs[key];
              } 
            }
            component.set("v.backlogQueue", tempBacklogs);
            component.set("v.backlogQueueElements", aggBacklogs); 
            component.set("v.backlogQueueKeys", mapKeys); 
            component.set("v.componentAggDataToUpdate", true);
          } else {
          } 
        } else if (callAction == "addToSprint")
          ;
      } else
        this.executeUpdateCallback(action, component, ""); 
        
      this.toggleSpinner(component, event);
    });
  },

  createAddToSprintButton: function(component, event, helper) {
      //  update the screen with the item components
     //  add the save button if it has not been created   
     if(component.get("v.showAddToSprint") == false){
       component.set("v.showAddToSprint", true);
       $A.createComponent("lightning:button", {"aura:id": "addToSprint",
                             "label": "Add To Sprint",
                             "variant": "brand",
                             "class": "slds-button slds-button_brand",
                             "onclick": component.getReference("c.showSprintModal")},
         function(newButton, status, errorMessage){
           //Add the new button to the body array
           if (status === "SUCCESS") {
             var divComponent = component.find("addToSprintButtonHere");
             var divComponent2 = component.find("addToSprintButtonBottomHere");
             divComponent.set("v.body", []);
             divComponent2.set("v.body", []);
             var body = component.get("v.body");
             body.push(newButton);
             divComponent.set("v.body", body);
             divComponent2.set("v.body", body);
           } else
             this.executeUpdateCallback(action, component, "");
        });
      }       
  },  

  showModal : function(component, event, helper) {    
    component.set("v.showAddToSprintForm", true);
    document.getElementById("addToSprint").style.display = 'block';
  },
    
  hideModal : function(component,event, helper){
    document.getElementById("addToSprint").style.display = 'none';
     // reset all items
    var inputElements = document.getElementsByClassName('itemCheckbox');
    for(var i=0; i < inputElements.length; i++){
      inputElements[i].checked = false;
    } 
    component.set("v.selectedItems", []);  
  },
  
  getLevels : function(component, helper) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetLevels");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.fire();
  },

  setSelectedItems: function(component, event) {
    // if item is checked add to selectedIssues array
    var inputElements = document.getElementsByClassName('itemCheckbox');
    var selectedItems = []; 
    for(var i=0; i < inputElements.length; i++){
      if(inputElements[i].checked){
           selectedItems.push(inputElements[i].value);       
      } 
       component.set("v.selectedItems", selectedItems);  
    }
  },
    
  toggleSpinner: function (component, event) {
    var spinner = component.find("loadSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },

  handleActionError : function(aState, aError, aSource){
    // Handle error after access to database
    if (aState === "INCOMPLETE") {
      console.log(aSource + " No response from server or client is offline.")
    } else if (aState === "ERROR") {
      if (aError) 
        if (aError[0] && aError[0].message) 
          console.log(aSource + " Error message: " + aError[0].message);
    } else 
      console.log("Unknown error");
  },

})