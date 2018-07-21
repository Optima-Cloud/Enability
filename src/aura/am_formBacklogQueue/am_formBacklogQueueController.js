({
  doInit: function(component, event, helper) {
    helper.toggleSpinner(component, event);
  },
  
  getBacklogQueue: function(component, event, helper) {
    var action = component.get("c.getAggBacklogQueueData");
    action.setParams({"aProject": component.get("v.project"),
                      "aItem": component.get("v.item"),
                      "aSprint": "", 
                      "aLevel": component.get("v.level")});


    component.set("v.showAggBacklog", true);
    component.set("v.showBacklog", true);
    helper.toggleSpinner(component, event);
    helper.actionCallback(action, component, "backlog");
    helper.createAddToSprintButton(component);
 
    $A.enqueueAction(action);

  },  

  setProject: function(component, event, helper) {
    // Set project from list box
    component.set("v.project", event.getParam("projectSelected"));
    component.set("v.level", "");

    // fill picklists
    helper.getLevels(component, helper);
  },

  setLevel: function(component, event, helper) {
    // Set level from list box
    component.set("v.level", event.getParam("levelSelected"));
  },

  setSprint: function(component, event, helper) {
    // Set level from list box
    component.set("v.sprint", event.getParam("sprintSelected"));
  },

  onChange: function(component, event, helper) {
    helper.setSelectedItems(component, event);
  },

  setItemsSelected: function(component, event, helper) {
    helper.setSelectedItems(component, event);
   },
  
  addToSprint : function(component, event, helper) {
    if (!component.get("v.sprint"))   
      alert('Select a sprint first');
    else {
      //  use JSON to fix bug in apex passing, believed to be fixed in Summer17      
      var items = component.get("v.selectedItems");
      var action = component.get("c.addItemToSprint");
      action.setParams({"aSelectedItems": JSON.stringify(items),
                      "aSprint": component.get("v.sprint")});
      helper.toggleSpinner(component, event);
      helper.actionCallback(action, component, "addToSprint");
      helper.hideModal(component, event, helper);
      $A.enqueueAction(action); 
    }
  },

  showSprintModal : function(component, event, helper) {
    if (component.get("v.selectedItems").length == 0)   
      alert('Select an item first');
    else
      helper.showModal(component, event, helper);
      //  trigger event to fill item list
      var levelEvent = $A.get("e.c:am_evtGetSprints");
      levelEvent.setParam( "projectSelected", component.get("v.project"));
      levelEvent.fire();
      
  },
  
  cancelSprintModal : function(component, event, helper) {
    helper.hideModal(component, event, helper);
  },

})