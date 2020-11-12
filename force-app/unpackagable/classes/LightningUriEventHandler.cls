public class LightningUriEventHandler extends AsyncJob {

    public override void execute(AsyncRequest__c ar) {
        DateTime toTime = DateTime.valueOf(ar.CRM_Params__c);
        //get elements from the begining of same day
        DateTime fromTime= DateTime.newInstance(toTime.year(), toTime.month(), toTime.day(), 0, 0, 0);
        
        //we know first record was processed by last job, if toTime is not default 
       	Boolean skipFirstRecord=false;
        Date yesterday=Date.today().addDays(-1);
        DateTime defaultInputDate=DateTime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), 23, 59, 59);
        if(toTime!=defaultInputDate){
            skipFirstRecord=true;
        }
        System.debug(fromTime);
        System.debug(toTime);
        List<LightningUriEvent> events=[SELECT EventDate,Operation,QueriedEntities,RecordId,Username, UserType FROM LightningUriEvent WHERE EventDate >=: fromTime AND EventDate <=:toTime LIMIT 2000];
        System.debug(events.size());
        //create log element
        List<UriEvent> uriEvents=new List<UriEvent>();
        Integer i=0;
        for(LightningUriEvent ue:events){
            uriEvents.add(new UriEvent(ue.RecordId, ue.EventDate, ue.QueriedEntities, ue.Operation, ue.Username, ue.UserType));
        }
        System.debug(uriEvents.size());
        if(uriEvents.size()>0){
            UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        }
       
        //create new async job if 2000 records was found
        if(events.size()==2000)
       	{
           createNewAsyncJob(events[1999].EventDate);
         }
    }
    
    @TestVisible
    private void createNewAsyncJob(DateTime lastEventDate){
         AsyncRequest__c req=new AsyncRequest__c();
        	req.CRM_ApexJobType__c='Queueable';
        	req.CRM_AsyncType__c='Lightning Uri Event';
        	req.CRM_Params__c=String.valueOf(lastEventDate);
        	insert req;
    }
 }