({
  doInit : function(component, event, helper) {
  },

  allowDrop: function(component, event, helper) {
    event.preventDefault();
  },
    
  onDrop: function(component, event, helper) {
    event.preventDefault();
    var epicChangeEvent = component.getEvent('am_evtEpicChange');

    epicChangeEvent.setParams({
      'title': component.get('v.epic.title'),
      'item': JSON.parse(event.dataTransfer.getData('item')),
      'type': JSON.parse(event.dataTransfer.getData('type')),
    });
    epicChangeEvent.fire();
        
  },
})