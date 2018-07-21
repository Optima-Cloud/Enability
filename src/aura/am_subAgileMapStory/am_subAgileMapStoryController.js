({
  doInit : function(component, event, helper) {
  },

  onDragStart : function(component, event, helper) {
    event.dataTransfer.dropEffect = "move";
    var story = component.get('v.story');
//         $A.util.addClass(component.find('story'), 'moving-card');
    event.dataTransfer.setData('item', JSON.stringify(story));
    event.dataTransfer.setData('type', JSON.stringify('story'));
  },
  
  allowDrop: function(component, event, helper) {
    event.preventDefault();
  },
    
  onDrop: function(component, event, helper) {
    event.preventDefault();
    var epicChangeEvent = component.getEvent('am_evtEpicChange');

    epicChangeEvent.setParams({
      'dropStory': component.get('v.story'),
      'item': JSON.parse(event.dataTransfer.getData('item')),
      'type': JSON.parse(event.dataTransfer.getData('type'))
    });
    epicChangeEvent.fire();
        
  }  
})