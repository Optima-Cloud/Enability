({
  doInit : function(component, event, helper) {
    var key = component.get("v.key");
    var map = component.get("v.mapItems");
    // set the values of map to the value attribute	
    component.set("v.auditItems", map[key].audits);
    component.set("v.issues", map[key].issues);
    if (map[key].issues.length > 0)
      component.set("v.issuesExist", true);    
    component.set("v.buildStages", map[key].buildStages);
    component.set("v.buildStage", map[key].item.Build_Stage__c);
    component.set("v.item", map[key]);
  },

  allFinished : function(component, event, helper) {
    var allCheckboxValue = event.getSource().get("v.checked");
    var auditList = component.get("v.auditItems");    
    var checkboxes = component.find("cboxFinished");
    
    for (var i = 0; i < auditList.length; i++){
     // set all checkboxes to match group checkbox
     checkboxes[i].set("v.checked", allCheckboxValue);

      //  if group checkbox checked set all finished
      if (allCheckboxValue){
        auditList[i].Number_Finished__c = auditList[i].Quantity__c;
        auditList[i].Number_Started__c = 0;
      }
    }    
    component.set("v.auditItems", auditList);
  },
  
  oneFinished : function(component, event, helper) {
    var oneCheckboxValue = event.getSource().get("v.checked");
    var checkboxName = event.currentTarget.name;
    var auditList = component.get("v.auditItems");    
    for (var i = 0; i < auditList.length; i++){
      //  if group checkbox checked set all finished
      if (auditList[i].Id == checkboxName && oneCheckboxValue){
        auditList[i].Number_Finished__c = auditList[i].Quantity__c;
        auditList[i].Number_Started__c = 0;
        component.set("v.auditItems", auditList);
        break;
      }
    }    
  },
  
  quantityChanged : function(component, event, helper) {
    var item = event.getSource();    
    var checkboxes = component.find("cboxFinished");

    for (var i = 0; i < checkboxes.length; i++){
      // set all checkboxes to match group checkbox
      if (checkboxes[i].get("v.name") == item.get("v.name")){
        checkboxes[i].set("v.checked", "");
      }
    }  
    component.find("allFinished").set("v.checked", ""); 
  },
  
  
  newIssueModal : function(component, event, helper) {
    var issueEvent = $A.get("e.c:am_evtCmdSprintReview");
    issueEvent.setParam( "commandSelected", "NewIssue");
    issueEvent.setParam( "selectedCriteria", component.get("v.key"));
    issueEvent.fire();
  },

  reviewIssueModal : function(component, event, helper) {
    var issueEvent = $A.get("e.c:am_evtCmdSprintReview");
    issueEvent.setParam( "commandSelected", "ReviewIssue");
    issueEvent.setParam( "selectedCriteria", component.get("v.key"));
    issueEvent.fire();
  },

  setStage: function(component, event, helper) {
    // Set build stage in the backlog element
    var issueEvent = $A.get("e.c:am_evtSetBuildStage");
    issueEvent.setParam( "buildStage", event.getSource().get("v.value"));
    issueEvent.setParam( "item", component.get("v.item").itemTitle);
    issueEvent.fire();
  },
})