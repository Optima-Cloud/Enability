({
  doInit: function(component, event, helper) {
    var action = component.get("c.getUserName");
    action.setCallback(this, function(response){
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.userName", response.getReturnValue());
      }
    })
    $A.enqueueAction(action);
  },

  reviewIssueModal : function(component, event, helper) {
    //  get id of item
    component.set("v.item", event.getSource().get("v.name"));
    helper.showReviewIssueModal(component, event, helper);
    helper.getItemIssues(component, event, helper);

  },
  
  cmdHandler : function(component, event, helper) {    
    if (event.getParam("commandSelected") == "NewIssue"){
      component.set("v.item", event.getParam("selectedCriteria"));
      helper.showIssueModal(component, event, helper);
    } else if (event.getParam("commandSelected") == "ReviewIssue"){
      component.set("v.item", event.getParam("selectedCriteria"));
      helper.showReviewIssueModal(component, event, helper);
      helper.getItemIssues(component, event, helper);
    }
  },
  
  saveIssueData : function(component, event, helper) {
      helper.saveIssue(component, event, helper);
      helper.removeIssueForm(component)
      helper.showItemForm(component);
  },

  saveIssueModalData : function(component, event, helper) {
    event.preventDefault();
    helper.hideIssueModal(component, event, helper);

    var mapAggItems = component.get("v.itemCollection");

    for (var key in mapAggItems) {
      if (component.get("v.item") == key){
         component.set("v.itemID", mapAggItems[key].itemID);
      }
    }
    helper.saveIssue(component, event, helper);
  },

  setStage : function(component, event, helper) {
    var mapAggItems = component.get("v.itemCollection");
    var listAggItems = [];
    var mapKeys = component.get("v.itemKeys");
    for (var key in mapAggItems) {
      if (key == event.getParam("item")) {
        mapAggItems[key].item.Build_Stage__c = event.getParam("buildStage");
      }
    }
    component.set("v.itemCollection", mapAggItems);
  },


  cancelReviewIssueModal : function(component, event, helper) {
    event.preventDefault();
    helper.hideReviewIssueModal(component, event, helper);
//    helper.resetIssue(component);
  }, 

  saveReviewIssueModalData : function(component, event, helper) {
   event.preventDefault();
   helper.hideReviewIssueModal(component, event, helper);
   
   var itemEvent = $A.get("e.c:am_evtSaveIssue");
   itemEvent.fire(); 
  },
  
  cancelIssueModal : function(component, event, helper) {
    event.preventDefault();
    helper.hideIssueModal(component, event, helper);
    helper.resetIssue(component);
  }, 

  cancelIssue : function(component, event, helper) {
    helper.removeIssueForm(component)
    helper.showItemForm(component);
    helper.resetIssue(component);
  },

  setIssueToRelateTo: function(component, event, helper) {
    // Set project from list box to parameter
    component.set("v.IssueToRelateTo", event.getParam("issuesSelected"));
  },
  
  setProject: function(component, event, helper) {
    //  save component data
    helper.saveItems(component);
    
    // Set project from list box
    component.set("v.project", event.getParam("projectSelected"));

    // fill picklists
    helper.getLevels(component, helper);
    helper.getSprints(component, helper);
  },
  
  setLevel: function(component, event, helper) {
    //  save component data
    helper.saveItems(component);
    
    // Set level from list box
    component.set("v.level", event.getParam("levelSelected"));
    component.set("v.sprint", null);

    // fill picklists
    helper.getItems(component, helper, "Level"); 
    helper.getAggregateItems(component, helper, "Level");
    helper.getSprints(component, helper);
  },

  setSprint: function(component, event, helper) {
    //  save component data
    helper.saveItems(component);

    // Set sprint from list box
    component.set("v.sprint", event.getParam("sprintSelected"));
    component.set("v.level", null);

    // fill picklists
    helper.getAggregateItems(component, helper, "Sprint");
    helper.getItems(component, helper, "Sprint");
    helper.getLevels(component, helper);
   },
  
  setItem: function(component, event, helper) {
    //  save component data
    helper.saveItems(component, event, helper); 

    // Show the correct form element
    helper.showAggItemForm(component);
    helper.removeItemForm(component);

    component.set("v.item", event.getParam("selectedItem"));
    helper.getItemComponentData(component, event, helper, "item");
  },
  
  setAggregateItem: function(component, event, helper) {
    //  save component data
    helper.saveItems(component, event, helper);
    component.set("v.aggregateItem", event.getParam("aggregateItemSelected"));
    //  fill item list box
    helper.getItems(component, helper, "AggregateItem");

    // Show the correct form element
    helper.showAggItemForm(component);
    helper.removeItemForm(component);

    helper.getItemComponentData(component, event, helper, "aggregateItem");
  }
  
})