@isTest
public class TaskFactory {
    public static List<Task> generateTasksFor_TaskRecordTypeIdUpdateQueryTest(){
        List<Task> results = new List<Task>();
        List<ID> rtList = new List<ID>();
        rtList.add([SELECT Id FROM RecordType WHERE Name='AG Oppgave' LIMIT 1].Id);
        rtList.add([SELECT Id FROM RecordType WHERE Name='HOT Task' LIMIT 1].Id);
        
        Integer maxTasksWithTypeCount = 5;
        for(ID rt : rtList){
            Integer actualTasksWithTypeCount = (Math.mod(Math.abs(System.Crypto.getRandomInteger()),
                              					maxTasksWithTypeCount)) + 1;
            for ( Integer i = 0; i < actualTasksWithTypeCount; i++){
                results.add(new Task(RecordTypeId = rt, Status = 'Open'));
            }
        }        
        return results;
    }
}