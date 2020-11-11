@IsTest  class UriEventToLog_ScheduleTest {
    
    @IsTest
    private static void testExecute(){
        Test.setMock(HttpCalloutMock.class, new  LightningUriEventAsynMock()); 

        Test.startTest();
        UriEventToLog_Schedule scheduleClass = new  UriEventToLog_Schedule();
		String chron = '0 0 23 * * ?';
		System.schedule( 'Create logs', chron, scheduleClass );
		Test.stopTest();
		System.assertEquals(1,[SELECT count() FROM CronTrigger], '1 job should be scheduled' );

    }
}
