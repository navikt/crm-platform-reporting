public with sharing class DeleteLog_Schedule implements Schedulable, Database.Batchable<SObject> {
   
    private string LOG_QUERY;
    
	public void execute( SchedulableContext sc ) {
        DeleteLog_Schedule btch = new DeleteLog_Schedule();
		Database.executeBatch( btch, 2000 );
    }

    public  DeleteLog_Schedule(){
        this.LOG_QUERY='SELECT Id FROM Log__c WHERE CRM_Status__c=\'Not completed\' OR (CRM_Status__c=\'Pending\' AND CRM_UserType__c!=\'Standard\')';
    }
    
    public  DeleteLog_Schedule(string condition){
        this.LOG_QUERY='SELECT Id FROM Log__c WHERE ' + condition;
    }
    
	public Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( this.LOG_QUERY);
    }
    
    public void execute( Database.BatchableContext BC, List<Log__c> scope ) {
        delete scope;   
        Database.emptyRecycleBin(scope);
    }

    public void finish( Database.BatchableContext BC ) {
    }
}  