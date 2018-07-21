global class am_Stage {
  /* 
   *  Written by:  David Strangward
   *  Date:  14/8/2016 
   *  Modified by:
   *  Date Modified: 
   *
   *  Description:  Handles everything to do with stages.
   *                Methods to get the next stage, get the stage number.
   */
   
   private Map<String, Decimal> picklistByName;
   private Map<String, Decimal> picklistByIndex; 
   private Map<String, List<Picklist_Setup__c>> picklistByRecordType; 

   public  am_Stage(){
     //  get all the stages
     Map<String, Picklist_Setup__c> pls = Picklist_Setup__c.getAll(); 

     //  create the different object stage lists
     picklistByName = new Map<String, Decimal>();
     picklistByIndex = new Map<String, Decimal>();
     picklistByRecordType = new Map<String, List<Picklist_Setup__c>>();
     for (Picklist_Setup__c pc : Picklist_Setup__c.getAll().values()){
       picklistByName.put(pc.Name, pc.Value_Index__c);         
       picklistByIndex.put(pc.Record_Type__c + pc.Value_Index__c, pc.Value_Index__c);   
       if(picklistByRecordType.containsKey(pc.Record_Type__c)){
         // add the stage to an existing recordtype
         picklistByRecordType.get(pc.Record_Type__c).add(pc);
       } else {
         //  add the record type key and list of stages 
         List<Picklist_Setup__c> newList = new List<Picklist_Setup__c>(); 
         newList.add(pc); 
         picklistByRecordType.put(pc.Record_Type__c, newList);
       }
     }
     
     //  sort the stage lists for each record type
     List<PicklistWrapper> tempPicklist = new List<PicklistWrapper>();
     for (String idx : picklistByRecordType.keySet()){
    	 for (Picklist_Setup__c pl : picklistByRecordType.get(idx))
    	   tempPicklist.add(new PicklistWrapper(pl));
    	 tempPicklist.sort();
    	 picklistByRecordType.get(idx).clear();
    	 for (PicklistWrapper pw : tempPicklist)
    	   picklistByRecordType.get(idx).add(pw.stagePicklist); 
    	 tempPicklist.clear();
     } 
   }
   
  public static Decimal getStageIndex(String aRecordType, String aStage){ 
  	//  returns the index of the passed record type and stage
    am_Stage stages = new am_Stage();
    
   	return stages.picklistByName.get(aRecordType+aStage);
  }

  private static String getStageName(String aRecordType, Decimal aIndex){ 
  	//  returns the name of the passed record type and stage
    am_Stage stages = new am_Stage();
    String returnStage = '';
    
    List<Picklist_Setup__c> temp = stages.picklistByRecordType.get(aRecordType);
    for (Picklist_Setup__c pl : temp)
      if (pl.Value_Index__c == aIndex)
        returnStage = pl.Value_Name__c;
        
   	return returnStage;
  }
/*
  public static List<Picklist_Setup__c> getRecordTypeStages(String aRecordType){ 
  	//  returns a sorted list of the stages for the stage record type
    am_Stage stages = new am_Stage();
   	return stages.picklistByRecordType.get(aRecordType);
  }
*/
  public static List<String> getRecordTypeStageNames(String aRecordType){ 
  	//  returns a sorted list of the stages for the stage record type
    am_Stage stages = new am_Stage();
  	List<String> tempList = new List<String>();
  	for (Picklist_Setup__c pl : stages.picklistByRecordType.get(aRecordType))
  	  tempList.add(pl.Value_Name__c);
   	return tempList;
  } 

   private static Decimal getNextStageIndex(String aStageType, String stage){
     //  return the index of the next stage, returns index of current if the last index
     am_Stage stages = new am_Stage();
     
     Decimal currentIndex = stages.picklistByName.get(aStageType+stage);
     Decimal nextIndex = stages.picklistByIndex.get(aStageType+(currentIndex+1));
     if (nextIndex != null)
       return nextIndex; 
     else
       return currentIndex;         
   } 

   private static Decimal getPriorStageIndex(String aStageType, String stage){
     //  return the index of the prior stage, returns index of current if the first index
     am_Stage stages = new am_Stage();
     Decimal priorIndex;
     
     Decimal currentIndex = stages.picklistByName.get(aStageType+stage);
     if (currentIndex > 1)
       priorIndex = stages.picklistByIndex.get(aStageType+(currentIndex-1));
     else
       priorIndex = 0;
       
     return priorIndex;         
   } 

   private static String getMinimumStage(String aStageType){
     //  return the index of the prior stage, returns index of current if the first index
     return getStageName(aStageType, 0);         
   } 

   public static Decimal getLastStageIndex(String aStageType){
     //  returns the index for the last stage
     am_Stage stages = new am_Stage();
     Decimal index = 0; 
     for (Picklist_Setup__c pc : stages.picklistByRecordType.get(aStageType)){ 
       if (pc.Value_Index__c > index)
         index = pc.Value_Index__c; 
     }
     return index;
   }    

   private static Decimal getWorkContribution(String aStage, String aStageType){
     //  return the work contribution for the stage
    am_Stage stages = new am_Stage();
    Decimal workPercent = 0;
    
    List<Picklist_Setup__c> temp = stages.picklistByRecordType.get(aStageType);
    for (Picklist_Setup__c pl : temp)
      if (pl.Value_Name__c == aStage)
        workPercent = pl.Work_Contribution__c;
        
   	return workPercent;
   } 

   private static Decimal getWorkCummContribution(String aStage, String aStageType){
     //  return the work contribution for the stage
    am_Stage stages = new am_Stage();
    Decimal cummPercent = 0;
    Decimal index = getStageIndex(aStageType, aStage);
    
    List<Picklist_Setup__c> temp = stages.picklistByRecordType.get(aStageType);
    for (Picklist_Setup__c pl : temp)
      if (pl.Value_Index__c < index)
        cummPercent += pl.Work_Contribution__c;
        
   	return cummPercent;
   } 

  global class PicklistWrapper implements Comparable {
    //  enable sorting list of the stages by index 
    public Picklist_Setup__c stagePicklist;
    
    // Constructor
    public PicklistWrapper(Picklist_Setup__c plist) {
      stagePicklist = plist;
    }
    
    // Picklist opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) { 
      // Cast argument to PicklistWrapper 
      PicklistWrapper compareToPicklist = (PicklistWrapper)compareTo;
        
      // The return value of 0 indicates that both elements are equal, positive is >, negative is <.
      Integer returnValue = 0;
      if (stagePicklist.Record_Type__c == compareToPicklist.stagePicklist.Record_Type__c) {
    		if(stagePicklist.Value_Index__c > compareToPicklist.stagePicklist.Value_Index__c) 
          returnValue = 1;
        else if (stagePicklist.Value_Index__c < compareToPicklist.stagePicklist.Value_Index__c)
          returnValue = -1;
      } else if (stagePicklist.Record_Type__c < compareToPicklist.stagePicklist.Record_Type__c) {
        returnValue = -1;
      } else
        returnValue = 1;      
        
      return returnValue;       
    }
  }   

