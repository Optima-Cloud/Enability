({
  createData : function(component) {
    var newItems = [
      { title: "Item 1", idItem: "1.1.1", idStory: "1.1", idEpic: "1", story: "Story 1", epic: "Epic 1", description: "Description Item 1", storydescription: "Description Story 1"},
      { title: "Item 2", idItem: "1.1.2", idStory: "1.1", idEpic: "1", story: "Story 1", epic: "Epic 1", description: "Description Item 2", storydescription: "Description Story 1"},
      { title: "Item 3", idItem: "1.1.3", idStory: "1.1", idEpic: "1", story: "Story 1", epic: "Epic 1", description: "Description Item 3", storydescription: "Description Story 1"},
      { title: "Item 4", idItem: "1.2.1", idStory: "1.2", idEpic: "1", story: "Story 2", epic: "Epic 1", description: "Description Item 4", storydescription: "Description Story 2"},
      { title: "Item 5", idItem: "1.2.2", idStory: "1.2", idEpic: "1", story: "Story 2", epic: "Epic 1", description: "Description Item 5", storydescription: "Description Story 2"},
      { title: "Item 6", idItem: "1.2.3", idStory: "1.2", idEpic: "1", story: "Story 2", epic: "Epic 1", description: "Description Item 6", storydescription: "Description Story 2"},
      { title: "Item 7", idItem: "1.3.1", idStory: "1.3", idEpic: "1", story: "Story 3", epic: "Epic 1", description: "Description Item 7", storydescription: "Description Story 3"},
      { title: "Item 8", idItem: "2.1.1", idStory: "2.1", idEpic: "2", story: "Story 4", epic: "Epic 2", description: "Description Item 8", storydescription: "Description Story 4"},
      { title: "Item 9", idItem: "2.2.1", idStory: "2.2", idEpic: "2", story: "Story 5", epic: "Epic 2", description: "Description Item 9", storydescription: "Description Story 5"},
      { title: "Item 10", idItem: "2.3.1", idStory: "2.3", idEpic: "2", story: "Story 6", epic: "Epic 2", description: "Description Item 10", storydescription: "Description Story 6"},
      { title: "Item 11", idItem: "3.1.1", idStory: "3.1", idEpic: "3", story: "Story 7", epic: "Epic 3", description: "Description Item 11", storydescription: "Description Story 7"},
      { title: "Item 12", idItem: "3.2.1", idStory: "3.1", idEpic: "3", story: "Story 7", epic: "Epic 3", description: "Description Item 12", storydescription: "Description Story 7"},
      { title: "Item 13", idItem: "2.3.2", idStory: "2.3", idEpic: "2", story: "Story 6", epic: "Epic 2", description: "Description Item 13", storydescription: "Description Story 6"},
      { title: "Item 14", idItem: "2.3.3", idStory: "2.3", idEpic: "2", story: "Story 6", epic: "Epic 2", description: "Description Item 14", storydescription: "Description Story 6"}
    ];

    var storyList = [];
    var epicList = [];

    // Create story list
    for(var i=0; i<newItems.length; i++) {
      // Greate item record
      var thisItem = { "title": newItems[i].title, "id": newItems[i].idItem,  "description": newItems[i].description };
      // Pull out the field that's going to be the key
      var thisStory = newItems[i].story;

      // Keep track of whether our key already exists in myObjectMap
      var found = false;
      // Loop through our map and see if an entry for our key exists
      for(var x=0; x<storyList.length; x++) {
        if(storyList[x].title  == thisStory) {
          storyList[x].items.push(thisItem);
          // We found our key and pushed the record into its list, no need to continue
          found = true;
          break;
        }
      }
      // Need to make sure this record found a home; if it didn't then we need to initialize it in our "map"
      if(!found) {
        var newStory = { "title": newItems[i].story, "description": newItems[i].storydescription, "id": newItems[i].idStory, "epic": newItems[i].epic, "items": [thisItem] };
        storyList.push(newStory);
      }
    }

    // Create epic list
    for(var y=0; y<storyList.length; y++){
      var thisEpic = storyList[y].epic;
      var thisStory = storyList[y];
    
      var found = false;
      for(var k=0; k<epicList.length; k++) {
        if(epicList[k].title  == thisEpic) {
          epicList[k].stories.push(thisStory);
          // We found our key and pushed the record into its list, no need to continue
          found = true;
          break;
        }
      }
      // Need to make sure this record found a home; if it didn't then we need to initialize it in our "map"
      if(!found) {
        var newEpic = { "title": thisStory.epic, "id": thisStory.idEpic, "stories": [thisStory] };
        epicList.push(newEpic);
      }
    }
/*
   for (var l = 0; l < epicList.length; l++){
     console.log('epic title = ' + epicList[l].title);
     for (var i = 0; i < epicList[l].stories.length; i++){
       console.log('story title = ' + epicList[l].stories[i].title);
       console.log('story id = ' + epicList[l].stories[i].id);
       for (var j = 0; j < epicList[l].stories[i].items.length; j++)
         console.log('item = ' + epicList[l].stories[i].items[j].title); 
     }
   }
*/
    component.set("v.epicList", epicList);
  },
  
  moveStory : function(component, event) {
    var moveStory = event.getParam("item");
    var newStoryId = event.getParam("dropStory").id;
    var thisStory;
    var remove = false;
    var add = false;

    var epicList = component.get("v.epicList");
    
    // Find elements to update
    for(var i=0; i<epicList.length; i++){
      for(var j=0; j<epicList[i].stories.length; j++) {
        //  find location to remove
        thisStory = epicList[i].stories[j];
        if(thisStory.id  == moveStory.id) { 
          epicList[i].stories.splice(j,1); 
        }
        //  find location to add
        if(thisStory.id  == newStoryId){
          epicList[i].stories.splice(j, 0, moveStory);
          j++;
        }
      }
    }
    
    component.set("v.epicList", epicList);
    
/*
   for (var l = 0; l < epicList.length; l++){
     console.log('epic title = ' + epicList[l].title);
     for (var i = 0; i < epicList[l].stories.length; i++){
       console.log('story title = ' + epicList[l].stories[i].title);
       console.log('story id = ' + epicList[l].stories[i].id);
       for (var j = 0; j < epicList[l].stories[i].items.length; j++)
         console.log('item = ' + epicList[l].stories[i].items[j].title);
     }
    }	
*/
  }
      
})