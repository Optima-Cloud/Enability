public class am_StaffProfiles {  
  /*
   *  Written by:  David Strangward
   *  Date:  4/8/2016
   *  Modified by:
   *  Date Modified:
   *
   *  Description:  Updates the staff profile hourly rates
   *                
   */
    
    public static void updateProfileRates(){
//      if(checkRecursive.runOnce()){
    //  update staff profiles when a staff record is inserted or updated
        //  update staff profiles when a rate or allowance is updated
        //  Cycle through each Staff record and update each profile record 
        //  updates totals, deletes all  
        //  summary records and recalculates and inserts new ones
        
        Decimal baseTotal_ETU = 0;
        Decimal baseTotal_LE = 0;
        Decimal actualTotal_ETU = 0;
        Decimal actualTotal_LE = 0;
        Decimal allowanceTotal_ETU = 0;
        Decimal allowanceTotal_LE = 0;
        Decimal allowanceCore_ETU = 0;
        Decimal allowanceCore_LE = 0; 
        Decimal onCostsTotal_ETU = 0;
        Decimal onCostsTotal_LE = 0;
        Decimal onCostsCoreTotal_ETU = 0;
        Decimal onCostsCoreTotal_LE = 0;
        Decimal leaveLoading_ETU = 0; 
        Decimal leaveLoading_LE = 0;
        Decimal leaveLoadingCore_ETU = 0; 
        Decimal leaveLoadingCore_LE = 0;
        Decimal super_ETU = 0; 
        Decimal super_LE = 0;
        Decimal longService_ETU = 0; 
        Decimal longService_LE = 0;
        
        Boolean debugON = false;

        decimal daysPerWeek = 5;  //  Saturday is overtime
        decimal weeksPerYear = 52;
        decimal hoursOrdinaryPerDayLE = 38 / daysPerWeek;
        decimal hoursOrdinaryPerDayETU = 36 / daysPerWeek;

        Staff_Profile__c[]        annualStaffProfiles = new List<Staff_Profile__c>();

        Staff_Cost_Constants__c   staffConstants =  [SELECT Weeks_Per_Year__c, Working_Hours_Per_Year__c, Hours_Per_Day__c, Superannuation__c, Long_Service__c, 
                                                     Annual_Leave_Loading__c, Annual_Leave_Days__c, Public_Holiday_Days__c, Sick_Leave_Days__c, Training_Days__c, Trade_School_Days__c  
                                                     FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];
        decimal hoursAnnualLeaveLE = staffConstants.Annual_Leave_Days__c * hoursOrdinaryPerDayLE;
        decimal hoursAnnualLeaveETU = staffConstants.Annual_Leave_Days__c * hoursOrdinaryPerDayETU;
        decimal hoursPublicHolidaysLE = staffConstants.Public_Holiday_Days__c * hoursOrdinaryPerDayLE;
        decimal hoursPublicHolidaysETU = staffConstants.Public_Holiday_Days__c * hoursOrdinaryPerDayETU;
        decimal hoursSickLeaveLE = staffConstants.Sick_Leave_Days__c * hoursOrdinaryPerDayLE;
        decimal hoursSickLeaveETU = staffConstants.Sick_Leave_Days__c * hoursOrdinaryPerDayETU;
        decimal hoursTrainingLE = staffConstants.Training_Days__c * hoursOrdinaryPerDayLE;    
        decimal hoursTrainingETU = staffConstants.Training_Days__c * hoursOrdinaryPerDayETU;    
        decimal hoursTradeSchoolLE = staffConstants.Trade_School_Days__c * hoursOrdinaryPerDayLE;    
        decimal hoursTradeSchoolETU = staffConstants.Trade_School_Days__c * hoursOrdinaryPerDayETU;    
        decimal hoursPaidPerYearLE = hoursOrdinaryPerDayLE * daysPerWeek * weeksPerYear;
        decimal hoursPaidPerYearETU = hoursOrdinaryPerDayETU * daysPerWeek * weeksPerYear;
        decimal hoursBillablePerYearLE = hoursPaidPerYearLE - hoursPublicHolidaysLE - hoursAnnualLeaveLE - hoursSickLeaveLE - hoursTrainingLE;
        decimal hoursBillablePerYearETU = hoursPaidPerYearETU - hoursPublicHolidaysETU - hoursAnnualLeaveETU - hoursSickLeaveETU - hoursTrainingETU;
        decimal hoursBillablePerYearAppLE = hoursPaidPerYearLE - hoursPublicHolidaysLE - hoursAnnualLeaveLE - hoursSickLeaveLE - hoursTrainingLE - hoursTradeSchoolLE;
        decimal hoursBillablePerYearAppETU = hoursPaidPerYearETU - hoursPublicHolidaysETU - hoursAnnualLeaveETU - hoursSickLeaveETU - hoursTrainingETU - hoursTradeSchoolETU;
        decimal hoursCorePerYearLE = hoursPaidPerYearLE;
        decimal hoursCorePerYearETU = hoursPaidPerYearETU;
        decimal weeklyToHourlyLE = 1/(daysPerWeek * hoursOrdinaryPerDayLE) * hoursPaidPerYearLE / hoursBillablePerYearLE;
        decimal weeklyToHourlyETU = 1/(daysPerWeek * hoursOrdinaryPerDayETU) * hoursPaidPerYearETU / hoursBillablePerYearETU;
        decimal dailyToHourlyLE = 1/hoursOrdinaryPerDayLE * hoursPaidPerYearLE / hoursBillablePerYearLE;
        decimal dailyToHourlyETU = 1/hoursOrdinaryPerDayETU * hoursPaidPerYearETU / hoursBillablePerYearETU;
        decimal debugETU;
        decimal debugLE=1;
       
        //  Populate rate map
        Map<String,RateandAllowance__c> rates = new Map<String,RateandAllowance__c>();
        RateandAllowance__c[] tempRates = [SELECT Name, Amount_LE_EBA__c, Amount_ETU_EBA__c FROM RateandAllowance__c];
        for(RateandAllowance__c r :tempRates)
            rates.put (r.Name, r);
        
        //  cycle through all staff records
        Staff__c[]  allStaffRecords = [Select Name, Id, Staff_Type__c, Vehicle_Provide__c From Staff__c];
        for(Staff__c s :allStaffRecords){
          RateandAllowance__c       relatedRate;
          String                   thisStaffType;
            
          //  Calculate base hourly rate record
            for (string theKey :rates.keySet()){
                if(rates.get(theKey).id == s.Staff_Type__c){ 
                    thisStaffType = rates.get(theKey).Name;
                    if (thisStaffType == 'Electrician A Grade' || thisStaffType == 'Electrician B Grade'){
                        actualTotal_ETU = rates.get(theKey).Amount_ETU_EBA__c  * hoursPaidPerYearLE / hoursBillablePerYearETU;           
                        actualTotal_LE = rates.get(theKey).Amount_LE_EBA__c  * hoursPaidPerYearETU / hoursBillablePerYearLE;
                        baseTotal_ETU = rates.get(theKey).Amount_ETU_EBA__c;           
                        baseTotal_LE = rates.get(theKey).Amount_LE_EBA__c;
                    } else {
                        actualTotal_ETU = rates.get(theKey).Amount_ETU_EBA__c  * hoursPaidPerYearLE / hoursBillablePerYearAppETU;           
                        actualTotal_LE = rates.get(theKey).Amount_LE_EBA__c  * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                        baseTotal_ETU = rates.get(theKey).Amount_ETU_EBA__c;           
                        baseTotal_LE = rates.get(theKey).Amount_LE_EBA__c;
                    }
                }
            }
                
            // determine correct travel daily allowance amount 
            if (thisStaffType == 'Apprentice Year 1' || thisStaffType == 'Apprentice Mature Year 1'){
                allowanceTotal_ETU = rates.get('Travel Apprentice Year 1').Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE = rates.get('Travel Apprentice Year 1').Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU = rates.get('Travel Apprentice Year 1').Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE = rates.get('Travel Apprentice Year 1').Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            } else if (thisStaffType == 'Apprentice Year 2' || thisStaffType == 'Apprentice Mature Year 2'){
                allowanceTotal_ETU = rates.get('Travel Apprentice Year 2').Amount_ETU_EBA__c  * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE = rates.get('Travel Apprentice Year 2').Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU = rates.get('Travel Apprentice Year 2').Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE = rates.get('Travel Apprentice Year 2').Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            } else if (thisStaffType == 'Apprentice Year 3' || thisStaffType == 'Apprentice Mature Year 3'){
                allowanceTotal_ETU = rates.get('Travel Apprentice Year 3').Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE = rates.get('Travel Apprentice Year 3').Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU = rates.get('Travel Apprentice Year 3').Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE = rates.get('Travel Apprentice Year 3').Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            } else if (thisStaffType == 'Apprentice Year 4' || thisStaffType == 'Apprentice Mature Year 4'){
                allowanceTotal_ETU = rates.get('Travel Apprentice Year 4').Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE = rates.get('Travel Apprentice Year 4').Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU = rates.get('Travel Apprentice Year 4').Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE = rates.get('Travel Apprentice Year 4').Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            } else if (thisStaffType == 'Electrician A Grade' || thisStaffType == 'Electrician B Grade'){
                allowanceTotal_ETU = rates.get('Electrician A Grade').Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE = rates.get('Electrician A Grade').Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU = rates.get('Electrician A Grade').Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE = rates.get('Electrician A Grade').Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            }    
            
            //  determine correct fares daily allowance
            if (s.Vehicle_Provide__c == true)
                relatedRate = rates.get('Fares Vehicle Provided');
            else
                relatedRate = rates.get('Fares Own Vehicle');           
            if (thisStaffType == 'Electrician A Grade' || thisStaffType == 'Electrician B Grade'){
                allowanceTotal_ETU += relatedRate.Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearETU;
                allowanceTotal_LE += relatedRate.Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearLE;
                allowanceCore_ETU += relatedRate.Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE += relatedRate.Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            } else {
                allowanceTotal_ETU += relatedRate.Amount_ETU_EBA__c * dailyToHourlyETU * hoursPaidPerYearLE / hoursBillablePerYearAppETU;
                allowanceTotal_LE += relatedRate.Amount_LE_EBA__c * dailyToHourlyLE * hoursPaidPerYearETU / hoursBillablePerYearAppLE;
                allowanceCore_ETU += relatedRate.Amount_ETU_EBA__c / hoursOrdinaryPerDayETU;
                allowanceCore_LE += relatedRate.Amount_LE_EBA__c / hoursOrdinaryPerDayLE;
            }
                debugETU = leaveLoading_ETU; debugLE = leaveLoading_LE;
                if (debugON)
                  System.debug('The value of Fares Own Vehicle: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
                
            //  determine leave loading amount 
            if (thisStaffType == 'Electrician A Grade' || thisStaffType == 'Electrician B Grade'){
                leaveLoading_LE = baseTotal_LE * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveLE / hoursBillablePerYearLE;
                leaveLoading_ETU = baseTotal_ETU * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursBillablePerYearETU;
                leaveLoadingCore_LE = baseTotal_LE * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursPaidPerYearLE;
                leaveLoadingCore_ETU = baseTotal_ETU * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursPaidPerYearETU;
            } else {
                leaveLoading_LE = baseTotal_LE * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveLE / hoursBillablePerYearAppLE;
                leaveLoading_ETU = baseTotal_ETU * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursBillablePerYearAppETU;
                leaveLoadingCore_LE = baseTotal_LE * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursPaidPerYearLE;
                leaveLoadingCore_ETU = baseTotal_ETU * (1 + staffConstants.Annual_Leave_Loading__c / 100) * hoursAnnualLeaveETU / hoursPaidPerYearETU;
            }
                debugETU = leaveLoading_ETU; debugLE = leaveLoading_LE;
                if (debugON)
                  System.debug('The value of Annual Leave Loading: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
           
            //  determine superannuation amount 
            super_ETU = (baseTotal_ETU + allowanceTotal_ETU) * staffConstants.Superannuation__c / 100; 
            super_LE = (baseTotal_LE + allowanceTotal_LE) * staffConstants.Superannuation__c / 100;
            debugETU = super_ETU; debugLE = super_LE;
            if (debugON)
              System.debug('The value of superannuation: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
            
            //  determine long service amount 
            //  does not apply to apprentices
            if (thisStaffType.left(10) <> 'Apprentice'){
                longService_ETU = baseTotal_ETU * staffConstants.Long_Service__c / 100; 
                longService_LE =  baseTotal_LE * staffConstants.Long_Service__c / 100;
                debugETU = longService_ETU; debugLE = longService_LE;
                if (debugON)
                  System.debug('The value of long service: ' + debugETU.setScale(2) + '   ' + debugLE.setScale(2));
            } else {
                longService_ETU = 0; 
                longService_LE =  0;
            }
            
            onCostsTotal_ETU = leaveLoading_ETU + super_ETU + longService_ETU;
            onCostsTotal_LE = leaveLoading_LE + super_LE + longService_LE;
            onCostsCoreTotal_ETU = leaveLoadingCore_ETU + super_ETU + longService_ETU;
            onCostsCoreTotal_LE = leaveLoadingCore_LE + super_LE + longService_LE;
            
            //  Insert hourly base record 
            Staff_Profile__c a = new Staff_Profile__c(ETU_EBA_Amount__c = actualTotal_ETU, 
                                                      LE_EBA_Amount__c = actualTotal_LE,
                                                      ETU_Core_Rate__c = baseTotal_ETU,
                                                      LE_Core_Rate__c = baseTotal_LE,
                                                      Staff_Name__c = s.Id, 
                                                      Staff_Rate__c = rates.get('Hourly Rate Base').Id);       
            annualStaffProfiles.add(a);
            
            //  Insert hourly base + allowance record 
            a = new Staff_Profile__c(ETU_EBA_Amount__c = (actualTotal_ETU + allowanceTotal_ETU), 
                                     LE_EBA_Amount__c = (actualTotal_LE + allowanceTotal_LE), 
                                     ETU_Core_Rate__c = (baseTotal_ETU + allowanceCore_ETU),
                                     LE_Core_Rate__c = (baseTotal_LE + allowanceCore_LE),
                                     Staff_Name__c = s.Id, 
                                     Staff_Rate__c = rates.get('Hourly Rate with Allowances').id);       
            annualStaffProfiles.add(a);
            
            //  Insert hourly base + allowance record + on costs
            a = new Staff_Profile__c(ETU_EBA_Amount__c = (actualTotal_ETU + allowanceTotal_ETU + onCostsTotal_ETU), 
                                     LE_EBA_Amount__c = (actualTotal_LE + allowanceTotal_LE + onCostsTotal_LE), 
                                     ETU_Core_Rate__c = (baseTotal_ETU + allowanceCore_ETU + onCostsCoreTotal_ETU),
                                     LE_Core_Rate__c = (baseTotal_LE + allowanceCore_LE + onCostsCoreTotal_LE),                                     Staff_Name__c = s.Id, 
                                     Staff_Rate__c = rates.get('Hourly Rate with On Costs').id);       
            annualStaffProfiles.add(a);
            
        }
        delete [SELECT Id FROM Staff_Profile__c where Staff_Rate__c = :rates.get('Hourly Rate Base').id];
        delete [SELECT Id FROM Staff_Profile__c where Staff_Rate__c = :rates.get('Hourly Rate with Allowances').id];
        delete [SELECT Id FROM Staff_Profile__c where Staff_Rate__c = :rates.get('Hourly Rate with On Costs').id];
        
        insert  annualStaffProfiles;
    }
//    }
}