/*  private Decimal getMaxStageIndex(Decimal aCurrentStage, Decimal aNewStage, String aStageType){
    //  compares the current stage to the new stage and returns the later stage
    Decimal currentIndex = picklistByName.get(aStageType+aCurrentStage);
    Decimal newIndex = picklistByIndex.get(aStageType+aNewStage);
    if (newIndex > currentIndex)
      return newIndex; 
    else
      return currentIndex;         
  }  

  pending implementation and creation of tests
    public Decimal getLastStageIndex(String aStageType, Decimal stage){
      //  returns the index for the last stage
      Decimal index = 0; 
      for (String key : picklistByIndex.keySet()){
        if (key == aStageType+stage && picklistByIndex.get(key) > index)
          index = picklistByIndex.get(key);
      }
      return index;
    }    

  public Decimal getMaxStageIndex(Decimal aCurrentStage, Decimal aNewStage, String aStageType){
    //  compares the current stage to the new stage and returns the later stage
    Decimal currentIndex = picklistByIndex.get(aStageType+aCurrentStage);
    Decimal newIndex = picklistByIndex.get(aStageType+aNewStage);
    if (newIndex > currentIndex)
      return newIndex; 
    else
      return currentIndex;         
  }  
  
  
  public Decimal getMinStageIndex(String aCurrentStage, String aNewStage, String aStageType){
    //  compares the current stage to the new stage and returns the earlier stage
    Decimal currentIndex = picklistByName.get(aStageType+aCurrentStage);
    Decimal newIndex = picklistByIndex.get(aStageType+aNewStage);
    if (newIndex > currentIndex) 
      return currentIndex; 
    else
      return newIndex;         
  }  

    public Decimal getAdjacentStageIndex(String aCurrentStage, String aStageType, String Direction){
      //  returns the next stage based on the current stage and the project
      Decimal currentIndex = picklistByName.get(aStageType+aCurrentStage);
      if (Direction == 'Next'){
        if (getLastStageIndex(aStageType, currentIndex) == currentIndex)
          currentIndex =+ currentIndex;
        else
          currentIndex = getLastStageIndex(aStageType, currentIndex);
      } else {
        if ((currentIndex =- currentIndex) < 0)
          currentIndex = 0;
        else
          currentIndex =- currentIndex;
      }
      return currentIndex;
    }
*/    
    public static String getNextStage(String aStageType, String stage){
    //  returns the next stage based on the current stage and the project type

    return getStageName(aStageType, getNextStageIndex(aStageType, stage));
/*
    if (aStageType == 'Construction_Stages_4'){
      if (String.isBlank(stage) || stage == 'Pending')
        nextStage = 'Roughin';
      if (stage == 'Roughin')
        nextStage = 'Cutout';
      else if (stage == 'Cutout')
        nextStage = 'Fitoff';
      else if (stage == 'Fitoff') 
        nextStage = 'Commission';
      else if (stage == 'Commission') 
        nextStage = 'Completed';
    } else if (aStageType == 'Construction_Stages_3'){
      if (String.isBlank(stage) || stage == 'Pending')
        nextStage = 'Roughin';
      if (stage == 'Roughin')
        nextStage = 'Fitoff';
      else if (stage == 'Fitoff') 
        nextStage = 'Commission';
      else if (stage == 'Commission') 
        nextStage = 'Completed';
    } else if (aStageType == 'Construction_Stages_1'){
      if (String.isBlank(stage) || stage == 'Pending')
        nextStage = 'In Progress';
    } else if (aStageType == 'IT_Stages_2'){
      if (String.isBlank(stage) || stage == 'Pending')
        nextStage = 'Develop';
      else if (stage == 'Develop')
        nextStage = 'Implement';
      else if (stage == 'Commission') 
        nextStage = 'Completed'; 
    }
    return nextStage;
*/
  }   

    public static String getLastStage(String aStageType, String stage){
    //  returns the last stage based on the stage type

    return getStageName(aStageType, getLastStageIndex(aStageType));
/*
    String lastStage;
    if (aStageType == 'Construction_Stages_4')
      lastStage = 'Commission';
    else if (aStageType == 'Construction_Stages_3')
      lastStage = 'Commission';
    else if (aStageType == 'Construction_Stages_1')
      lastStage = 'In Progress';
    else if (aStageType == 'IT_Stages_2')
      lastStage = 'Implement';
   
    return lastStage;
*/    
  }   

  public static String getMaxStage(List<String> aStages, String aProjectType){
    //  cycle through all the stages and get the Maximum
    String maxStage;
    for (String newStage :aStages){ 
      maxStage = getMaxStage(maxStage, newStage, aProjectType);
    }
    return maxStage;

/*
    String maxStage;
    Integer i = 0;
    for (String s :aStages){ 
      if (i == 0){
        maxStage = s;
        i++;
      } else
        maxStage = getMaxStage(maxStage, s, aProjectType);
    }
    return maxStage;
*/    
  }  

  public static String getMaxStage(String aCurrentStage, String aNewStage, String aStageType){
    //  compares the current stage to the new stage and returns the later stage
   Decimal currentIndex = getStageIndex(aStageType, aCurrentStage);
   Decimal newIndex = getStageIndex(aStageType, aNewStage);
   if (currentIndex > newIndex)
     return aCurrentStage;
   else 
     return aNewStage;

/*
    String maxStage = 'Commission';

    if (aStageType == 'Construction_Stages_4'){
      if (aCurrentStage == 'Pending'){
        maxStage = aCurrentStage;
      } else if (aCurrentStage == 'Roughin'){
        if (aNewStage == 'Pending' || aNewStage == 'Roughin') 
          maxStage = aCurrentStage;
        else
          maxStage = aNewStage;
      } else if (aCurrentStage == 'Cutout') {
        if (aNewStage == 'Pending' || aNewStage == 'Roughin' || aNewStage == 'Cutout')
          maxStage = aCurrentStage;
        else 
          maxStage = aNewStage;
      } else if (aCurrentStage == 'Fitoff') {
        if (aNewStage == 'Pending' || aNewStage == 'Roughin' || aNewStage == 'Cutout' || aNewStage == 'Fitoff')
          maxStage = aCurrentStage;
        else 
          maxStage = aNewStage;
      }else if (aCurrentStage == 'Commission') {
          maxStage = aCurrentStage;
      } else
          maxStage = 'Commission';  // Returns the max if argument is blank so can be reduced down;
    
    }  else if (aStageType == 'Construction_Stages_3'){
      if (aCurrentStage == 'Pending'){
        maxStage = aCurrentStage;
      } else if (aCurrentStage == 'Roughin'){
        if (aNewStage == 'Pending' || aNewStage == 'Roughin') 
          maxStage = aCurrentStage;
        else
          maxStage = aNewStage;
      } else if (aCurrentStage == 'Fitoff') {
        if (aNewStage == 'Pending' || aNewStage == 'Roughin' || aNewStage == 'Cutout' || aNewStage == 'Fitoff')
          maxStage = aCurrentStage;
        else 
          maxStage = aNewStage;
      }else if (aCurrentStage == 'Commission') {
          maxStage = aCurrentStage;
      } else
          maxStage = 'Commission';  // Returns the max if argument is blank so can be reduced down;

    } else if (aStageType == 'Construction_Stages_1'){
      if (aCurrentStage == 'Pending')
        maxStage = aCurrentStage;

    } else if (aStageType == 'IT_Stages_2'){
      if (aNewStage == 'Pending')
        maxStage = aNewStage;
      else if (aCurrentStage == 'Develop')
        if (aNewStage == 'Pending' || aNewStage == 'Develop')
          maxStage = aCurrentStage;  
      }
    return maxStage;    
*/
    }
    

  public static String getMinStage(Set<String> aStages, String aProjectType){
    //  cycle through all the stages and get the minimum
    String minStage;
    for (String newStage :aStages){ 
      minStage = getMinStage(minStage, newStage, aProjectType);
    }
    return minStage;
/*
    String minStage;
    Integer i = 0;

    for (String s :aStages){
      if (i == 0){
        minStage = s;
        i++;
      } else
        minStage = getMinStage(minStage, s, aProjectType);
    }
    return minStage;
*/    
  }  

  public static String getMinStage(String aCurrentStage, String aNewStage, String aProjectType){
    //  compares the current stage to the new stage and returns the earlier stage

   Decimal currentIndex = getStageIndex(aProjectType, aCurrentStage);
   Decimal newIndex = getStageIndex(aProjectType, aNewStage);
   if (currentIndex <= newIndex)
     return aCurrentStage;
   else 
     return aNewStage;
/*   
    String minStage = 'Commission';

    if (aProjectType == 'Construction_Stages_4'){
      if (aCurrentStage == 'Pending'){
        minStage = aCurrentStage;
      } else if (aCurrentStage == 'Roughin'){
        if (aNewStage == 'Pending' || aNewStage == 'Roughin') 
          minStage = aNewStage;
        else
          minStage = aCurrentStage;
      } else if (aCurrentStage == 'Cutout') {
        if (aNewStage == 'Pending' || aNewStage == 'Roughin' || aNewStage == 'Cutout')
          minStage = aNewStage;
        else 
          minStage = aCurrentStage;
      } else if (aCurrentStage == 'Fitoff') {
        if (aNewStage == 'Pending' || aNewStage == 'Roughin' || aNewStage == 'Cutout' || aNewStage == 'Fitoff')
          minStage = aNewStage;
        else
          minStage = aCurrentStage;
      }else if (aCurrentStage == 'Commission') {
          minStage = aNewStage;
      } else
          minStage = 'Commission';  // Returns the max if argument is blank so can be reduced down;

    } else if (aProjectType == 'IT_Stages_2'){
      if (aNewStage == 'Pending')
        minStage = aNewStage;
      else if (aCurrentStage == 'Develop')
        if (aNewStage == 'Pending' || aNewStage == 'Develop')
          minStage = aNewStage;  
      }
    return minStage;    
*/
    }
    
  public static Boolean checkMinStage(String aStage, String aProjectType){
    //  cycle through all the stages and get the minimum
    
    if (aStage == getMinimumStage(aProjectType))
      return true;
    else
      return false;
  }  


    public Static Decimal getStageStatusPercentage(String aStage, String aStatus, String aStageType, String aAction){
      //  returns the cummulative percent or percent for the stage stage depending on aAction which can be 'Cummulative' or 'StatusBased' 
      Decimal returnCummulativePercent = 0;
      Decimal returnStageStatusPercent = 0;
      Decimal percentStarted = 40;

      if (string.isBlank(aStatus)) 
        aStatus = 'Not Started';        
 
      if (aStage == 'StatusOnly'){
        if (aStatus == 'Started'){
          returnCummulativePercent = percentStarted;
          returnStageStatusPercent = percentStarted;
        } else if (aStatus == 'Not Started'){
          returnCummulativePercent = 0;
          returnStageStatusPercent = 0;
        } else {
          returnCummulativePercent = 100;
          returnStageStatusPercent = 100;
        }
      } else {
        if (aStatus == 'Started'){
          returnCummulativePercent = getWorkCummContribution(aStage, aStageType) + getWorkContribution(aStage, aStageType) * percentStarted / 100;
          returnStageStatusPercent = getWorkContribution(aStage, aStageType) * percentStarted / 100;
        } else if (aStatus == 'Not Started'){
          returnCummulativePercent = getWorkCummContribution(aStage, aStageType);
          returnStageStatusPercent = 0;
        } else{
          returnCummulativePercent = getWorkCummContribution(aStage, aStageType) + getWorkContribution(aStage, aStageType);
          returnStageStatusPercent = getWorkContribution(aStage, aStageType);
        }
      } 

      if (aAction == 'Cummulative')
        return returnCummulativePercent;
      else 
        return returnStageStatusPercent;
    }    
