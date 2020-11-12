@IsTest
private class LightningUriEventHandlerTest {

    @IsTest
    private static void testExecute(){
        AsyncRequest__c req=new AsyncRequest__c();
        Date yesterday=Date.today().addDays(-1);
        DateTime inputDate=DateTime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), 23, 59, 59);
        req.CRM_ApexJobType__c='Queueable';
        req.CRM_AsyncType__c='Lightning Uri Event';
        req.CRM_Params__c=String.valueOf(inputDate);
		
        Test.startTest();
        LightningUriEventHandler handler=new LightningUriEventHandler();
		handler.execute(req);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCreateNewAsyncJob(){
        Test.startTest();
       	LightningUriEventHandler handler=new LightningUriEventHandler();
		handler.createNewAsyncJob(DateTime.now());
        Test.StopTest();
        System.assertEquals(1, [SELECT count() FROM AsyncRequest__c], 'New async request is created');
    }
}