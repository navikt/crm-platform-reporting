public class TaskRecordTypeIdUpdateQuery implements Database.Batchable<sObject>{
    
    public final String query;
    public final id newRecordTypeId;
    
    public TaskRecordTypeIdUpdateQuery(){
        newRecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name='AG Oppgave' LIMIT 1].Id;
        if(Test.isRunningTest()){
            ID htaskId = [SELECT Id FROM RecordType WHERE Name='HOT Task' LIMIT 1].Id;
            query = 'SELECT Id FROM Task WHERE RecordTypeId = \'' + htaskId + '\'';
        } else {
            query = 'SELECT Id FROM Task WHERE RecordTypeId = NULL';
        } 
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }   
    public void execute(Database.BatchableContext bc, List<Task> tasks){
        for(Task t : tasks){
            t.RecordTypeId = newRecordTypeId;
        }
        update tasks;
    }   
    public void finish(Database.BatchableContext bc){
        System.debug('Finished: TaskTypeRecordIdUpdate');
    }

}