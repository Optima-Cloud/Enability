({
  fillSelectOption : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // update select
        var cmp = component.find("selectSprint");        
        cmp.set('v.disabled', false);

        cmp.set('v.body', []); // clear all options
        this.addSelectOption( response.getReturnValue(), cmp, component);
      }
      else if (component.isValid() && state === "INCOMPLETE") {
        console.log("No response from server or client is offline.")
      }
      else if (component.isValid() && state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) 
            console.log("Error message: " + errors[0].message);
        } 
        else {
          console.log("Unknown error");
        }
      }
    });
    
    //  call the apex action
    $A.enqueueAction(action);
    
  },

  addSelectOption : function(opts, component, parentComponent) {
      // for each option an an option to the select box
      var body = component.get('v.body');
      var emptyList = false;
      var selectedState = false;
      var selectedId;
      var sprint;
      if (opts.length <= 0) {
        opts = [{ "tag": "option", Name: "No Item", selected: "true" }];
        emptyList = true;
      }
	  opts.forEach(function (opt) {
        if (opt.Name != ''){
          //  get sprint for current period
          var todayDate = new Date().toJSON().slice(0,10);
/*  23/6/17 removed as causes loop when attempt to set level
          if (opt.Date_Start__c <= todayDate && opt.Date_End__c >= todayDate){
            selectedState = true;
            selectedId = opt.Id;
            sprint = opt.Name;
          }
*/
          var sprintName = opt.Date_End__c + " - " + opt.Name;
          $A.createComponent( 'aura:html', {tag: 'option', HTMLAttributes: {value: opt.Id, text: sprintName, selected: selectedState}}, 
            function (newOption) {
              //Add options to the body
              if (component.isValid()) { 
                body.push(newOption);
                component.set('v.body', body);             
              }
              else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
              }
              else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
              }
            } 
          )
        }
      })
      if (emptyList == false) {
          this.addSelectFirstLine("Pick a Sprint", component);
      } 
      
      if (selectedState == true){
        //  fill the item box for the default
        parentComponent.find("selectSprint").set("v.value", selectedId);
        parentComponent.find("selectSprint").set("v.text", sprint);
        this.broadcastSprint(parentComponent);
      }
	},
	
  addSelectFirstLine : function(firstLineText, component) {
      // add first item in list to prompt to pick an item
      
      $A.createComponent( 'aura:html', {tag: 'option', HTMLAttributes: {value: firstLineText,text: firstLineText}}, 
        function (newOption) {
          //Add options to the body
          if (component.isValid()) { 
            var body = component.get('v.body');
            body.unshift(newOption);
            component.set('v.body', body);             
          }
          else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
          }
          else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
          }
        } 
      )
	},

  broadcastSprint : function(component){
    var sprintEvent = $A.get("e.c:am_evtSetSprint");
    sprintEvent.setParam( "requestSource", "Sprint");
    sprintEvent.setParam( "sprintSelected", component.find("selectSprint").get("v.value"));
    sprintEvent.fire();
  },

})