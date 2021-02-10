public with sharing class HOT_ServiceAppointmentReportController {

    public static void upsertReportingData(Date periodStart, Date periodEnd) {
        List<ServiceAppointment> serviceAppointments = [SELECT Id, ParentRecordId, HOT_IsEmployedInterpreter__c, HOT_IsReleasedToFreelance__c, WorkType.Name, ServiceTerritory.Name,
                                                               EarliestStartTime, DueDate, SchedStartTime, SchedEndTime, ActualStartTime, ActualEndTime, HOT_HapticCommunication__c,
                                                               CreatedDate, Status, Duration, HOT_AssignmentType__c, Owner.Name, ActualDuration, DurationType, AppointmentNumber,
                                                               HOT_IsSerieoppdrag__c, HOT_CancelComment__c, HOT_IsAcute__c, HOT_IsScreenInterpreter__c, HOT_ReleaseDate__c,
                                                               HOT_FreelanceSubject__c, HOT_DeadlineDate__c, HOT_Request__c, Subject
                                                        FROM ServiceAppointment WHERE LastModifiedDate >= :periodStart AND LastModifiedDate <= :periodEnd];
        
        Map<Id, ServiceAppointment> IdtoSA = new Map<Id, ServiceAppointment>();
        for(ServiceAppointment sa:serviceAppointments){
            IdtoSA.put(sa.Id, sa);
        }

        Map<Id, Id> SAtoWOLI = new Map<Id, Id>();
        for(ServiceAppointment sa:serviceAppointments){
            SAtoWOLI.put(sa.Id, sa.ParentRecordId);
        }
        List<WorkOrderLineItem> workOrderLineItems = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Id IN :SAtoWOLI.values()];
        Map<Id, Id> WOLItoWO = new Map<Id, Id>();
        for(WorkOrderLineItem woli:workOrderLineItems){
            WOLItoWO.put(woli.Id, woli.WorkOrderId);
        }
        List<WorkOrder> workOrders = [SELECT Id, HOT_Request__c FROM WorkOrder WHERE Id IN :WOLItoWO.values()];
        Map<Id, Id> WOtoRequest = new Map<Id, Id>();
        for(WorkOrder wo:workOrders){
            WOtoRequest.put(wo.Id, wo.HOT_Request__c);
        }
        List<HOT_Request__c> requests = [SELECT Id, AssignmentType__c, IsAcute__c, Status__c, Name, CreatedDate, Subject__c        
                                         FROM HOT_Request__c WHERE Id IN :WOtoRequest.values()];
        
        Map<Id, HOT_Request__c> requestMap = new Map<Id, HOT_Request__c>();
        for(HOT_Request__c req:requests){
            requestMap.put(req.Id, req);
        }

        Map<Id, HOT_Request__c> SAIdtoRequest = new Map<Id, HOT_Request__c>();
        for(Id saId:SAtoWOLI.keySet()){
            SAIdtoRequest.put(saId, requestMap.get(WOtoRequest.get(WOLItoWO.get(SAtoWOLI.get(saId)))));
        }
        
        List<ReportingData__c> reportingData = [SELECT Id, HOT_ServiceAppointment__c FROM ReportingData__c WHERE HOT_ServiceAppointment__c IN :SAIdtoRequest.keySet()];
        Map<Id, ReportingData__c> SAIdtoRepData = new Map<Id, ReportingData__c>();
        for(ReportingData__c repData:reportingData){
            SAIdtoRepData.put(repData.HOT_ServiceAppointment__c, repData);
        }
        
        for(ServiceAppointment sa:serviceAppointments){
            if(SAIdtoRepData.containsKey(sa.Id)){
                SAIdtoRepData.put(sa.Id, setFieldValues(SAIdtoRepData.get(sa.Id), IdtoSA.get(sa.Id), SAIdtoRequest.get(sa.Id)));
            }
            else{
                ReportingData__c repData = new ReportingData__c();
                SAIdtoRepData.put(sa.Id, setFieldValues(repData, IdtoSA.get(sa.Id), SAIdtoRequest.get(sa.Id)));
            }
        }
        upsert SAIdtoRepData.values();
    }

    public static ReportingData__c setFieldValues(ReportingData__c repData, ServiceAppointment serviceAppointment, HOT_Request__c request){
        repData.CRM_Category__c = 'Service Appointment';
        repData.CRM_Region__c = serviceAppointment.ServiceTerritory.Name;

        repData.HOT_ServiceAppointment__c = serviceAppointment.Id;
        repData.HOT_CreatedDate__c = serviceAppointment.CreatedDate;

        repData.HOT_RecordName__c = serviceAppointment.AppointmentNumber;
        repData.HOT_Request__c = serviceAppointment.HOT_Request__c;
        repData.HOT_Subject__c = serviceAppointment.Subject;
        repData.HOT_WorkType__c = serviceAppointment.WorkType.Name;
        repData.HOT_IsHapticCommunication__c = serviceAppointment.HOT_HapticCommunication__c;
        repData.HOT_IsSerieoppdrag__c = serviceAppointment.HOT_IsSerieoppdrag__c;
        
        repData.HOT_Owner__c = serviceAppointment.Owner.Name;
        repData.HOT_ServiceTerritory__c = serviceAppointment.ServiceTerritory.Name;
        repData.HOT_Status__c = serviceAppointment.Status;
        repData.HOT_CancelComment__c = serviceAppointment.HOT_CancelComment__c;
        repData.HOT_IsAcute__c = serviceAppointment.HOT_IsAcute__c;
        repData.HOT_IsScreenInterpreter__c = serviceAppointment.HOT_IsScreenInterpreter__c;

        repData.HOT_EarliestStartTime__c = serviceAppointment.EarliestStartTime;
        repData.HOT_DueDate__c = serviceAppointment.DueDate;

        repData.HOT_SchedStartTime__c = serviceAppointment.SchedStartTime;
        repData.HOT_SchedEndTime__c = serviceAppointment.SchedEndTime;
        repData.HOT_Duration__c = serviceAppointment.Duration;
        repData.HOT_DurationType__c = serviceAppointment.DurationType;

        repData.HOT_ActualStartTime__c = serviceAppointment.ActualStartTime;
        repData.HOT_ActualEndTime__c = serviceAppointment.ActualEndTime;
        repData.HOT_ActualDuration__c = serviceAppointment.ActualDuration;
        
        repData.HOT_IsEmployedInterpreter__c = serviceAppointment.HOT_IsEmployedInterpreter__c;
        repData.HOT_IsFreelanceInterpreter__c = serviceAppointment.HOT_IsReleasedToFreelance__c;
        repData.HOT_FreelanceSubject__c = serviceAppointment.HOT_FreelanceSubject__c;
        repData.HOT_ReleaseDate__c = serviceAppointment.HOT_ReleaseDate__c;
        repData.HOT_DeadlineDate__c = serviceAppointment.HOT_DeadlineDate__c;

        return repData;
    }
}
