@IsTest
private class DIA_UserAdoption_Schedule_Test {
    @TestSetup
    private static void makeData(){
        Profile platformProfile=[SELECT Id FROM Profile WHERE Name='Standard Platform User' LIMIT 1];

        User platformUser=new User();
        platformUser.FirstName='Platform';
        platformUser.LastName='Test';
        platformUser.Email='test.platform@nav.no';
        platformUser.UserName='test.platform423_fdsfds@nav.no';
        platformUser.ProfileId=platformProfile.Id;
        platformUser.CRM_Nav_Ident__c='A123456';
        platformUser.Alias='plattest';
        platformUser.TimeZoneSidKey='Europe/Paris';
        platformUser.LocaleSidKey='no_NO';
        platformUser.EmailEncodingKey='ISO-8859-1';
        platformUser.LanguageLocaleKey='no';
        platformUser.CompanyName='Test Unit';
        insert platformUser;
        system.debug(platformUser);
      
    }
    @IsTest
    private static void testScheduleExecute() {
      
        Test.startTest();
        DIA_UserAdoption_Schedule scheduleClass = new DIA_UserAdoption_Schedule();
        String chron = '0 0 23 * * ?';
        System.schedule('Create user adoption job', chron, scheduleClass);
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'Create user adoption job'],
            '1 job should be scheduled'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ReportingData__c WHERE CRM_Category__c='DIA User Adoption' AND CRM_Week__c=1 AND CRM_NavUnit__c='Test Unit' AND CRM_Value__c=1],
            '1 Reporting Data record should be created'
        );
       
    }
}
