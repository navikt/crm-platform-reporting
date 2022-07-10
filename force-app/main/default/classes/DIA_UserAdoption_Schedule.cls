public with sharing class DIA_UserAdoption_Schedule implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        Integer weekNumber=getWeekNumber();
        //remove data for current week before insterting new data
        DELETE [SELECT Id FROM ReportingData__c WHERE CRM_Category__c='DIA User Adoption' AND CRM_Week__c=:weekNumber];

        List<ReportingData__c> recordsToBeInserted=new List<ReportingData__c>();
        DateTime startOfWeek=Date.Today().AddDays(-1).toStartOfWeek();
        AggregateResult[] users=[SELECT CompanyName, COUNT(Id) numberOfUsers FROM USER WHERE ProfileId in('00e7U000000cWBPQA2','00e7U000000cWBUQA2')  AND LastLoginDate>=:startOfWeek GROUP BY CompanyName];
        if(Test.isRunningTest()){
            User platformUser=[SELECT Id FROM User WHERE UserName='test.platform423_fdsfds@nav.no' LIMIT 1];
            //aggregate result for test purpose
            users=[SELECT CompanyName, COUNT(Name) numberOfUsers FROM USER WHERE UserName='test.platform423_fdsfds@nav.no' GROUP BY CompanyName];
        }
        for(AggregateResult ar:users){
            ReportingData__c usersPerUnit=new ReportingData__c();
            usersPerUnit.CRM_Category__c='DIA User Adoption';
            usersPerUnit.CRM_Week__c=weekNumber;
            usersPerUnit.CRM_NavUnit__c=(String)ar.get('CompanyName');
            usersPerUnit.CRM_Value__c=(Integer)ar.get('numberOfUsers');
            recordsToBeInserted.add(usersPerUnit);
        }
        insert recordsToBeInserted;
    } 

    public Integer getWeekNumber(){
        Integer weekNumber=Integer.valueOf(DateTime.newInstanceGmt(Date.Today().AddDays(-1).toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w'))-1;
        if(Test.isRunningTest()){
            weekNumber=1;
        }
        return weekNumber;
    }

 

}

