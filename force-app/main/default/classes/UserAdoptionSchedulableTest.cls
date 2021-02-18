@IsTest
private class UserAdoptionSchedulableTest {
    private static String CRON_EXP = '0 0 0 3 9 ? 2022';

    @IsTest
    private static void execute() {
        Test.startTest();
        String jobId = System.schedule('UserAdoptionSchedulable', CRON_EXP, new UserAdoptionSchedulable());
        Test.stopTest();
        System.assert(jobId != null);
        List<ReportingData__c> reportingData = [SELECT Id FROM ReportingData__c];
    }
}
