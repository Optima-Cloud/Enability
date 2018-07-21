({
  broadcastLevel : function(component, helper) {
    //  trigger event to fill item list
    levelEvent = $A.get("e.c:am_evtSetLevel");
    levelEvent.setParam( "levelSelected", component.find("selectLevel").get("v.value"));
    levelEvent.fire();
  },
  
  fillSelectOption : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // update select
        var cmp = component.find("selectLevel");        
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
      if (opts.length <= 0) {
        opts = [{ "tag": "option", Level__c: "No Level", selected: "true" }];
        emptyList = true;
      }
	  opts.forEach(function (opt) {
        if (opt.Level__c != ''){
          $A.createComponent( 'aura:html', {tag: 'option', HTMLAttributes: {value: opt, text: opt, selected: selectedState}}, 
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
          this.addSelectFirstLine("Pick a Level", component);
      } 
/*      
      if (selectedState == true){
        //  fill the item box for the default
        parentComponent.find("selectLevel").set("v.value", selectedId);
        parentComponent.find("selectLevel").set("v.text", sprint);
        this.broadcastSprint(parentComponent);
      }
*/
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
	
})