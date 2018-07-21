({
    setStaffActivityData : function(component, event, helper) {
      component.set("v.activitiesEntered", event.getParam("selectStaffActivity"));
      var act = component.get("v.activitiesEntered");
      var hours = 0;
      for (var i = 0; i < act.length; i++) { 
        hours += act[i].Time_Worked__c;
      }
      component.set("v.hoursTotal", hours);
    },

})