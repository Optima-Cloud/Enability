public Class checkRecursive{

    private static boolean run = true;
    private static boolean runbefore = true;
    private static boolean runafter = true;
    public static boolean runOnce(){
      if(run){
        run=false;
        return true;
      }else{
        return run;
      }
    }
    
    public static boolean runBeforeOnce(){  
      if(runbefore){
        runbefore=false;
        return true; 
      }
      else
       return runbefore;
    } 
    
    public static boolean runAfterOnce(){
      if(runafter){
        runafter=false;
        return true;
      }
      else
        return runafter;
    }
}