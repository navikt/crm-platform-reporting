@isTest
public class TaskFactory {
    public static List<Task> generateTasksFor_TaskRecordTypeIdUpdateQueryTest(){
        List<Task> results = new List<Task>();
        ID agOppId = [SELECT Id FROM RecordType WHERE Name='AG Oppgave' LIMIT 1].Id;
        ID hTaskId = [SELECT Id FROM RecordType WHERE Name='HOT Task' LIMIT 1].Id;
        
        List<ID> rtList = new List<ID>();
        
        rtList.add(agOppId);
        rtList.add(hTaskId);
        
        Integer maxTasksWithTypeCount = 5;
        for(ID rt : rtList){
            Integer actualTasksWithTypeCount = (Math.mod(Math.abs(System.Crypto.getRandomInteger()),
                              					maxTasksWithTypeCount)) + 1;
            for ( Integer i = 0; i < actualTasksWithTypeCount; i++){
                results.add(new Task(RecordTypeId = rt));
            }
        }
/*       
        Integer actualTasksWithTypeCount;
        Integer maxTasksWithTypeCount = 5;
        for ( Integer j = 0; j < 2; j++){
            actualTasksWithTypeCount = (Math.mod(Math.abs(System.Crypto.getRandomInteger()),
                              maxTasksWithTypeCount)) + 1;
            for ( Integer i = 0; i < actualTasksWithTypeCount; i++){
                results.add(new Task(RecordTypeId = (j == 0)? agOppId:
                                     						  hTaskId));
            }
        }
*/       
        
        return results;
    }
}