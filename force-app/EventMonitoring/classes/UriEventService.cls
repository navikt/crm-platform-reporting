/* 
convert UriEvent to Log__c record with lookup to Person Ident
Make it possible for NAV's "snokelogg" to get log elemnts
*/
public with sharing class UriEventService {
    public static void addPersonRelatedRecordsToLog(List<UriEvent> uriEvents) {
        List<Log__c> logs = new List<Log__c>();

        Map<Id, UriEvent> uriEventByRecordId = new Map<Id, UriEvent>();

        //record ids for each object we want to log
        Set<Id> personRecordIds = new Set<Id>();
        Set<Id> accountRecordIds = new Set<Id>();
        Set<Id> hotRequestRecordIds = new Set<Id>();
        Set<Id> serviceAppointmentRecordIds = new Set<Id>();
        Set<Id> workOrderRecordIds = new Set<Id>();
        Set<Id> workOrderLineItemRecordIds = new Set<Id>();
        Set<Id> caseRecordIds = new Set<Id>();
        Set<Id> chatTranscriptRecordIds = new Set<Id>();
        Set<Id> navTaskRecordIds = new Set<Id>();

        //check if object ype should be logged
        for (UriEvent ue : uriEvents) {
            //only standard users are logged
            if (ue.UserType != 'Standard')
                continue;

            switch on ue.QueriedEntities {
                when 'Person__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    personRecordIds.add(ue.RecordId);
                }
                when 'Account' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    accountRecordIds.add(ue.RecordId);
                }
                when 'HOT_Request__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    hotRequestRecordIds.add(ue.RecordId);
                }
                when 'WorkOrder' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    workOrderRecordIds.add(ue.RecordId);
                }
                when 'WorkOrderLineItem' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    workOrderLineItemRecordIds.add(ue.RecordId);
                }
                when 'ServiceAppointment' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    serviceAppointmentRecordIds.add(ue.RecordId);
                }
                when 'Case' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    caseRecordIds.add(ue.RecordId);
                }
                when 'LiveChatTranscript' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    chatTranscriptRecordIds.add(ue.RecordId);
                }
                when 'NavTask__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    navTaskRecordIds.add(ue.RecordId);
                }
            }
        }

        //get related person ident for each object
        Map<Id, String> personIdentByRecordId = getPersonIdentsForEachObject(
            personRecordIds,
            accountRecordIds,
            hotRequestRecordIds,
            workOrderRecordIds,
            workOrderLineItemRecordIds,
            serviceAppointmentRecordIds,
            caseRecordIds,
            chatTranscriptRecordIds,
            navTaskRecordIds
        );

        //add log elemnt with person ident
        for (Id recordId : personIdentByRecordId.keyset()) {
            logs.add(addLogElement(uriEventByRecordId.get(recordId), personIdentByRecordId.get(recordId)));
        }

        if (logs.size() > 0) {
            insert logs;
        }
    }

    private static Map<Id, String> getPersonIdentsForEachObject(
        Set<Id> personRecordIds,
        Set<Id> accountRecordIds,
        Set<Id> hotRequestRecordIds,
        Set<Id> workOrderRecordIds,
        Set<Id> workOrderLineItemRecordIds,
        Set<Id> serviceAppointmentRecordIds,
        Set<Id> caseRecordIds,
        Set<Id> chatTranscriptRecordIds,
        Set<Id> navTaskRecordIds
    ) {
        Map<Id, String> personIdentByRecordId = new Map<Id, String>();

        //Person
        if (personRecordIds.size() > 0) {
            for (Person__c person : [SELECT Id, Name FROM Person__c WHERE Id IN :personRecordIds]) {
                personIdentByRecordId.put(person.Id, person.Name);
            }
        }

        //Account
        if (accountRecordIds.size() > 0) {
            for (Account acc : [
                SELECT Id, Int_PersonIdent__c
                FROM Account
                WHERE Id IN :accountRecordIds AND INT_PersonIdent__c != NULL
            ]) {
                personIdentByRecordId.put(acc.Id, acc.INT_PersonIdent__c);
            }
        }

        //HOT Request
        if (hotRequestRecordIds.size() > 0) {
            for (HOT_Request__c req : [
                SELECT Id, Person__r.Name
                FROM HOT_Request__c
                WHERE Id IN :hotRequestRecordIds
            ]) {
                personIdentByRecordId.put(req.Id, req.Person__r.Name);
            }
        }

        //Work Order
        if (workOrderRecordIds.size() > 0) {
            for (WorkOrder wo : [
                SELECT Id, Account.INT_PersonIdent__c
                FROM WorkOrder
                WHERE Id IN :workOrderRecordIds
            ]) {
                personIdentByRecordId.put(wo.Id, wo.Account.INT_PersonIdent__c);
            }
        }

        //Work Order Lime Item
        if (workOrderLineItemRecordIds.size() > 0) {
            for (WorkOrderLineItem woli : [
                SELECT Id, WorkOrder.Account.INT_PersonIdent__c
                FROM WorkOrderLineItem
                WHERE Id IN :workOrderLineItemRecordIds
            ]) {
                personIdentByRecordId.put(woli.Id, woli.WorkOrder.Account.INT_PersonIdent__c);
            }
        }

        //Service Appointment
        if (serviceAppointmentRecordIds.size() > 0) {
            for (ServiceAppointment sa : [
                SELECT Id, Account.INT_PersonIdent__c
                FROM ServiceAppointment
                WHERE Id IN :serviceAppointmentRecordIds
            ]) {
                personIdentByRecordId.put(sa.Id, sa.Account.INT_PersonIdent__c);
            }
        }

        //Case
        if (caseRecordIds.size() > 0) {
            for (Case c : [SELECT Id, Account.INT_PersonIdent__c FROM Case WHERE Id IN :caseRecordIds]) {
                personIdentByRecordId.put(c.Id, c.Account.INT_PersonIdent__c);
            }
        }

        //Chat Transcript
        if (chatTranscriptRecordIds.size() > 0) {
            for (LiveChatTranscript c : [
                SELECT Id, Account.INT_PersonIdent__c
                FROM LiveChatTranscript
                WHERE Id IN :chatTranscriptRecordIds
            ]) {
                personIdentByRecordId.put(c.Id, c.Account.INT_PersonIdent__c);
            }
        }

        //NAV Task
        if (navTaskRecordIds.size() > 0) {
            for (NavTask__c navTask : [
                SELECT Id, CRM_Account__r.INT_PersonIdent__c
                FROM NavTask__c
                WHERE Id IN :navTaskRecordIds
            ]) {
                personIdentByRecordId.put(navTask.Id, navTask.CRM_Account__r.INT_PersonIdent__c);
            }
        }

        return personIdentByRecordId;
    }

    private static Log__c addLogElement(UriEvent ue, String personIdent) {
        return new Log__c(
            CRM_RecordId__c = ue.RecordId,
            CRM_EventDate__c = ue.EventDate,
            CRM_QueriedEntity__c = ue.QueriedEntities,
            CRM_Username__c = ue.Username,
            CRM_Operation__c = ue.Operation,
            CRM_PersonIdent__c = personIdent,
            CRM_Type__c = 'LightningUriEvent',
            CRM_Status__c = 'Completed'
        );
    }
}
