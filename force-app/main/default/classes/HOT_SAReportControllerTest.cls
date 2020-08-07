@isTest
private class HOT_SAReportControllerTest{

	@testSetup static void setup(){

		WorkType workType = HOT_TestDataFactory.createWorkType();
		insert workType;
		HOT_Request__c request = HOT_TestDataFactory.createRequest('Bestilling', workType);
		insert request;
		request.Status__c = 'Godkjent';
		update request;

		
	}

	@isTest static void upsertReportingDataTest() {
		Test.startTest();
		HOT_ServiceAppointmentReportController.upsertReportingData(Date.today(), Date.today().addDays(1));
		Test.stopTest();

        List<ReportingData__c> reportingData=[SELECT Id FROM ReportingData__c];
        System.assertEquals(reportingData.size(), 1);
	}

}