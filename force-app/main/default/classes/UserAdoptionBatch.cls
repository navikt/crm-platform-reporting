global without sharing class UserAdoptionBatch implements Schedulable, Database.Batchable<AggregateResult> {
    private Boolean isNewUsers {get; set;} // Flag for batch type, set automatically.
    private final Integer BATCH_LIMIT = 1000; // Ensure the batch limit is reasonable to avoid limit exhaustion (!)
    private final Map<Id, String> profileNameById = getProfilesById();
    private final DateTime periodDate = DateTime.now().addDays(-7);
    private final DateTime reportDate = periodDate.addDays(6);
    private final DateTime startDate = DateTime.newInstance(reportDate.year(), reportDate.month(), reportDate.day(), 0, 0, 0);
    private final DateTime endDate = DateTime.newInstance(reportDate.year(), reportDate.month(), reportDate.day(), 23, 59, 59);
    private LoggerUtility logger = new LoggerUtility();
    
    global UserAdoptionBatch(Boolean isNewUsers){
        this.isNewUsers = isNewUsers;
    }

    // Necessary for the class to be schedulable as well as batchable
    global UserAdoptionBatch(){        
    }
    
    global void execute(SchedulableContext sc) {
        UserAdoptionBatch btch = new UserAdoptionBatch(false);
        Database.executeBatch(btch, BATCH_LIMIT);
    }

    global Iterable<AggregateResult> start(Database.BatchableContext BC) {       
        String query = '';
        // Query and thus batch type depends on the isNewUsers flag.
        if(!isNewUsers){            
            if(Test.isRunningTest()){
                query = 'SELECT CompanyName, Min(Region__c) Region, COUNT(ID) Logins FROM User WHERE Username LIKE \'%@nav.apextest%\' GROUP BY CompanyName';
            }else{
                query = 'SELECT CompanyName, Min(Region__c) Region, COUNT(ID) Logins FROM User WHERE LastLoginDate >= ' + String.valueOf(periodDate).replace(' ','T') + 'Z AND CompanyName != null GROUP BY CompanyName';
            }
        } else {
            if(Test.isRunningTest()){
                query = 'SELECT CompanyName, Min(Region__c) Region, ProfileId, COUNT(ID) Users FROM User WHERE CreatedDate >= ' + String.valueOf(startDate.addDays(1)).replace(' ','T') + 'Z AND CreatedDate <= ' + String.valueOf(endDate.addDays(1)).replace(' ','T') + 'Z GROUP BY CompanyName, ProfileId';
            }else{
                query = 'SELECT CompanyName, Min(Region__c) Region, ProfileId, COUNT(ID) Users FROM User WHERE CreatedDate >= ' + String.valueOf(startDate).replace(' ','T') + 'Z AND CreatedDate <= ' + String.valueOf(endDate).replace(' ','T') + 'Z AND CompanyName != null GROUP BY CompanyName, ProfileId';
            }
        }
        return new AggregateResultIterable(query);       
    }

    global void execute(Database.BatchableContext BC, List<AggregateResult> scope) {
        List<ReportingData__c> reportingData = new List<ReportingData__c>();
        Date rD = Date.newInstance(reportDate.year(), reportDate.month(), reportDate.day());
        for(AggregateResult ar : scope){
            ReportingData__c r = new ReportingData__c(
                CRM_Region__c = (String) ar.get('Region'),                
                CRM_Date__c = rD,
                CRM_NavUnit__c = (String) ar.get('CompanyName'));
            if(!isNewUsers){
                r.Name = 'Pålogging';
                r.CRM_Value__c = (Integer) ar.get('Logins');
                r.CRM_Category__c = 'User Adoption';
            } else {
                String profileName = (String) ar.get('ProfileId');
                r.Name = profileNameById.get(profileName);
                r.CRM_Value__c = (Integer) ar.get('Users');
                r.CRM_Category__c = 'New Users';
            }
            reportingData.add(r);            
        }
        
        try {
            insert reportingData;
        } catch (Exception e) {
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
        }        
    }
    global void finish(Database.BatchableContext BC) {
        //Start processing the newly created users by starting a new batch and setting the isNewUsers flag
        if(!isNewUsers){
            try{
                UserAdoptionBatch btchFinal = new UserAdoptionBatch(true);
                Database.executeBatch(btchFinal, BATCH_LIMIT);
            } catch (Exception e) {
                logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            }
        }
        if(logger.peek() != null) logger.publish();        
    }

    private static Map<Id, String> getProfilesById() {
        Map<Id, String> nameById = new Map<Id, String>();
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        for (Profile p : profiles) {
            nameById.put(p.Id, p.Name);
        }
        return nameById;
    }
}