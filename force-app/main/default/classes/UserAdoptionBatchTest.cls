@IsTest
private class UserAdoptionBatchTest {
    private static String CRON_EXP {
        get {
            Datetime start = Datetime.now().addMinutes(10);
            String hour = String.valueOf(start.hour());
            String min = String.valueOf(start..minute());
            String ss = String.valueOf(start.second());

            //parse to cron expression
            return ss + ' ' + min + ' ' + hour + ' * * ?';
        }
        private set {
        }
    }

    @TestSetup
    static void makeData() {
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
