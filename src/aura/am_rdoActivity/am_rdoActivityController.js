({

  getActivityData : function(cmp, event, helper) {
    // Load items from Salesforce and fill out select list
    var item = event.getParam("selectedItem");
    var sprint = event.getParam("selectedSprint");
    // Setup the apex action to call
    var action = cmp.get("c.getActivities");
    action.setParams({ aItem : item, aSprint : sprint });

    //  setup the call back function and fill the radio buttons
    helper.fillRadio(action, cmp);
    var act = cmp.get("v.activities");
  },

    setSprint: function(cmp, event, helper) {
        cmp.set("v.sprint", event.getParam("sprintSelected"));
        //  clear radio button
        helper.resetActivity(cmp);        
    },

    resetActivity: function(cmp, event, helper) {
        //  clear radio button
        helper.resetActivity(cmp);        
    },


    onRadio: function(cmp, evt) {
      var newEvent = $A.get("e.c:am_evtSetActivity");
      newEvent.setParam( "activitySelected", document.querySelector('input[name="options"]:checked').value);
      for(var act in cmp.get("v.activities")){
        if (act.Id == document.querySelector('input[name="options"]:checked').value){
          newEvent.setParam( "activitySelected", act);
        }
      }
      newEvent.fire(); 
    },
})