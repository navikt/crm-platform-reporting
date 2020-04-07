public with sharing class UserAdoptionService {

    public static void insertReportingData(Date reportDate) {

        DateTime periodStart =DateTime.now().addDays(-7);
        
        List<ReportingData__c> reportingData = getLastLogInByUnit(periodStart, reportDate);
        reportingData.addAll(getNewUsers(reportDate));
        insert reportingData;
    }

    public static List<ReportingData__c> getLastLogInByUnit(DateTime periodStart, Date reportDate) {

        AggregateResult[] usersByUnit = [
                SELECT CompanyName, Min(Region__c) Region, COUNT(ID) Logins
                FROM User
                WHERE LastLoginDate >= :periodStart
                GROUP BY CompanyName
        ];

        List<ReportingData__c> reportingData = new List<ReportingData__c>();
        for (AggregateResult ar : usersByUnit) {
            reportingData.add(new ReportingData__c(
                    Name = 'Pålogging',
                    CRM_Region__c = (String) ar.get('Region'),
                    CRM_Value__c = (Integer) ar.get('Logins'),
                    CRM_Date__c =reportDate,
                    CRM_Category__c = 'User Adoption',
                    CRM_NavUnit__c=(String) ar.get('CompanyName')
            ));
        }
        return reportingData;
    }

    public static List<ReportingData__c> getNewUsers(Date reportDate) {
        
        DateTime startDate=DateTime.newInstance(reportDate.year(),reportDate.month(),reportDate.day(),0,0,0);
        DateTime endDate=DateTime.newInstance(reportDate.year(),reportDate.month(),reportDate.day(),23,59,59);
        AggregateResult[] usersByUnit = [
                SELECT CompanyName, Min(Region__c) Region, ProfileId, COUNT(ID) Users
                FROM User
                WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate
                GROUP BY CompanyName, ProfileId
        ];

        Map<Id,String> profileNameById=getProfilesById();
        List<ReportingData__c> reportingData = new List<ReportingData__c>();
        for (AggregateResult ar : usersByUnit) {
            String profileName=(String)ar.get('ProfileId');
            reportingData.add(new ReportingData__c(
                    Name = profileNameById.get(profileName),
                    CRM_Region__c = (String) ar.get('Region'),
                    CRM_Value__c = (Integer) ar.get('Users'),
                    CRM_Date__c =reportDate,
                    CRM_Category__c = 'New Users',
                    CRM_NavUnit__c=(String) ar.get('CompanyName')
            ));
        }
        return reportingData;
    }

    private static Map<Id,String> getProfilesById(){
        Map<Id,String> nameById=new Map<Id,String>();
        List<Profile> profiles= [SELECT Id, Name FROM Profile];
        for(Profile p:profiles){
            nameById.put(p.Id,p.Name);
        }
        return nameById;

    }


}