/*
    public Static Decimal getStageStatusPercentage(String Stage, String Status, String aStageType, String aAction){
      //  returns the cummulative percent or percent for the stage stage depending on aAction which can be 'Cummulative' or 'StatusBased' 
      Decimal returnCummulativePercent = 0;
      Decimal returnStageStatusPercent = 0;
      Decimal percentStage0 = 0;
      Decimal percentStage1 = 40;
      Decimal percentStage2 = 10;
      Decimal percentStage3 = 45;
      Decimal percentStage4 = 5;
      Decimal percentStage1Stage = 100;  //  to cater for hours based on infrastructure install
      Decimal percentStage2Stage = 9;
      Decimal percentStage3Stage = 75;
      Decimal percentStage4Stage = 16;
      Decimal percentStarted = 40;

      Decimal percent3Stage1 = 45;
      Decimal percent3Stage2 = 45;
      Decimal percent3Stage3 = 5;
 
      if (string.isBlank(Status))
        status = 'Not Started';
        
      if (aStageType == 'Construction_Stages_4'){
        if (Stage == 'StatusOnly'){
          if (Status == 'Started'){
            returnCummulativePercent = percentStarted;
            returnStageStatusPercent = percentStarted;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage0;
            returnStageStatusPercent = percentStage0;
          } else {
            returnCummulativePercent = 100;
            returnStageStatusPercent = 100;
          }
        }
        else if (Stage == 'Roughin') 
          if (Status == 'Started'){
            returnCummulativePercent = percentStage1 * percentStarted / 100;
            returnStageStatusPercent = percentStage1Stage * (100 - percentStarted) / 100;
//            returnStageStatusPercent = percentStage1 * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage0;
            returnStageStatusPercent = percentStage1Stage;
          } else{
            returnCummulativePercent = percentStage1;
            returnStageStatusPercent = percentStage0;
          }
        else if (Stage == 'Cutout')
          if (Status == 'Started'){
            returnCummulativePercent = percentStage1 + percentStage2 * percentStarted / 100;
            returnStageStatusPercent = percentStage2Stage * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage1;
            returnStageStatusPercent = percentStage2Stage;
          } else{
            returnCummulativePercent = percentStage1 + percentStage2;
            returnStageStatusPercent = percentStage0;
          }  
        else if (Stage == 'Fitoff')
          if (Status == 'Started'){
            returnCummulativePercent = percentStage1 + percentStage2 + percentStage3 * percentStarted / 100;
            returnStageStatusPercent = percentStage3Stage * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage1 + percentStage2;
            returnStageStatusPercent = percentStage3Stage;
          } else{
            returnCummulativePercent = (percentStage1 + percentStage2 + percentStage3);
            returnStageStatusPercent = percentStage0;
          }
        else if (Stage == 'Commission')
          if (Status == 'Started'){
            returnCummulativePercent = percentStage1 + percentStage2 + percentStage3 + percentStage4 * percentStarted / 100;
            returnStageStatusPercent = percentStage4Stage * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage1 + percentStage2 + percentStage3;
            returnStageStatusPercent = percentStage3Stage;
          } else{
            returnCummulativePercent = percentStage1 + percentStage2 + percentStage3 + percentStage4;
            returnStageStatusPercent = percentStage0;
          }
      } else if (aStageType == 'Construction_Stages_3'){
        if (Stage == 'StatusOnly'){
          if (Status == 'Started'){
            returnCummulativePercent = percentStarted;
            returnStageStatusPercent = percentStarted;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage0;
            returnStageStatusPercent = percentStage0;
          } else{
            returnCummulativePercent = 100;
            returnStageStatusPercent = 100;
          }
        }
        else if (Stage == 'Roughin') 
          if (Status == 'Started'){
            returnCummulativePercent = percent3Stage1 * percentStarted / 100;
            returnStageStatusPercent = percent3Stage1 * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage0;
            returnStageStatusPercent = percentStage1;
          } else{
            returnCummulativePercent = percent3Stage1;
            returnStageStatusPercent = percentStage0;
          }
        else if (Stage == 'Fitoff')
          if (Status == 'Started'){
            returnCummulativePercent = percent3Stage1 + percent3Stage2 * percentStarted / 100;
            returnStageStatusPercent = percent3Stage2 * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percent3Stage2;
            returnStageStatusPercent = percent3Stage2;
          } else{
            returnCummulativePercent = (percent3Stage1 + percent3Stage2);
            returnStageStatusPercent = percentStage0;
          }
        else if (Stage == 'Commission')
          if (Status == 'Started'){
            returnCummulativePercent = percent3Stage1 + percent3Stage2 + percent3Stage3 * percentStarted / 100;
            returnStageStatusPercent = percent3Stage3 * (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percent3Stage3;
            returnStageStatusPercent = percent3Stage3;
          } else{
            returnCummulativePercent = percent3Stage1 + percent3Stage2 + percent3Stage3;
            returnStageStatusPercent = percentStage0;
          }            
      } else if (aStageType == 'Construction_Stages_1'){
          if (Status == 'Started'){
            returnCummulativePercent = percentStarted;
            returnStageStatusPercent = (100 - percentStarted) / 100;
          } else if (Status == 'Not Started'){
            returnCummulativePercent = percentStage0;
            returnStageStatusPercent = 100;
          } else{
            returnCummulativePercent = 100;
            returnStageStatusPercent = percentStage0;
          }
      } else if (aStageType == 'IT_Stages_2'){
          if (Stage == 'Develop'){
            if (Status == 'Started'){
              returnCummulativePercent = 40 * percentStarted / 100;
              returnStageStatusPercent = 40 * (100 - percentStarted) / 100;
            } else if (Status == 'Not Started'){
              returnCummulativePercent = 40;
              returnStageStatusPercent = 40;
            } else {
              returnCummulativePercent = 40;
              returnStageStatusPercent = 0;
            }
          } else {  
            if (Status == 'Started'){
              returnCummulativePercent = 100 * percentStarted / 100;
              returnStageStatusPercent = 60 * (100 - percentStarted) / 100;
            } else if (Status == 'Not Started'){
              returnCummulativePercent = 100;
              returnStageStatusPercent = 60;
            } else {
              returnCummulativePercent = 100;
              returnStageStatusPercent = 0;
            }
          }
      }
        
      if (aAction == 'Cummulative')
        return returnCummulativePercent;
      else 
        return returnStageStatusPercent;
    }    
*/
    public Static String getAdjacentStage(String aCurrentStage, String aStageType, String Direction){
      //  returns the next stage based on the current stage and the project
      if (Direction == 'Next')
        return getStageName(aStageType, getNextStageIndex(aStageType, aCurrentStage));
      else
        return getStageName(aStageType, getPriorStageIndex(aStageType, aCurrentStage));
      

/*
        String priorStage;
        String NextStage;

        if (aStageType == 'Construction_Stages_4'){
            if (String.isBlank(aCurrentStage) || aCurrentStage == 'Roughin'){
                priorStage = 'Pending';
                NextStage = 'Cutout';
            }
            else if (aCurrentStage == 'Cutout'){
                priorStage = 'Roughin';
                NextStage = 'Fitoff';
            }
            else if (aCurrentStage == 'Fitoff'){
                priorStage = 'Cutout';
                NextStage = 'Commission';
            }
            else if (aCurrentStage == 'Commission'){
                priorStage = 'Fitoff';
                NextStage = 'Commission';
            }
         } 
         else if (aStageType == 'Construction_Stages_3'){
            if (String.isBlank(aCurrentStage) || aCurrentStage == 'Roughin'){
                priorStage = 'Pending';
                NextStage = 'Fitoff';
            }
            else if (aCurrentStage == 'Fitoff'){
                priorStage = 'Cutout';
                NextStage = 'Commission';
            }
            else if (aCurrentStage == 'Commission'){
                priorStage = 'Fitoff';
                NextStage = 'Commission';
            }
         } 
         else if (aStageType == 'IT_Stages_2'){
            if (String.isBlank(aCurrentStage) || aCurrentStage == 'Develop'){
                priorStage = 'Pending';
                NextStage = 'Implement';
            }
            else if (aCurrentStage == 'Implement'){
                priorStage = 'Develop';
                NextStage = 'Commission';
            }
        }
        if (Direction == 'Next')
            priorStage = NextStage;
        return priorStage;
*/
    }
