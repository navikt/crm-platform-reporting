@IsTest
private class EventMonitoringLog_ScheduleTest {

    @TestSetup
    static void makeData(){
        Log__c log=Reporting_TestDataFactory.getLog('0010E00000pmCdkQAE','Account');
        insert log;

    }

    @IsTest
	private static void testBatchExecute() {
		Test.startTest();
		EventMonitoringLog_Schedule btch = new EventMonitoringLog_Schedule();
		Database.executeBatch( btch, 2000 );
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Log__c WHERE CRM_Status__c='Not completed'], 'Log is not processed due to missing person ident');
	}
    
    @IsTest
	private static void testScheduleExecute() {
		Test.startTest();
		EventMonitoringLog_Schedule scheduleClass = new EventMonitoringLog_Schedule();
		String chron = '0 0 23 * * ?';
		System.schedule( 'Create logs', chron, scheduleClass );
		Test.stopTest();
		System.assertEquals(1,[SELECT count() FROM CronTrigger], '1 job should be scheduled' );
	}
}