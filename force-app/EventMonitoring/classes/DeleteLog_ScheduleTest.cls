@IsTest
private class DeleteLog_ScheduleTest {
    
    @TestSetup
    static void makeData(){
        List<Log__c> logs=new List<Log__c>();
        logs.add(Reporting_TestDataFactory.getLog('0010E00000pmCdkQAE','Account'));
        logs.add(Reporting_TestDataFactory.getLog('0010E00000pmCdkQAb','Account'));
        logs[0].CRM_Status__c='Not completed';
        insert logs;
    }

    @IsTest
	private static void testBatchExecute() {
		Test.startTest();
		DeleteLog_Schedule btch = new DeleteLog_Schedule();
		Database.executeBatch( btch, 2000 );
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Log__c], '1 Log left');
	}
    
    @IsTest
	private static void testScheduleExecute() {
		Test.startTest();
		DeleteLog_Schedule scheduleClass = new DeleteLog_Schedule();
		String chron = '0 0 23 * * ?';
		System.schedule( 'Delte logs', chron, scheduleClass );
		Test.stopTest();
		System.assertEquals(1,[SELECT count() FROM CronTrigger], '1 job should be scheduled' );
	}
}
