({
  doInit: function(component, event, helper) {
    // Load sprints from Salesforce and fill out select list
    // Setup the apex action to call
    var action = component.get("c.getIssues");
    action.setParams({ aProject : component.get("v.project") });

    //  setup the call back function and fill the select box
    helper.fillCheckbox(action, component);
  },
  

  getIssuesData: function(component, event, helper) {
    // Setup the apex action to call
    var action = component.get("c.getIssues");
    action.setParams({ aProject : event.getParam("projectSelected") });

    //  setup the call back function and fill the select box
    helper.fillCheckbox(action, component);
  },

  onChange: function(cmp, evt) {
    // if item is checked add to selectedIssues array
    var inputElements = document.getElementsByClassName('issueCheckbox');
    var selectedIssues = []; 
    for(var i=0; i < inputElements.length; i++){
      if(inputElements[i].checked){
           selectedIssues.push(inputElements[i].value);       
      }    
    }
    var issueEvent = $A.get("e.c:am_evtSetIssue");
    issueEvent.setParam( "issuesSelected", selectedIssues);
    issueEvent.fire();
		
	},

  resetIssuesData: function(cmp, evt) {
    // if item is checked add to selectedIssues array
    var inputElements = document.getElementsByClassName('issueCheckbox');
    var selectedIssues = []; 
    for(var i=0; i < inputElements.length; i++){
      inputElements[i].checked = "";
    }

    var issueEvent = $A.get("e.c:am_evtSetIssue");
    issueEvent.setParam( "issuesSelected", selectedIssues);
    issueEvent.fire();
		
	},

})