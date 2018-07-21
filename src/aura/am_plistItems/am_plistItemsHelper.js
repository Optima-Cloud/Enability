({
  getItemsDataHelper : function(component, event, helper, action) {
    // Load items from Salesforce and fill out select list
    // Setup the apex action to call
    if(component.get("v.requestSource") == "Sprint" && component.get("v.allowableSource") == "Sprint"){
      var action = component.get("c.getItemsSprint");
      action.setParams({ aSprint : component.get("v.sprint") });
    } else if(component.get("v.requestSource") == "Project" && component.get("v.allowableSource") == "Project"){
      // Setup the apex action to call
      var action = component.get("c.getItemsProject");
      action.setParams({ aProject : component.get("v.project") });
    } else if(component.get("v.requestSource") == "Level" && component.get("v.allowableSource") == "Sprint"){
      // Setup the apex action to call
      var action = component.get("c.getItemsLevel");
      action.setParams({ aProject : component.get("v.project"), aLevel : component.get("v.level")});
    } else if(component.get("v.requestSource") == "AggregateItem" && component.get("v.allowableSource") == "Sprint"){
      // Setup the apex action to call
      var action = component.get("c.getItemsAggregateItem");
      action.setParams({ aAggregateItem : component.get("v.aggregateItem")});
    } else {
      //  reset the item list
      var action = component.get("c.getItemsProject");
      action.setParams({ aProject : "" });
    }

    //  setup the call back function and fill the select box
    if (action != null){
      this.fillSelectOption(action, component);
    }
  },

  fillSelectOption : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // update select
        var cmp = component.find("selectItem");        
        cmp.set('v.body', []); // clear all options
        this.addSelectOption( response.getReturnValue(), cmp, component);
        //  clear the item components        
      } else if (component.isValid() && state === "INCOMPLETE") {
        console.log("No response from server or client is offline.")
      } else if (component.isValid() && state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) 
            console.log("fillSelectOption - Error message: " + errors[0].message);
        } else {
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
      if (opts.length <= 0) {
        opts = [{ "tag": "option", Name: "No Items", selected: "true" }];
        emptyList = true;
      }

	  opts.forEach(function (opt) {
        if (emptyList == false){
          if (parentComponent.get("v.requestSource") == "Sprint"){
            opt.Name = opt.Item__r.Name;
            opt.Id = opt.Item__r.Id;
          } else if (component.get("v.requestSource") == "Project"){
            opt.Name = opt.Name;
            opt.Id = opt.Id;
          }  
        }
        $A.createComponent( 'aura:html', {tag: 'option', HTMLAttributes: {value: opt.Id, text: opt.Name}}, 
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
      })
      if (emptyList == false) {
        component.set('v.disabled', false);             
        this.addSelectFirstLine("Pick an Item", component);
      } else {
        component.set('v.disabled', true);                   
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
	
})