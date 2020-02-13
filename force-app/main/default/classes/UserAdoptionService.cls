public with sharing class UserAdoptionService {

    public static void insertReportingDataLastWeek() {

        DateTime periodStart =DateTime.now().addDays(-7);


        List<ReportingData__c> reportingData = getLastLogInByRegion(periodStart);
        insert reportingData;
    }

    @TestVisible
    private static List<ReportingData__c> getLastLogInByRegion(DateTime periodStart) {

        AggregateResult[] usersByRegion = [
                SELECT Region__c, COUNT(ID) Logins
                FROM User
                WHERE LastLoginDate >= :periodStart
                GROUP BY Region__c
        ];

        List<ReportingData__c> reportingData = new List<ReportingData__c>();
        for (AggregateResult ar : usersByRegion) {
            reportingData.add(new ReportingData__c(
                    Name = 'Pålogging',
                    CRM_Region__c = (String) ar.get('Region__c'),
                    CRM_Value__c = (Integer) ar.get('Logins'),
                    CRM_Date__c =Date.today().addDays(-1),
                    CRM_Category__c = 'User Adoption'
            ));
        }
        return reportingData;
    }


}