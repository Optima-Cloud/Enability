({
  doInit: function(component, event, helper) {
    helper.getItemsDataHelper(component, event, helper);
  },
   
  getItemsData : function(component, event, helper) {
    //  get values from event
    component.set("v.project", event.getParam("projectSelected"));
    component.set("v.level", event.getParam("levelSelected"));
    component.set("v.sprint", event.getParam("sprintSelected"));
    component.set("v.aggregateItem", event.getParam("aggregateItemSelected"));
    component.set("v.requestSource", event.getParam("requestSource"));

    // Load items from Salesforce and fill out select list
    helper.getItemsDataHelper(component, event, helper);
  },
/* refactored 23/6/17
  getProjectItemsData : function(component, event, helper) {
    //  get values from event
    component.set("v.project", event.getParam("projectSelected"));
    component.set("v.requestSource", event.getParam("requestSource"));
    component.set("v.level", event.getParam("levelSelected"));

    // Load items from Salesforce and fill out select list
    helper.getItemsDataHelper(component, event, helper);
  },
*/
  setItem: function(component, event, helper) {
    var itemEvent = $A.get("e.c:am_evtSetItem");
    itemEvent.setParam( "selectedItem", component.find("selectItem").get("v.value"));
    itemEvent.fire();
  },

})