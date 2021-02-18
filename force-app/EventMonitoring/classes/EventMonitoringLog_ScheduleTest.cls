@IsTest
private class EventMonitoringLog_ScheduleTest {
    @IsTest
    private static void testScheduleExecute() {
        Test.startTest();
        EventMonitoringLog_Schedule scheduleClass = new EventMonitoringLog_Schedule();
        String chron = '0 0 23 * * ?';
        System.schedule('Create logs', chron, scheduleClass);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger], '1 job should be scheduled');
        System.assertEquals(1, [SELECT COUNT() FROM AsyncRequest__c]);
    }
}
