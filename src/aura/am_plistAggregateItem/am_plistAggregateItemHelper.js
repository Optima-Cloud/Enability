({
  getAggregateItemData: function(component, event, helper) {
    // Setup the apex action to call
    var action = component.get("c.getAggregateItems");
    action.setParams({ aProject : component.get("v.project"),
                       aLevel : component.get("v.level"),
                       aSprint : component.get("v.sprint")  });
    //  setup the call back function and fill the select box
    helper.fillSelectOption(action, component);
  },
  
  fillSelectOption : function(action, component){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var cmp = component.find("selectAggregateItem"); 
        //  check aggregate items returned
        cmp.set('v.body', []); // clear all options
        cmp.set('v.disabled', false);

        this.addSelectOption( response.getReturnValue(), cmp, component);
      }
      else 
        this.executeUpdateCallback(action, component, "");

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
        opts[0] = "No Aggregate Item";
        emptyList = true;
      }
	  opts.forEach(function (opt) {
          $A.createComponent( 'aura:html', {tag: 'option', HTMLAttributes: {value: opt, text: opt, selected: selectedState}}, 
            function (newOption) {
              //Add options to the body
              if (component.isValid()) { 
                body.push(newOption);
                component.set('v.body', body);             
              }
              else if (status === "INCOMPLETE") 
                console.log("No response from server or client is offline.")
              else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
              }
            } 
          )
      })
      if (emptyList == false)
          this.addSelectFirstLine("Pick an Aggregate Item", component);
      else 
        component.set('v.disabled', true);                   
      
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
          } else
            this.executeUpdateCallback(action, component, "");
        } 
      )
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