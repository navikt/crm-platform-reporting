@IsTest
private class UriEventServiceTest {
    @TestSetup
    static void makeData() {
        Group publicGroup = TestDataFactory.getPublicGroup('HMS Agder', 'group_47001');
        TestDataFactory.getPersons(1, true);
        TestDataFactory.getAccounts(1, true);
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forPerson() {
        Person__c testPerson = [SELECT Id, Name FROM Person__c LIMIT 1][0];
        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(testPerson.Id, DateTime.now(), 'Person__c', 'Read', 'user@user.nav.no', 'Standard'));

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [SELECT CRM_PersonIdent__c FROM Log__c WHERE CRM_Type__c = 'LightningUriEvent'];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            testPerson.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forAccounts() {
        //check test data
        List<Account> accounts = [SELECT Id, INT_PersonIdent__c FROM Account ORDER BY INT_PersonIdent__c];
        System.assertEquals(2, accounts.size());
        System.assertEquals(null, accounts[0].INT_PersonIdent__c);
        System.assertNotEquals(null, accounts[1].INT_PersonIdent__c);

        //create test uriEvents
        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(accounts[0].Id, DateTime.now(), 'Account', 'Read', 'user@user.nav.no', 'Standard'));
        uriEvents.add(new UriEvent(accounts[1].Id, DateTime.now(), 'Account', 'Read', 'user@user.nav.no', 'Standard'));

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [SELECT CRM_PersonIdent__c FROM Log__c WHERE CRM_Type__c = 'LightningUriEvent'];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            accounts[1].INT_PersonIdent__c,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forNotRelevantObject() {
        //create test uriEvents
        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(
            new UriEvent(
                '0011j00000vDpWQAA0',
                DateTime.now(),
                'TemporaryLayoyff__c',
                'Read',
                'user@user.nav.no',
                'Standard'
            )
        );

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [SELECT CRM_PersonIdent__c FROM Log__c WHERE CRM_Type__c = 'LightningUriEvent'];
        System.assertEquals(0, logs.size(), 'Log is not created');
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forPortalUser() {
        Person__c testPerson = [SELECT Id, Name FROM Person__c LIMIT 1][0];

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(testPerson.Id, DateTime.now(), 'Person__c', 'Read', 'user@user.nav.no', 'Portal'));

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [SELECT CRM_PersonIdent__c FROM Log__c WHERE CRM_Type__c = 'LightningUriEvent'];
        System.assertEquals(0, logs.size(), 'Portal user events is not logged');
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forHotRequest() {
        Person__c testPerson = [SELECT Id, Name, CRM_Account__c FROM Person__c LIMIT 1][0];
        HOT_Request__c request = new HOT_Request__c(Account__c = testPerson.CRM_Account__c, Person__c = testPerson.Id);
        insert request;

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(
            new UriEvent(request.Id, DateTime.now(), 'HOT_Request__c', 'Read', 'user@user.nav.no', 'Standard')
        );

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent' AND CRM_QueriedEntity__c = 'HOT_Request__c'
        ];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            testPerson.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forWorkOrdersAndWorkOrderLineItemsAndServiceAppointments() {
        Person__c testPerson = [SELECT Id, Name, CRM_Account__c FROM Person__c LIMIT 1][0];
        HOT_Request__c request = new HOT_Request__c(Account__c = testPerson.CRM_Account__c, Person__c = testPerson.Id);
        insert request;

        WorkOrder wo = new WorkOrder(AccountId = testPerson.CRM_Account__c, HOT_Request__c = request.Id);
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.Id);
        insert woli;

        ServiceAppointment sa = new ServiceAppointment(ParentRecordId = woli.Id, HOT_Request__c = request.Id);
        insert sa;

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(wo.Id, DateTime.now(), 'WorkOrder', 'Read', 'user@user.nav.no', 'Standard'));
        uriEvents.add(
            new UriEvent(woli.Id, DateTime.now(), 'WorkOrderLineItem', 'Read', 'user@user.nav.no', 'Standard')
        );
        uriEvents.add(
            new UriEvent(sa.Id, DateTime.now(), 'ServiceAppointment', 'Read', 'user@user.nav.no', 'Standard')
        );

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c, CRM_QueriedEntity__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent'
        ];
        System.assertEquals(3, logs.size(), 'One log element is created');

        System.assertEquals('WorkOrder', logs[0].CRM_QueriedEntity__c, 'First log element is Work Order');
        System.assertEquals(
            testPerson.Name,
            logs[0].CRM_PersonIdent__c,
            'Work Order Log element should have persons fødselsr / dnr'
        );

        System.assertEquals(
            'WorkOrderLineItem',
            logs[1].CRM_QueriedEntity__c,
            'Second log element is Work Order Line Item'
        );
        System.assertEquals(
            testPerson.Name,
            logs[1].CRM_PersonIdent__c,
            'Work Order Line Item Log element should have persons fødselsr / dnr'
        );

        System.assertEquals(
            'ServiceAppointment',
            logs[2].CRM_QueriedEntity__c,
            'Third log element is Service Appointment'
        );
        System.assertEquals(
            testPerson.Name,
            logs[2].CRM_PersonIdent__c,
            'Third Log element should have persons fødselsr / dnr'
        );
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forCaseAndChatTranscript() {
        Person__c testPerson = [SELECT Id, Name, CRM_Account__c FROM Person__c LIMIT 1][0];
        Case testCase = new Case(AccountId = testPerson.CRM_Account__c, Origin = 'Web', Subject = 'Test Case');
        insert testCase;

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        LiveChatTranscript testTranscript = new LiveChatTranscript(
            AccountId = testPerson.CRM_Account__c,
            CaseId = testCase.Id,
            LiveChatVisitorId = visitor.Id
        );
        insert testTranscript;

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(testCase.Id, DateTime.now(), 'Case', 'Read', 'user@user.nav.no', 'Standard'));
        uriEvents.add(
            new UriEvent(
                testTranscript.Id,
                DateTime.now(),
                'LiveChatTranscript',
                'Read',
                'user@user.nav.no',
                'Standard'
            )
        );

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c, CRM_QueriedEntity__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent'
        ];
        System.assertEquals(2, logs.size(), 'Two log element is created');
        System.assertEquals(
            testPerson.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
        System.assertEquals(
            testPerson.Name,
            logs[1].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
        System.assertEquals('Case', logs[0].CRM_QueriedEntity__c);
        System.assertEquals('LiveChatTranscript', logs[1].CRM_QueriedEntity__c);
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forNavTask() {
        Person__c testPerson = [SELECT Id, Name, CRM_Account__c FROM Person__c LIMIT 1][0];
        NavTask__c testTask = new NavTask__c(CRM_Account__c = testPerson.CRM_Account__c);
        insert testTask;

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(testTask.Id, DateTime.now(), 'NavTask__c', 'Read', 'user@user.nav.no', 'Standard'));

        Test.startTest();
        UriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent' AND CRM_QueriedEntity__c = 'NavTask__c'
        ];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            testPerson.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }
}
