public class Manning_schedule {
  /*
   *  Written by:  David Strangward
   *  Date:  2/6/2016
   *  Modified by:
   *  Date Modified:
   *
   *  Description:  Creates role based and month based manning schedules.
   *                
   */

    public static void Upsert_Manning_Schedules(){
        // goes through each project role and calculates all the costs associated with that role
        // then inserts the costs for the role on a monthly basis into manning schedules
        // then creates a monthly manning schedule for the project based on the monthly cost manning schedule
        boolean debugOn = False;
//        boolean debugOn = True;
        List<Manning_Schedule__c> roleManningSchedules = new list<Manning_Schedule__c>();
        List<Manning_Schedule__c> projectManningSchedules = new list<Manning_Schedule__c>();

        //  check  active projects and project roles, otherwise abort
        AggregateResult activeProjects = [SELECT count(Id) FROM Project__c WHERE Active__c = True];
        AggregateResult roles = [SELECT Count(Id) FROM Project_Role__c WHERE Project__r.Active__c = True];
        if (integer.valueof(activeProjects.get('expr0')) <=0 || integer.valueof(roles.get('expr0')) <=0)
          return;
          
        //  Populate rates and allowances map
        Map<String,RateandAllowance__c> rates = new Map<String,RateandAllowance__c>();
        List<RateandAllowance__c> tempRates = [SELECT Name, Amount_LE_EBA__c, Amount_ETU_EBA__c FROM RateandAllowance__c];
        for(RateandAllowance__c r :tempRates)
            rates.put (r.Name, r); 
        //  Populate staff profile map
        Map<String, Staff_Profile__c> staffProfiles = new Map<String, Staff_Profile__c>();
        List<Staff_Profile__c> tempProfiles = [SELECT Name, Staff_Name__c, Staff_Name__r.Name, Staff_Rate__c, Staff_Rate__r.Name, ETU_Core_Rate__c, LE_Core_Rate__c FROM Staff_Profile__c];
        for(Staff_Profile__c r :tempProfiles)
            staffProfiles.put (r.Name, r);
        
        //  Get Company, Project, Role, Staff records for all active projects
        //  Create a manning schedule for each month of project for each project role
        for(Project_Role__c r : [SELECT Project__r.Company__r.Name, 
                                 Project__r.Company__r.Annual_Leave_Days__c, Project__r.Company__r.Annual_Leave_Loading__c, 
                                 Project__r.Company__r.Long_Service__c, 
                                 Project__r.Company__r.Public_Holiday_Days__c, Project__r.Company__r.Sick_Leave_Days__c, 
                                 Project__r.Company__r.Superannuation__c, Project__r.Company__r.Training_Days__c,
                                 Project__r.Name, Project__r.Company__c, Project__r.Building_Height__r.Amount_LE_EBA__c, 
                                 Project__r.Building_Height__r.Amount_ETU_EBA__c, Project__r.CBD__c, 
                                 Project__r.End_Date__c, Project__r.Picnic_Day__c, Project__r.Income_Protection__c, 
                                 Project__r.Project_Size__r.Amount_ETU_EBA__c, Project__r.Project_Size__r.Amount_LE_EBA__c,
                                 Project__r.RDO_Cycle__c, Project__r.Redundancy__c, Project__r.Start_Date__c, 
                                 Project__r.Type__c, Project__r.Active__c, Project__r.Work_Days_Per_Week__c, assigned_to_project__c, 
                                 Staff__c, Name, Id, Supervisor__r.Name, Supervisor__r.Amount_ETU_EBA__c, Supervisor__r.Amount_LE_EBA__c, 
                                 Staff__r.Name, Staff__r.Staff_Type__c, Staff__r.Vehicle_Provide__c,    
                                 Staff__r.Staff_Type__r.Amount_ETU_EBA__c, Staff__r.Staff_Type__r.Amount_LE_EBA__c, Staff__r.Staff_Type__r.Name
                                 FROM Project_Role__c WHERE Project__r.Active__c = True AND Active__c = True]){

            decimal daysPerWeek = 5;  //  Saturday is overtime
            decimal weeksPerYear = 52;
            decimal hoursOrdinaryPerDay = decimal.valueof(r.Project__r.RDO_Cycle__c) / daysPerWeek;
            decimal hoursAnnualLeave = r.Project__r.Company__r.Annual_Leave_Days__c * hoursOrdinaryPerDay;
            decimal hoursPublicHolidays = r.Project__r.Company__r.Public_Holiday_Days__c * hoursOrdinaryPerDay;
            decimal hoursSickLeave = r.Project__r.Company__r.Sick_Leave_Days__c * hoursOrdinaryPerDay;
            decimal hoursPicnic = 0;
            decimal daysPicnic = 0;
            if(r.Project__r.Picnic_Day__c){
                hoursPicnic=hoursOrdinaryPerDay;
                daysPicnic = 1;
            }
            decimal hoursTraining = r.Project__r.Company__r.Training_Days__c * hoursOrdinaryPerDay;    
            decimal hoursPaidPerYear = hoursOrdinaryPerDay * daysPerWeek * weeksPerYear;
            decimal hoursBillablePerYear = hoursPaidPerYear - hoursPublicHolidays - hoursAnnualLeave - hoursSickLeave - hoursPicnic - hoursTraining;
//            decimal weeklyToHourly = 1/(daysPerWeek * hoursOrdinaryPerDay) * hoursPaidPerYear / hoursBillablePerYear;
            decimal weeklyToHourly = 1/(daysPerWeek * hoursOrdinaryPerDay);
//            decimal dailyToHourly = 1/hoursOrdinaryPerDay * hoursPaidPerYear / hoursBillablePerYear;
            decimal dailyToHourly = 1/hoursOrdinaryPerDay;
            decimal directCostsETU = 0;
            decimal directCostsLE = 0;
            decimal finalDirectCosts = 0;
            decimal onCostsETU = 0;
            decimal onCostsLE = 0;
            decimal debugETU=0;
            decimal debugLE=0;
                                     
            //  Get the base rate with allowances and on costs hourly rate for the staff member in the project role                        
            for (string theKey :staffProfiles.keySet()){
                if(staffProfiles.get(theKey).Staff_Name__r.Name == r.Staff__r.Name){ 
                    if(staffProfiles.get(theKey).Staff_Rate__r.Name == 'Hourly Rate with Allowances'){ 
                       directCostsETU = staffProfiles.get(theKey).ETU_Core_Rate__c;           
                       directCostsLE = staffProfiles.get(theKey).LE_Core_Rate__c;
                    } else if(staffProfiles.get(theKey).Staff_Rate__r.Name == 'Hourly Rate with On Costs'){ 
                       onCostsETU = staffProfiles.get(theKey).ETU_Core_Rate__c;           
                       onCostsLE = staffProfiles.get(theKey).LE_Core_Rate__c;
                    } 
                }
                if(debugOn){ 
                  System.debug('The profile costs: ' + staffProfiles.get(theKey).Staff_Name__r.Name + ' ' +
                               staffProfiles.get(theKey).ETU_Core_Rate__c + '   ' + staffProfiles.get(theKey).LE_Core_Rate__c);
                }
            }
            onCostsETU -=  directCostsETU;           
            onCostsLE -= directCostsLE;
            if(debugOn){ 
              debugETU = directCostsETU; debugLE = directCostsLE;
              System.debug('The value of direct costs: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
              debugETU = onCostsETU; debugLE = onCostsLE;
              System.debug('The value of on costs: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
            }    

           //  calculate the project based allowances for the project role and add to the direct costs
           //  supervisor allowance
           if(r.Supervisor__r.Name != null){
               directCostsETU += r.Supervisor__r.Amount_ETU_EBA__c * weeklyToHourly;
               directCostsLE += r.Supervisor__r.Amount_ETU_EBA__c * weeklyToHourly;
               if(debugOn){ 
                   debugETU = directCostsETU - debugETU; debugLE = directCostsLE - debugLE;
                   System.debug('The value of costs + Supervisor: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
               }    
            }

            // Height allowance (Hourly)
            directCostsETU += r.Project__r.Building_Height__r.Amount_ETU_EBA__c;
            directCostsLE += r.Project__r.Building_Height__r.Amount_LE_EBA__c;
            if(debugOn){
                debugETU = directCostsETU - debugETU; debugLE = directCostsLE - debugLE;
                System.debug('The value of costs + Height: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
            }
                                     
            // Size / Site (Hourly)
            directCostsETU += r.Project__r.Project_Size__r.Amount_ETU_EBA__c;
            directCostsLE += r.Project__r.Project_Size__r.Amount_LE_EBA__c;
            if(debugOn){ 
                debugETU = directCostsETU - debugETU; debugLE = directCostsLE - debugLE;
                System.debug('The value of costs + Site: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
            }

            //  Get the base rate with allowances and on costs for check box items                         
            for (string theKey :rates.keySet()){
                if(rates.get(theKey).Name == 'CBD'){ 
                    if(r.Project__r.CBD__c){ 
                        directCostsETU += rates.get(theKey).Amount_ETU_EBA__c;
                        directCostsLE += rates.get(theKey).Amount_LE_EBA__c;            
                        if(debugOn){ 
                            debugETU = directCostsETU - debugETU; debugLE = directCostsLE - debugLE;
                            System.debug('The value of CBD: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
                        }    
                    }
                } else if(rates.get(theKey).Name == 'Income Protection'){ 
                    if(r.Project__r.Income_Protection__c){ 
                        onCostsETU += rates.get(theKey).Amount_ETU_EBA__c * weeklyToHourly;
                        onCostsLE += rates.get(theKey).Amount_LE_EBA__c * weeklyToHourly;
                        if(debugOn){ 
                            debugETU = onCostsETU - debugETU; debugLE = onCostsLE - debugLE;
                            System.debug('The value of Income Protection: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
                        }    
                    } 
                } else if (rates.get(theKey).Name == 'Redundancy'){ 
                    if(r.Project__r.Redundancy__c){ 
                        onCostsETU += rates.get(theKey).Amount_ETU_EBA__c * weeklyToHourly;
                        onCostsLE += rates.get(theKey).Amount_LE_EBA__c * weeklyToHourly;
                        if(debugOn){ 
                            debugETU = onCostsETU - debugETU; debugLE = onCostsLE - debugLE;
                            System.debug('The value of Redundancy : ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
                        }    
                    } 
                }
            }
            List<RateandAllowance__c> rateAllowance = new list<RateandAllowance__c>();

            //  create list of manning schedules for costs for full month worked for the project role
            Manning_Schedule__c tempManningSchedules = new Manning_Schedule__c();
            tempManningSchedules.Project__c = r.Project__r.id;
            tempManningSchedules.Project_Role__c = r.Id;
            tempManningSchedules.Type__c = 'Role Month Total';
            tempManningSchedules.Staff__c = r.Staff__r.Id;
            tempManningSchedules.Hours__c = hoursBillablePerYear * decimal.valueof(r.assigned_to_project__c) / 100 / 12;
            if(r.Project__r.Type__c == 'LE'){
                tempManningSchedules.Direct_Costs__c = directCostsLE * tempManningSchedules.Hours__c;
                tempManningSchedules.On_Costs__c = onCostsLE * tempManningSchedules.Hours__c;
                tempManningSchedules.Overhead_Costs__c = onCostsLE * tempManningSchedules.Hours__c;
            } 
            else{
                tempManningSchedules.Direct_Costs__c = directCostsETU * tempManningSchedules.Hours__c;
                tempManningSchedules.On_Costs__c = onCostsETU * tempManningSchedules.Hours__c;
                tempManningSchedules.Overhead_Costs__c = onCostsETU * tempManningSchedules.Hours__c;
            }    
            roleManningSchedules.add(tempManningSchedules);

            //  reset variables                         
            onCostsETU = 0;
            directCostsETU = 0;           
            onCostsLE = 0;
            directCostsLE = 0;
        }

        //  Delete all existing manning schedules
        List<Manning_Schedule__c> toDel = new List<Manning_Schedule__c>();
        toDel = [select id from Manning_Schedule__c];
        delete toDel;

        //  enter all the monthly total manning schedules for each project role
        insert  roleManningSchedules;

        //     get project days off for each month for calculating actual hours for month
        Map<String, Project_Days_Off__c> projectDaysOff = new Map<String, Project_Days_Off__c>();
        for (Project_Days_Off__c tempDays :[SELECT Month__c, Mandatory_Annual_Leave__c, Public_Holiday__c, RDO_36__c, RDO_38__c, Picnic_Day__c FROM Project_Days_Off__c]){
          projectDaysOff.put(tempDays.Month__c,tempDays);
        }
        //    create project based manning schedule for each month 
        //    loop through each project
        for(Project__c p : [SELECT Name, Id, Start_Date__c, End_Date__c, RDO_Cycle__c, Picnic_Day__c                     
                            FROM Project__c WHERE Active__c = True]){
            
            //  Go through project and create temp manning schedule
            //  aggregate hours, Direct, On, Overhead costs for each project role into temp manning schedule
            Date thisMonthEnd = p.Start_Date__c.addMonths(1).toStartofMonth().addDays(-1);
            Date thisMonth = thisMonthEnd;
            for(integer i=0; i<=p.Start_Date__c.monthsBetween(p.End_Date__c);i++){
                //  reset thisMonthEnd last time through loop
                if (i == p.Start_Date__c.monthsBetween(p.End_Date__c))
                    thisMonthEnd = thisMonth;
                    
                //  get project totals for roles that are active and valid for the month
                AggregateResult tempSchedule = [SELECT Sum(Direct_Costs__c) DirectCosts, Sum(On_Costs__c) OnCosts, Sum(Hours__c) Hours, Count(Hours__c) Roles 
                         FROM Manning_Schedule__c WHERE Project__c = :p.Id AND Project_Role__r.Start_Date__c <= :thisMonth AND Project_Role__r.End_Date__c >= :thisMonthEnd];

                //  get days off for the month (.format only exists in DateTime)            
                DateTime tempDate = thisMonth;
                String monthString = tempDate.format('MMMM');
                Project_Days_Off__c thisprojectDaysOff = projectDaysOff.get(monthString);
                Decimal daysRDO = thisprojectDaysOff.RDO_38__c;
                Decimal daysPicnic = 0;
            
                if (p.RDO_Cycle__c == '36')
                    daysRDO = thisprojectDaysOff.RDO_38__c - thisprojectDaysOff.RDO_36__c;
                if (p.Picnic_Day__c)
                    daysPicnic = 1;
                Decimal monthDaysOff = daysRDO + daysPicnic + thisprojectDaysOff.Mandatory_Annual_Leave__c + thisprojectDaysOff.Public_Holiday__c;
                
                monthDaysOff = monthDaysOff * (decimal) tempSchedule.get('Roles');
                Decimal monthHoursOff = monthDaysOff * decimal.valueof(p.RDO_Cycle__c) / 5; 
            
                //  reset thisMonth first time through loop
                if (thisMonth == thisMonthEnd)
                    thisMonth = thisMonth.toStartofMonth();

                //  skip schedules where project roles not yet allocated
                if(Integer.valueOf(tempSchedule.get('Hours'))>0){
                    Manning_Schedule__c tempManningSchedules = new Manning_Schedule__c();
                    tempManningSchedules.Project__c = p.Id;
                    tempManningSchedules.Period__c = thisMonth;
                    tempManningSchedules.Type__c = 'Project Monthly Hours Total';
                    tempManningSchedules.Hours_Paid__c = Integer.valueOf(tempSchedule.get('Hours'));
                    tempManningSchedules.Hours__c = Integer.valueOf(tempSchedule.get('Hours')) - (integer)monthHoursOff;
                    tempManningSchedules.Direct_Costs__c = (decimal) tempSchedule.get('DirectCosts');
                    tempManningSchedules.On_Costs__c = (decimal) tempSchedule.get('OnCosts');
                    projectManningSchedules.add(tempManningSchedules);
                }
                
                thisMonth = thisMonth.addMonths(1).toStartofMonth();
                thisMonthEnd = thisMonthEnd.addMonths(2).toStartofMonth().addDays(-1);
//                if(debugOn)
//                    System.debug('Period : ' + thisMonth + '     ' + monthHoursOff + '  -   ' + tempSchedule.get('DirectCosts') + '   -  ' + ((decimal) tempSchedule.get('DirectCosts')/(decimal)tempSchedule.get('Hours') * ((decimal)tempSchedule.get('Hours') - (decimal)monthHoursOff)));

            }
        }

        //  Insert manning schedule
        insert  projectManningSchedules;

        //  For each period/project manning schedule create overhead costs
        decimal totalOverheads = [SELECT Annual_Overhead_Amount__c FROM Staff_Cost_Constants__c].Annual_Overhead_Amount__c;
        for (AggregateResult ar : [SELECT Sum(Direct_Costs__c) DirectCosts, Sum(On_Costs__c) OnCosts, Sum(Hours__c) Hours, Period__c Period
                                  FROM Manning_Schedule__c GROUP BY Period__c]){
            decimal periodOverheads = totalOverheads / 12 / (decimal) ar.get('Hours');
            if(debugOn) { 
                System.debug(ar.get('DirectCosts')+'-'+ar.get('OnCosts')+'-'+ar.get('Hours')+'-'+ar.get('Period'));
                System.debug(periodOverheads+'-');
            }                          
            for (Manning_Schedule__c pms: [SELECT Project__c, Hours__c 
                                           FROM Manning_Schedule__c WHERE Period__c = :(date)ar.get('Period')]){
               pms.Overhead_Costs__c = pms.Hours__c * periodOverheads;
               update pms;
            }
        }
    }
}