({
  setProject: function(component, event, helper) {
    //  save component data
//    helper.saveItems(component);
    
    // Set project from list box
    component.set("v.project", {'sobjectType': 'Project__c',
                  'Id': event.getParam("projectSelected") });
    // fill picklists
    helper.getProjectData(component, event, helper);
  },
})