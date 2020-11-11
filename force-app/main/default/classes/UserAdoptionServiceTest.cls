@IsTest
private class UserAdoptionServiceTest {

    @IsTest
    private static void getLastLogInByUnit(){
        DateTime periodStart=Datetime.now().addYears(-1);
        List<ReportingData__c> reportingData=UserAdoptionService.getLastLogInByUnit(periodStart, Date.today());
    }

    @IsTest
    private static void getNewUsers(){
        User currentUser=[SELECT CreatedDate FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        DateTime createdDate = currentUser.CreatedDate;
        Date reportDate=Date.newInstance(createdDate.year(), createdDate.month(), createdDate.day());
        List<ReportingData__c> reportingData=UserAdoptionService.getNewUSers(reportDate);
        System.assert(reportingData.size()>0);
    }

    @IsTest
    private static void insertReportingData(){
        UserAdoptionService.insertReportingData(Date.today());
        List<ReportingData__c> reportingData=[SELECT Id FROM ReportingData__c];
        System.assert(reportingData.size()>0);
    }

}