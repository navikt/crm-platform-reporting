/* 
Handle converted UriEvent to Log__c record with lookup to Person Ident
Make it possible for NAV's "snokelogg" to get log elemnts
*/
public with sharing class UriEventService {
   
    public static void addPersonRelatedRecordsToLog(List<Log__c> logs){

        //record ids for each object we want to log
        Set<Id> personRecordIds=new Set<Id>();
        Set<Id> accountRecordIds=new Set<Id>();
        Set<Id> hotRequestRecordIds=new Set<Id>();
        Set<Id> serviceAppointmentRecordIds=new Set<Id>();
        Set<Id> workOrderRecordIds=new Set<Id>();
        Set<Id> workOrderLineItemRecordIds=new Set<Id>();

        //check if object ype should be logged
        for(Log__c log:logs){

            switch on log.CRM_ObjectType__c {
               when 'Person__c'{
                personRecordIds.add(log.CRM_RecordId__c);
               }
               when 'Account'{
                accountRecordIds.add(log.CRM_RecordId__c);
               }
               when 'HOT_Request__c'{
                hotRequestRecordIds.add(log.CRM_RecordId__c);
               }
               when 'WorkOrder'{
                workOrderRecordIds.add(log.CRM_RecordId__c);
               }
               when 'WorkOrderLineItem'{
                workOrderLineItemRecordIds.add(log.CRM_RecordId__c);
               }
               when 'ServiceAppointment'{
                serviceAppointmentRecordIds.add(log.CRM_RecordId__c);
               }
           }
        }

        //get related person ident for each object
        Map<Id,String> personIdentByRecordId=getPersonIdentsForEachObject(personRecordIds, accountRecordIds, hotRequestRecordIds, workOrderRecordIds, workOrderLineItemRecordIds, serviceAppointmentRecordIds);

        //update log element
        for(Log__c log:logs){
            String personIdent=personIdentByRecordId.get(log.CRM_RecordId__c);
            if(personIdent!=null){
                log.CRM_Status__c='Completed';
                log.CRM_PersonIdent__c=personIdent;
                log.CRM_EventDate__c=log.CRM_EventDate__c.addHours(2); //adjust time zone
            }
            else{
                log.CRM_Status__c='Not completed';
            }
        }
        update logs;
    }

    private static Map<Id,String> getPersonIdentsForEachObject(Set<Id> personRecordIds, Set<Id> accountRecordIds, Set<Id> hotRequestRecordIds, Set<Id> workOrderRecordIds, Set<Id> workOrderLineItemRecordIds, Set<Id> serviceAppointmentRecordIds){
        Map<Id,String> personIdentByRecordId = new Map<Id,String>();

        //Person
        if(personRecordIds.size()>0){
            for(Person__c person:[SELECT Id, Name FROM Person__c WHERE Id in:personRecordIds]){
                personIdentByRecordId.put(person.Id,person.Name);
            }
        }

        //Account
        if(accountRecordIds.size()>0){
            for(Account acc:[SELECT Id, Int_PersonIdent__c FROM Account WHERE Id in:accountRecordIds AND INT_PersonIdent__c!=null]){
                personIdentByRecordId.put(acc.Id,acc.INT_PersonIdent__c);
            }
        }

          //HOT Request
          if(hotRequestRecordIds.size()>0){
            for(HOT_Request__c req:[SELECT Id, Person__r.Name FROM HOT_Request__c WHERE Id in:hotRequestRecordIds]){
                personIdentByRecordId.put(req.Id,req.Person__r.Name);
            }
        }

            //Work Order
            if(workOrderRecordIds.size()>0){
                for(WorkOrder wo:[SELECT Id, Account.INT_PersonIdent__c FROM WorkOrder WHERE Id in:workOrderRecordIds]){
                    personIdentByRecordId.put(wo.Id,wo.Account.INT_PersonIdent__c);
                }
            }

             //Work Order Lime Item
             if(workOrderLineItemRecordIds.size()>0){
                for(WorkOrderLineItem woli:[SELECT Id, WorkOrder.Account.INT_PersonIdent__c FROM WorkOrderLineItem WHERE Id in:workOrderLineItemRecordIds]){
                    personIdentByRecordId.put(woli.Id,woli.WorkOrder.Account.INT_PersonIdent__c);
                }
            }

             //Service Appointment
             if(serviceAppointmentRecordIds.size()>0){
                for(ServiceAppointment sa:[SELECT Id, Account.INT_PersonIdent__c FROM ServiceAppointment WHERE Id in:serviceAppointmentRecordIds]){
                    personIdentByRecordId.put(sa.Id,sa.Account.INT_PersonIdent__c);
                }
            }
        return personIdentByRecordId;
    }
}
