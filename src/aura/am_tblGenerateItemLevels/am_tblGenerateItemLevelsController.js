({
  doInit : function(component, event, helper) {
    var key = component.get("v.key");
        var map1 = component.get("v.mapBacklog");
    var newmap = {};
//    newmap[key] = "hell"+key;
    newmap = "hell"+key;
    // set the values of map to the value attribute	
    component.set("v.item", newmap);
//    component.set("v.item", {'sobjectType': 'Progress__c',
//                  'Level__c': map[key].Level__c });
//for (key of component.get("v.mapBacklog")){
console.log('tbl key = ' + key); 
console.log('tbl item = ' + component.get("v.item"));
console.log('tbl map1 = ' + map1); 
//}
  },
})