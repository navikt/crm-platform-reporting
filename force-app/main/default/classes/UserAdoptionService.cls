public with sharing class UserAdoptionService {

    public static void insertReportingDataLastDay() {
        Date yesterday = Date.today().addDays(-1);
        Time startTime = Time.newInstance(0, 0, 0, 0);
        Time endTime = Time.newInstance(23, 59, 59, 59);



        DateTime periodStart = Datetime.newInstance(yesterday, startTime);
        DateTime periodEnd = Datetime.newInstance(yesterday, endTime);

        if(Test.isRunningTest()){
            //scratch org will not necessarily have logins the day before
            periodEnd=Datetime.now();
        }

        List<ReportingData__c> reportingData = getLastLogInByRegion(periodStart, periodEnd);
        insert reportingData;
    }

    @TestVisible
    private static List<ReportingData__c> getLastLogInByRegion(DateTime periodStart, DateTime periodEnd) {

        AggregateResult[] usersByRegion = [
                SELECT Region__c, COUNT(ID) Logins
                FROM User
                WHERE LastLoginDate >= :periodStart AND LastLoginDate <= :periodEnd
                GROUP BY Region__c
        ];

        List<ReportingData__c> reportingData = new List<ReportingData__c>();
        for (AggregateResult ar : usersByRegion) {
            reportingData.add(new ReportingData__c(
                    Name = 'Pålogging',
                    CRM_Region__c = (String) ar.get('Region__c'),
                    CRM_Value__c = (Integer) ar.get('Logins'),
                    CRM_Date__c = periodStart.date(),
                    CRM_Category__c = 'User Adoption'
            ));
        }
        return reportingData;
    }


}