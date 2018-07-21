({
  doInit : function(component, event, helper) {
        var key = component.get("v.key");
        var map = component.get("v.mapBacklog");
        // set the values of map to the value attribute	
        component.set("v.listBacklogElements", map[key]);
	},

  onChange : function(component, event, helper) {
    levelEvent = $A.get("e.c:am_evtSetBacklogElement");
    levelEvent.fire();
	},

})