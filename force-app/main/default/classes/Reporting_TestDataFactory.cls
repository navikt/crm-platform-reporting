@IsTest
public with sharing class Reporting_TestDataFactory {


    public static Log__c getLog(Id recordId, String objectType){
        Log__c log = new Log__c();
        log.CRM_RecordId__c=recordId;
        log.CRM_EventDate__c=DateTime.now();
        log.CRM_QueriedEntity__c=objectType; 
        log.CRM_Operation__c='Read';
        log.CRM_Type__c='LightningUriEvent';
        log.CRM_Status__c='Error';
        log.CRM_Username__c='user@nav.no';
        return log;
       }
}
