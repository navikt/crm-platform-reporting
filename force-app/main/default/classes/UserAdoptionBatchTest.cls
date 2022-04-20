@IsTest
private class UserAdoptionBatchTest {
    private static String CRON_EXP = '0 0 0 3 9 ? 2022';

    @TestSetup
    static void makeData(){
        List<User> users = TestDataFactory.getUsers(10, 'System Administrator', true, true);
    }

    @isTest
    private static void testUserAdoptionBatch() {
                
        Test.startTest();
        String jobId = System.schedule('UserAdoptionBatch', CRON_EXP, new UserAdoptionBatch());
        Test.stopTest();

        System.assert(jobId != null, 'Job was not successfully created.');
    }
}
