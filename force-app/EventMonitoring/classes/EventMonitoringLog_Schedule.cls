global class EventMonitoringLog_Schedule implements Schedulable, Database.Batchable<SObject> {
   
    private final string LOG_QUERY='SELECT CRM_Username__c, CRM_EventDate__c, CRM_ObjectType__c, CRM_Operation__c, CRM_PersonIdent__c, CRM_RecordId__c FROM Log__c WHERE CRM_Status__c=\'Pending\' AND CRM_Type__c=\'LightningUriEvent\'';
  
	public void execute( SchedulableContext sc ) {
        EventMonitoringLog_Schedule btch = new EventMonitoringLog_Schedule();
		Database.executeBatch( btch, 2000 );
    }
    
	public Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( this.LOG_QUERY);
    }
    
    public void execute( Database.BatchableContext BC, List<Log__c> scope ) {
        UriEventService.addPersonRelatedRecordsToLog(scope);
    }

    public void finish( Database.BatchableContext BC ) {
    }
}  