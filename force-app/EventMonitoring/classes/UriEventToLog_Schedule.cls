/* fetch lightning uri event form yesterday and save it to Logg__c **/

global class UriEventToLog_Schedule Implements Schedulable
    {
        private String sessionId;

        global UriEventToLog_Schedule( ) {
            this.sessionId = UserInfo.getSessionId();
        }
        
        global void execute(SchedulableContext sc) {
            queryUriEventFromYesterday(sessionId);
        }
        
        // annotate with @future(callout=true) since this is scheduled Apex in order
        // to make the necessary call out to the Rest API
        @future(callout=true)
        public static void queryUriEventFromYesterday(String sessionId){
        
            // set the session id passed in to a local variable
            String sId = sessionId;
        
            // set date range for yesterday
       	    DateTime f = date.today();
            String endTime = f.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
            
            DateTime s = f.addDays(-1);
            String startTime = s.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
        
            
            // Async SOQL JSON Body for post
    
            String content = '{"query":"SELECT Recordid, EventDate, QueriedEntities, Operation, Username FROM LightningUriEvent WHERE EventDate>=' + startTime + ' AND EventDate<=' + endTime + '","targetObject":"Log__c","targetFieldMap":{"Username":"CRM_Username__c", "EventDate":"CRM_EventDate__c", "QueriedEntities":"CRM_ObjectType__c","Operation":"CRM_Operation__c","RecordId":"CRM_RecordId__c"}}';
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
                        
            req.setEndpoint(System.URL.getSalesforceBaseURL().toExternalForm() + '/services/data/v49.0/async-queries');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setBody(content);
            
            // Grab session Id that was passed in to authenticate
            req.setHeader('Authorization', 'Bearer ' + sId);
            
            // try callout to Async SOQL Rest API
            try {
                res = http.send(req);
              
                // parse JSON results to extract the jobid for tracking purposes
                JSONParser parser = JSON.createParser(res.getBody());  
                while (parser.nextToken() != null) {  
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if (fieldName == 'jobId') {
                            //accesstoken = parser.getText();
                            system.debug('jobId Text() => ' + parser.getText());
                        }
                    }
                }     
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            }
        }
}
