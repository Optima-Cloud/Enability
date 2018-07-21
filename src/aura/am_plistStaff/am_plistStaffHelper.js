({
  fillSelectOption : function(action, component, selectType){
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        // update select
        var cmp = component.find("select".concat(selectType));        
        cmp.set('v.body', []); // clear all options
        this.addSelectOption( response.getReturnValue(), cmp, selectType );        
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

  addSelectOption : function(opts, component, selectType) {
      // for each option an an option to the select box
      var body = component.get('v.body');
      var emptyList = false;
      if (opts.length <= 0) {
        opts = [{ "tag": "option", Name: "No ".concat(selectType), selected: "true" }];
        emptyList = true;
      }
	  opts.forEach(function (opt) {
        if (selectType == "Item"){
          opt.Name = opt.Item__r.Name;
          opt.Id = opt.Item__r.Id;
        }
        else if (selectType == "Project"){
          component.set('v.projectId', opt.Id);
        }
        if (opt.Name != ''){
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
        }
      })
      if (emptyList == false) {
        if (selectType == "Item"){
          this.addSelectFirstLine("Pick an ".concat(selectType), component);
        }
        else {
          this.addSelectFirstLine("Pick a ".concat(selectType), component);
        }
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