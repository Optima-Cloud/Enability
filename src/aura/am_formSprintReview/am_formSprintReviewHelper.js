({
  getItemComponentData : function(component, event, helper, source) {
    helper.toggleSpinner(component, event);

    var action = component.get("c.getAggItemComponentAudits");

    if (source == "item"){
      action.setParams({ aItem : component.get("v.item"),
                         aSprint : component.get("v.sprint"),
                         aLevel : component.get("v.level") });
    } else {
      action.setParams({ aProject : component.get("v.project"),
                         aAggregateItem : component.get("v.aggregateItem"),
                         aSprint : component.get("v.sprint") });
    }
    
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS"){
          var aggItems = response.getReturnValue();
          var mapKeys = [];
          for (var key in aggItems) {
              mapKeys.push(key);
          }
          component.set("v.itemCollection", aggItems); 
          component.set("v.itemKeys", mapKeys); 
      } else {
          this.handleActionError(state, response.getError(), 'getItemComponentData');
          component.set("v.itemCollection", []); 
      }
      helper.toggleSpinner(component, event);
    });

    $A.enqueueAction(action);
  },

  executeUpdateCallback : function(action, component, callAction){
    // Create a callback that is executed after 
    // the server-side action returns
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid()){
        if (state === "SUCCESS") {
          // Alert the user with the value returned from the server
          if (callAction="saveIssue"){
            component.set("v.issue", {'sobjectType': 'Issue__c',
                          'Description__c': '', 'Title__c':'', 'Project__c': '' });
          }
        } else
          this.handleActionError(state, response.getError(), 'executeUpdateCallback');
      }
    });
  },

  createListIssue :function(component, event, helper) {
   var itemEvent = $A.get("e.c:am_evtGetIssue");
   itemEvent.setParam( "selectedItem", component.get("v.item"));
   itemEvent.fire(); 
  },

  showIssueForm :function(component){
      component.set("v.showIssueInputForm", true);
      this.createIssueTable(component);
  },

  showItemForm :function(component){
      component.set("v.showItemForm", true);
      component.set("v.showCreateIssueButton", true);
  },

  showAggItemForm :function(component){
    component.set("v.showItemAggregateForm", true);
  },

  removeIssueForm :function(component){
      component.set("v.showIssueInputForm", false);
      component.set("v.issueCreated", false);
  },

  removeItemForm :function(component){
      component.set("v.showItemForm", false);
      component.set("v.showCreateIssueButton", false);
  },

  removeAggItemForm :function(component){
    component.set("v.showItemAggregateForm", false);
  },
 
  showReviewIssueModal :function(component, event, helper) {    
    component.set("v.showReviewIssue", true);
    document.getElementById("reviewIssueModalWindow").style.display = "block";
  },
  
  hideReviewIssueModal :function(component,event, helper){
    component.set("v.showReviewIssue", false);
    document.getElementById("reviewIssueModalWindow").style.display = 'none';
  },

  showIssueModal :function(component, event, helper) {    
    document.getElementById("createIssueModal").style.display = "block";
    this.getIssues(component);
  },
  
  hideIssueModal :function(component,event, helper){
    document.getElementById("createIssueModal").style.display = 'none';
  },

  saveIssue : function(component, event, helper) {
    var action = component.get("c.createIssue");
    
    // populate issue with default values
    component.set("v.issue.Raised_By__c", component.get("v.userName"));
    component.set("v.issue.Project__c", component.get("v.project"));
    component.set("v.issue.Type__c", 'Site Issue');

    // JSON work around for bug in apex parameter passing
    action.setParams({ aIssue : JSON.stringify(component.get("v.issue")),
                       aItemId : component.get("v.itemID"),
                       aIssueRelatedTo: component.get("v.IssueToRelateTo")});

    helper.executeUpdateCallback(action, component, "saveIssue");

    $A.enqueueAction(action);
    
//    this.createListIssue(component);
    
    this.resetIssue(component);
  },
  
  saveItems : function(component, event, helper) {
//    if (component.get("v.componentDataToUpdate") == true) {
      component.set("v.componentDataToUpdate", false);
      this.saveAuditData(component, event, helper);
      this.saveItemData(component, event, helper);
//    } 
  },
  
  saveAuditData : function(component, event, helper) {
    var action = component.get("c.saveItemComponentAudits");

    var mapAggItems = component.get("v.itemCollection");
    var listAggItems = [];
    var mapKeys = component.get("v.itemKeys");
    for (var key in component.get("v.itemCollection")) {
      for (var idx = 0; idx < mapAggItems[key].audits.length; idx++) {
        listAggItems.push(mapAggItems[key].audits[idx]);
      }
    }
    action.setParams({ aSelectedItemComponentUseAudits : listAggItems });
    this.executeUpdateCallback(action, component, "");

    $A.enqueueAction(action);
  },
  
  saveItemData : function(component, event, helper) {
    var action = component.get("c.saveItemData");

    var mapAggItems = component.get("v.itemCollection");
    var listItems = [];
    var mapKeys = component.get("v.itemKeys");
    for (var key in mapAggItems) {
      listItems.push(mapAggItems[key].item);
      
    }
    action.setParams({ aSelectedItems : listItems });
    this.executeUpdateCallback(action, component, "");

    $A.enqueueAction(action);
  },
  
  
  resetIssue: function (component) {
    //  reset issue selection
    var issueEvent = $A.get("e.c:am_evtResetIssue");
    issueEvent.fire();
    component.set("v.issue.Title__c", "");
  },
  
  toggleSpinner: function (component, event) {
    var spinner = component.find("loadSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },
  
  getItemIssues : function(component, event, helper) {
    //  get id
    var itemId;
    var mapAggItems = component.get("v.itemCollection");
    for (var key in mapAggItems) {
      if (key == component.get("v.item")){
        itemId = mapAggItems[key].itemID; 
        break;
      }
    } 
    var issueEvent = $A.get("e.c:am_evtSetItemIssue");
    issueEvent.setParam( "selectedItem", itemId);
    issueEvent.fire();
  },

  getIssues : function(component, helper) {
    var issueEvent = $A.get("e.c:am_evtGetIssues");
    issueEvent.setParam( "projectSelected", component.get("v.project"));
    issueEvent.fire();
  },

  getLevels : function(component, helper) {
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetLevels");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.fire();
  }, 
  
  getSprints : function(component, helper) { 
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetSprints"); 
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.fire();
  },
  
  getItems : function(component, helper, source) {
    component.set("v.componentDataToUpdate", true);
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetItems");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.setParam( "sprintSelected", component.get("v.sprint"));
    levelEvent.setParam( "levelSelected", component.get("v.level"));
    levelEvent.setParam( "aggregateItemSelected", component.get("v.aggregateItem"));
    levelEvent.setParam( "requestSource", source);
    levelEvent.fire();
  },
  
  getAggregateItems : function(component, helper, source) {
    component.set("v.componentDataToUpdate", true);
    //  trigger event to fill item list
    var levelEvent = $A.get("e.c:am_evtGetAggregateItems");
    levelEvent.setParam( "projectSelected", component.get("v.project"));
    levelEvent.setParam( "levelSelected", component.get("v.level"));
    levelEvent.setParam( "sprintSelected", component.get("v.sprint"));
    levelEvent.setParam( "requestSource", source);
    levelEvent.fire(); 
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
})