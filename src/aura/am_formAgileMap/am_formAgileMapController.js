({
  doInit: function(component, event, helper) {
    helper.createData(component);
  },

  onEpicChanged: function(component, event, helper) {
    var type = event.getParam("type");
    
    if (event.getParam("type") == 'story')
      helper.moveStory(component, event);
    else if (event.getParam("type") == 'item')
      helper.moveItem(component, event);    
  }
 
})