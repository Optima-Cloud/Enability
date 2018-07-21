trigger Update_Profile on Staff_Profile__c (before update, before insert) {
    //  takes the profile that is passed and updates totals, deletes all oncost records and 
    //  summary records and recalculates and inserts new ones
    Decimal SuperGuaranteeTotal_ETU = 0;
    Decimal SuperGuaranteeTotal_LE = 0;
    Decimal baseTotal_ETU = 0;
    Decimal baseTotal_LE = 0;
    Decimal allowanceTotal_ETU = 0;
    Decimal allowanceTotal_LE = 0;
    Decimal onCostsTotal_ETU = 0;
    Decimal onCostsTotal_LE = 0;
    Decimal overheadTotal_ETU = 0;
    Decimal overheadTotal_LE = 0;
    
    Staff_Cost_Constants__c   staffConstants =  [SELECT Weeks_Per_Year__c, Working_Hours_Per_Year__c, Hours_Per_Day__c, Superannuation__c, Long_Service__c, Annual_Leave_Loading__c  FROM Staff_Cost_Constants__c WHERE Name = 'Living Electrics'];
    RateandAllowance__c       relatedRate = [SELECT Name, Type__c, Frequency__c, Amount_LE_EBA__c, Amount_ETU_EBA__c FROM RateandAllowance__c WHERE Id = :Trigger.New[0].Staff_Rate__c];

    Staff_Profile__c          newStaffProfile = new Staff_Profile__c();
    Staff_Profile__c[]        annualStaffProfiles = new List<Staff_Profile__c>();
    Staff_Profile__c[]        allStaffProfiles =  [SELECT Name, Staff_Rate__c, ETU_EBA_Amount__c, LE_EBA_Amount__c  FROM Staff_Profile__c WHERE Staff_Name__c = : Trigger.New[0].Staff_Name__c];
    RateandAllowance__c       superRate = [SELECT id FROM RateandAllowance__c WHERE Name = 'Superannuation'];

    //  update Base and Allowances to annual
    if (relatedRate.Type__c == '1. Base Rate' || relatedRate.Type__c == '2. Allowances') {    
        //  Update Base and Allowances to annual figures
        for(Staff_Profile__c t :Trigger.New){
            if (relatedRate.Type__c == '1. Base Rate' || relatedRate.Type__c == '2. Allowances') {
                if( relatedRate.Frequency__c == 'Hourly'){
                   t.ETU_EBA_Amount__c = relatedRate.Amount_ETU_EBA__c * staffConstants.Hours_Per_Day__c * 5 * 52;
                   t.LE_EBA_Amount__c = relatedRate.Amount_LE_EBA__c * staffConstants.Hours_Per_Day__c * 5 * 52;
                }     
                else if (relatedRate.Frequency__c == 'Daily'){
                   t.ETU_EBA_Amount__c = relatedRate.Amount_ETU_EBA__c  * 5 * staffConstants.Weeks_Per_Year__c;
                   t.LE_EBA_Amount__c = relatedRate.Amount_LE_EBA__c  * 5 * staffConstants.Weeks_Per_Year__c;
                }
                else if (relatedRate.Frequency__c == 'Weekly'){
                   t.ETU_EBA_Amount__c = relatedRate.Amount_ETU_EBA__c * staffConstants.Weeks_Per_Year__c;
                   t.LE_EBA_Amount__c = relatedRate.Amount_LE_EBA__c * staffConstants.Weeks_Per_Year__c;
                }
            }
        }

        //  Calculate Summary based fields
        for(Staff_Profile__c s :allStaffProfiles){
            if ([SELECT Type__c FROM RateandAllowance__c WHERE Id = :s.Staff_Rate__c].Type__c == '1. Base Rate'){
                baseTotal_LE += s.LE_EBA_Amount__c;
                baseTotal_ETU += s.ETU_EBA_Amount__c;
            } else if ([SELECT Type__c FROM RateandAllowance__c WHERE Id = :s.Staff_Rate__c].Type__c == '2. Allowances') {
                allowanceTotal_ETU += s.ETU_EBA_Amount__c;
                allowanceTotal_LE += s.LE_EBA_Amount__c;
            } else {
                onCostsTotal_ETU += s.ETU_EBA_Amount__c;
                onCostsTotal_LE += s.LE_EBA_Amount__c;
                // delete all the oncost records
                delete s;
            }     
        }

       //  Insert leave loading record 
       Staff_Profile__c a = new Staff_Profile__c(ETU_EBA_Amount__c = baseTotal_ETU * staffConstants.Annual_Leave_Loading__c / 100 / 52 * 4, 
                                                 LE_EBA_Amount__c = baseTotal_LE * staffConstants.Annual_Leave_Loading__c / 100 / 52 * 4, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Annual Leave Loading'].id);
       annualStaffProfiles.add(a);

       //  Insert superannuation record 
       Staff_Profile__c b = new Staff_Profile__c(ETU_EBA_Amount__c = (baseTotal_ETU + allowanceTotal_ETU) * staffConstants.Superannuation__c / 100, 
                                                 LE_EBA_Amount__c = (baseTotal_LE + allowanceTotal_LE) * staffConstants.Superannuation__c / 100, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Superannuation'].id);
       annualStaffProfiles.add(b);


       //  Insert long service record 
       Staff_Profile__c c = new Staff_Profile__c(ETU_EBA_Amount__c = baseTotal_ETU * staffConstants.Long_Service__c / 100, 
                                                 LE_EBA_Amount__c = baseTotal_LE * staffConstants.Long_Service__c / 100, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Long Service Leave'].id);
       annualStaffProfiles.add(c);

        //  Insert hourly base record 
       Staff_Profile__c d = new Staff_Profile__c(ETU_EBA_Amount__c = baseTotal_ETU / staffConstants.Working_Hours_Per_Year__c, 
                                                 LE_EBA_Amount__c = baseTotal_LE / staffConstants.Working_Hours_Per_Year__c, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Hourly Rate Base'].id);       
       annualStaffProfiles.add(d);

        //  Insert hourly base + allowance record 
       Staff_Profile__c e = new Staff_Profile__c(ETU_EBA_Amount__c = (baseTotal_ETU + allowanceTotal_ETU) / staffConstants.Working_Hours_Per_Year__c, 
                                                 LE_EBA_Amount__c = (baseTotal_LE + allowanceTotal_LE) / staffConstants.Working_Hours_Per_Year__c, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Hourly Rate with Allowances'].id);       
       annualStaffProfiles.add(e);

        //  Insert hourly base + allowance record + on costs
       Staff_Profile__c f = new Staff_Profile__c(ETU_EBA_Amount__c = (baseTotal_ETU + allowanceTotal_ETU + onCostsTotal_ETU) / staffConstants.Working_Hours_Per_Year__c, 
                                                 LE_EBA_Amount__c = (baseTotal_LE + allowanceTotal_LE + onCostsTotal_LE) / staffConstants.Working_Hours_Per_Year__c, 
                                                 Staff_Name__c = Trigger.New[0].Staff_Name__c, 
                                                 Staff_Rate__c = [SELECT id FROM RateandAllowance__c WHERE Name = 'Hourly Rate with On Costs'].id);       
       annualStaffProfiles.add(f);


//       insert  annualStaffProfiles;
    }
}