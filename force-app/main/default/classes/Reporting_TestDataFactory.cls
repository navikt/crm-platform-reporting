@IsTest
public with sharing class Reporting_TestDataFactory {


    public static Log__c getLog(Id recordId, String objectType){
        Log__c log = new Log__c();
        log.CRM_RecordId__c=recordId;
        log.CRM_EventDate__c=DateTime.now();
        log.CRM_ObjectType__c=objectType; 
        log.CRM_Operation__c='Read';
        log.CRM_Type__c='LightningUriEvent';
        log.CRM_Status__c='Pending';
        log.CRM_Username__c='user@nav.no';
        log.CRM_UserType__c='Standard';
        return log;
       }
}