/*
    public static String getPriorStage(Progress__c item, String aStageType){
        //  returns the next stage based on the current stage and the project
        String priorStage;

        if (aStageType == 'Construction_Stages_4'){
            if (String.isBlank(item.Project__r.Project_Type__c) || item.Project__r.Project_Type__c == 'Roughin')
                priorStage = 'Pending';
            else if (item.Stage__c == 'Cutout')
                priorStage = 'Roughin';
            else if (item.Stage__c == 'Fitoff')
                priorStage = 'Cutout';
           else if (item.Stage__c == 'Commission')
                priorStage = 'Fitoff';
         } else if (aStageType == 'IT_Stages_2'){
            if (String.isBlank(item.Stage__c) || item.Stage__c == 'Develop')
                priorStage = 'Pending';
            else if (item.Stage__c == 'Implement')
                priorStage = 'Develop';
        }
        return priorStage;
    }
*/

    public static String getPriorStage(String aCurrentStage, String aStageType){
        //  returns the next stage based on the current stage and the project
    return getStageName(aStageType, getPriorStageIndex(aStageType, aCurrentStage));

/*
        String priorStage;

        if (aStageType == 'Construction_Stages_4'){
            if (String.isBlank(aCurrentStage) || aCurrentStage == 'Roughin')
                priorStage = 'Pending';
            else if (aCurrentStage == 'Cutout')
                priorStage = 'Roughin';
            else if (aCurrentStage == 'Fitoff')
                priorStage = 'Cutout';
           else if (aCurrentStage == 'Commission')
                priorStage = 'Fitoff';
         } else if (aStageType == 'IT_Stages_2'){
            if (String.isBlank(aCurrentStage) || aCurrentStage == 'Develop')
                priorStage = 'Pending';
            else if (aCurrentStage == 'Implement')
                priorStage = 'Develop';
        }
        return priorStage;
*/
    }

  public static Boolean isHigherStage(String aCurrentStage, String aStageType, String aQueryStage){
    //  returns true if the queryStage is greater than the currentStage
   Decimal currentIndex = getStageIndex(aStageType, aCurrentStage);
   Decimal queryIndex = getStageIndex(aStageType, aQueryStage);
   if (currentIndex < queryIndex)
     return true;
   else 
     return false;

/*
    String nextStage = aQueryStage;
    String tempStage;
    Boolean earlierStage = true;
    if (aCurrentStage != aQueryStage) {
      do {
        tempStage = nextStage;
        nextStage = getAdjacentStage(tempStage, aStageType, 'Next');
        if (aCurrentStage == nextStage){
          earlierStage = false;
          break;    
        }
      } while (nextStage != tempStage);
    } else
      earlierStage = false;
    return earlierStage;
*/
  }
    
}