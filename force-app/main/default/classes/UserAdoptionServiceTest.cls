@IsTest
private class UserAdoptionServiceTest {

    @IsTest
    private static void getLastLogInByRegion(){
        DateTime periodStart=Datetime.now().addYears(-1);
        List<ReportingData__c> reportingData=UserAdoptionService.getLastLogInByRegion(periodStart);
        System.assert(reportingData.size()>0);
    }

    @IsTest
    private static void insertReportingDataLastDay(){
        UserAdoptionService.insertReportingDataLastWeek();
        List<ReportingData__c> reportingData=[SELECT Id FROM ReportingData__c];
        System.assert(reportingData.size()>0);
    }

}