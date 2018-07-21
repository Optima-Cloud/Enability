({
    doInit : function(component, event, helper){
      component.set("v.showTimeEntry", "false");
      component.set("v.showSprintReview", "false");
      component.set("v.showCreateIssue", "false");
      component.set("v.showReviewBuild", "false");
      component.set("v.showReviewIssue", "false");
      component.set("v.showBacklogQueue", "false");
    },
	clickEnterTimes : function(component, event, helper) {
	  component.set("v.showTimeEntry", true);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", false);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
	},
	
	clickSprintReview : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", true);	
	  component.set("v.showCreateIssue", false);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
	},
	
	clickCreateIssue : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", true);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
    },	
    
	clickCreateIssue : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", true);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
    },	
    
	clickAgileMap : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", false);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
	  component.set("v.showAgileMap", true);	
    },	  
	
	clickBacklogQueue : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", false);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", true);	
    },	  
	
	clickListBuilder : function(component, event, helper) {
      component.set("v.showTimeEntry", false);	
	  component.set("v.showSprintReview", false);	
	  component.set("v.showCreateIssue", false);	
	  component.set("v.showReviewIssue", false);	
	  component.set("v.showBacklogQueue", false);	
	  component.set("v.showListBuilder", true);	
    }	  
})