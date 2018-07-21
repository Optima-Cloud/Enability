({
  doInit: function(component, event, helper) {
  },
   
  setProject: function(component, event, helper) {
    // Set project from list box
    component.set("v.project", event.getParam("projectSelected"));

    // fill picklists
    helper.getLevels(component, helper);
  }, 
 
  setLevel: function(component, event, helper) {
    // Set level from list box
    component.set("v.level", event.getParam("levelSelected"));
    component.set("v.source", "level");
    helper.getItemsAndIssues(component, event, helper, "level");
  },

  setItem: function(component, event, helper) {
    if (component.get("v.notModal")){
    // Set item from list box
      component.set("v.showHeader", false);
      component.set("v.source", "level");
      component.set("v.item", event.getParam("selectedItem"));
      component.set("v.showSaveButton", false);
      component.set("v.showItemIssueForm", false);
    }

    component.set("v.item", event.getParam("selectedItem"));
    helper.getItemsAndIssues(component, event, helper, "item");
    component.set("v.showItemIssueForm", true);
    
  },
  
  setStage: function(component, event, helper) {
    // Set build stage in the backlog element
    var item = event.getSource();
    var updatedBuildStage = item.get("v.value");
    var updatedItemId = item.get("v.name");
    var allItems = component.get("v.itemsAndIssues");
    for(var i=0; i < allItems.length; i++){
      if(allItems[i].itemID == updatedItemId)
        allItems[i].buildStage = updatedBuildStage;
    }
  },
    
  saveIssues : function(component, event, helper) {
    // get all of the issues that have been marked as resolved
    var inputElements = document.getElementsByClassName('issueItemCheckbox');
    var items = component.get("v.itemsAndIssues");
    var resolvedIssueItems = [];
    for(var i=0; i < items.length; i++){
      for(var j=0; j < items[i].issue.length; j++){
        for(var k=0; k < inputElements.length; k++){
          if(inputElements[k].id == items[i].issue[j].Id){
            if(inputElements[k].checked){
              items[i].issue[j].Resolved__c = true;
              resolvedIssueItems.push(items[i].issue[j]);
            }
          }
        }
      }
    }

    
    //  update aura attribute
    component.set("v.itemIssues", resolvedIssueItems);

    //  save issues
    var action = component.get("c.saveIssueItems");
    action.setParams({ aIssueItems : component.get("v.itemIssues") });
    helper.executeUpdateCallback(action, component, "");

    $A.enqueueAction(action);

    //  save item build stage 
    var action = component.get("c.saveItems");
    var items = component.get("v.itemsAndIssues");
    JSON.stringify(component.get("v.itemsAndIssues"));
    
    var itemsList = [];
    for(var i=0; i < items.length; i++){
              itemsList.push(items[i]);
    }
    action.setParams({ aBacklogElements : JSON.stringify(component.get("v.itemsAndIssues")) });
    helper.executeUpdateCallback(action, component, "");

    $A.enqueueAction(action);

    //  reset issue list
    helper.getItemsAndIssues(component, event, helper);
  },
  
})