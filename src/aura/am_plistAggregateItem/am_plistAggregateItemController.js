({
  doInit: function(component, event, helper) {
  },
   
  setProject: function(component, event, helper) {
    component.set("v.project", event.getParam("projectSelected"));
  },

  getAggregateItemData: function(component, event, helper) {
    component.set("v.project", event.getParam("projectSelected"));
    component.set("v.level", event.getParam("levelSelected"));
    component.set("v.sprint", event.getParam("sprintSelected"));
    helper.getAggregateItemData(component, event, helper);
  },
  
  setAggregateItem: function(component, event, helper) {
    //  broadcast result
    var itemEvent = $A.get("e.c:am_evtSetAggregateItem");
    itemEvent.setParam( "aggregateItemSelected", component.find("selectAggregateItem").get("v.value"));
    itemEvent.fire();
  }
})