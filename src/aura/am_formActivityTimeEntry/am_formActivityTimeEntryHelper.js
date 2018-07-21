({
   addActivity: function(cmp) {
      //  prevent page from submitting    
      var tempStaffAct = [];
      var act = cmp.get("v.staffActivities");
      // get date in correct format
      var  workDate = new Date(cmp.find("selectDate").get("v.value"));
    
      act.push({'sobjectType':'Staff_Activity__c',
                         Date__c: workDate,
                         Staff__c: cmp.get("v.staff"),
                         Activity__c: cmp.get("v.activityId"),
                         Description__c: cmp.get("v.activityName"),
                         Time_Worked__c: cmp.get("v.activityHours")});

      cmp.set('v.staffActivities', act);
 
      //  fire event with activity updated
      var newEvent = $A.get("e.c:am_evtSetStaffActivity");
      newEvent.setParam("selectStaffActivity", cmp.get('v.staffActivities'));
      newEvent.fire();      
    },
    
    resetSelection: function(cmp) {
      var newEvent = $A.get("e.c:am_evtResetActivity");
      newEvent.fire(); 
      cmp.set("v.selectedActivity", false);  
    },

    resetActivity: function(cmp) {
      //  fire event with activity updated
      var newEvent = $A.get("e.c:am_evtSetStaffActivity");
      newEvent.setParam("selectStaffActivity", []);
      newEvent.fire();    
      cmp.set("v.selectedActivity", false);  
      cmp.set("v.staffActivities", []);
      cmp.set("v.activityId", "");      
      cmp.set("v.activityName", "");
      this.resetSelection(cmp);    
    },

    getActivityData : function(action, component){
        action.setCallback(this,function(response){
        component.set("v.activityName", response.getReturnValue().Description__c);});
        $A.enqueueAction(action);
    }, 
    
  getSprints : function(component, event, helper) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetSprints"); 
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.fire();
  },
    
  getItems : function(component, event, helper, source) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetItems");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.setParam( "sprintSelected", component.get("v.sprint"));
    levelEvent.setParam( "requestSource", source);
    levelEvent.fire();  
  },
  
  getActivities : function(component, event, helper) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetActivities");
    levelEvent.setParam( "selectedItem", component.get("v.item"));
    levelEvent.setParam( "selectedSprint", component.get("v.sprint"));
    levelEvent.fire();
  },
  
  
    
})