@isTest
private class HOT_SAReportControllerTest{

	@testSetup static void setup(){

		WorkType workType = HOT_TestDataFactory.createWorkType();
		insert workType;
		HOT_Request__c request = HOT_TestDataFactory.createRequest('Bestilling', workType);
		insert request;
		request.Status__c = 'Godkjent';
		update request;

		HOT_ServiceAppointmentReportController.upsertReportingData(Date.today().addDays(-1), Date.today().addDays(1));
	}

	@isTest static void upsertReportingDataTest() {
        List<ReportingData__c> reportingData=[SELECT Id FROM ReportingData__c];
        System.assertNotEquals(reportingData.size(), 0);
	}

}