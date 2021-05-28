@isTest
private class TaskRecordTypeIdUpdateQueryTest{
    @isTest public static void QueryTest(){
        
        // Test setup
        List<Task> ts = TaskFactory.generateTasksFor_TaskRecordTypeIdUpdateQueryTest();
        insert ts;
        ID hTaskId = [SELECT Id FROM RecordType WHERE Name='HOT Task' LIMIT 1].Id;
        Integer htCount = [SELECT COUNT() FROM Task WHERE RecordTypeId = :hTaskId];
        Integer otherCount = [SELECT COUNT() FROM Task WHERE RecordTypeId != :hTaskId];

        // Test
        TaskRecordTypeIdUpdateQuery trt = new TaskRecordTypeIdUpdateQuery();
		Test.startTest();
        Database.executeBatch(trt);
        Test.stopTest();
        Integer newHtCount = [SELECT COUNT() FROM Task WHERE RecordTypeId = :hTaskId];
        Integer newOtherCount = [SELECT COUNT() FROM Task WHERE RecordTypeId != :hTaskId];
        
        System.assertEquals(0,newHtCount);
        System.assertEquals(htCount+otherCount, newOtherCount);
    }
}