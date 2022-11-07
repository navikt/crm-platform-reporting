@IsTest
private class UserAdoptionBatchTest {
    @TestSetup
    static void makeData(){
        List<User> users = TestDataFactory.getUsers(10, 'System Administrator', true, true);
    }

    @isTest
    private static void testUserAdoptionBatch() {
                
        Test.startTest();
        new UserAdoptionBatch().execute(null);
        Test.stopTest();

        System.assert(jobId != null, 'Job was not successfully created.');
    }
}
