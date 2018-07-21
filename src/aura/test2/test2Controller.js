({
	doInit : function(component, event, helper) {
console.log('test2 doInit');    
    var historyEvent = component.getEvent("evt_SetBillingAccount");
console.log('test2 doInit a');    
    historyEvent.fire();
console.log('test2 doInit b');    
},

	setStage : function(component, event, helper) {
console.log('test2 setStage');    
		
	}
})