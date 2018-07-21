({
  onDragStart : function(component, event, helper) {
    event.dataTransfer.dropEffect = "move";
    var item = component.get('v.item');
    event.dataTransfer.setData('item', JSON.stringify(item));
    event.dataTransfer.setData('type', JSON.stringify('item'));
  }
})