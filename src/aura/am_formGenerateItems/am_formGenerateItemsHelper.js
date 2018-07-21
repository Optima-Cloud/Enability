({
  getProjectData : function(component, event, helper) {
    helper.toggleSpinner(component, event);

    var action = component.get("c.getProjectDetails");

    action.setParams({ aProject : component.get("v.project.Id")});
    
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS"){
        var project = response.getReturnValue();
        var levels = [];
 //       var itemMap = {};
        var itemTemp = {};
        component.set("v.showLevelItemQuantities", "true");
        component.set("v.project", {'sobjectType': 'Project__c',
                  'Levels__c': project.Levels__c, 'Basements__c': project.Basements__c });

//    var mapVar = component.get("v.itemCollection");
var mapVar = {};
        for (var i=0; i <= project.Levels__c; i++){
//          itemTemp = new Object();
//          itemTemp = {};
//          itemTemp.Level__c = i;
//          itemTemp.Aggregate_Item__c = 'test';
          var itemTemp = 'hello'+i;
//          mapVar[i] = [];
          mapVar[i] = itemTemp;
//          mapVar[i].splice(-1);
          levels.push(i); 
/*          levels.push(i); 
          itemMap[i] = i;
          itemMap[i].push(itemTemp);
          itemMap[i].splice(-1);
*/        }

        component.set("v.itemKeys", levels); 
        component.set("v.itemCollection", mapVar); 
//console.log(mapVar);
//console.log(component.get("v.itemCollection[5]"));

      } else {
          this.handleActionError(state, response.getError(), 'getProjectData');
      }
      helper.toggleSpinner(component, event);
    });

    $A.enqueueAction(action);
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
  
  toggleSpinner: function (component, event) {
    var spinner = component.find("loadSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },
  
})