@IsTest
private class UserAdoptionBatchTest {
    private static String CRON_EXP {
        get {
            Datetime start = Datetime.now().addMinutes(10);
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now()..minute());
            String ss = String.valueOf(Datetime.now().second());

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
