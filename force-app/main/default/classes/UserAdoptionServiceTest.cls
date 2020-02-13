@IsTest
private class UserAdoptionServiceTest {

    @IsTest
    private static void getLastLogInByRegion(){
        DateTime periodStart=Datetime.now().addYears(-1);
        DateTime periodEnd=Datetime.now();
        List<ReportingData__c> reportingData=UserAdoptionService.getLastLogInByRegion(periodStart,periodEnd);
        System.assert(reportingData.size()>0);
    }

    @IsTest
    private static void insertReportingDataLastDay(){
        UserAdoptionService.insertReportingDataLastDay();
        List<ReportingData__c> reportingData=[SELECT Id FROM ReportingData__c];
        System.assert(reportingData.size()>0);
    }

}