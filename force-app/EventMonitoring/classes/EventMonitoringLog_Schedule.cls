//* start async job to handle next 2000 LightningUrlEvents
global class EventMonitoringLog_Schedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        AsyncRequest__c req = new AsyncRequest__c();
        Date yesterday = Date.today().addDays(-1);
        DateTime inputDate = DateTime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), 23, 59, 59);
        req.CRM_ApexJobType__c = 'Queueable';
        req.CRM_AsyncType__c = 'Lightning Uri Event';
        req.CRM_Params__c = String.valueOf(inputDate);
        insert req;
    }
}
