public with sharing class AmplitudeHelper {
    
    @AuraEnabled(cacheable=true) 
    public static String getAmplitudeKey(){
        if (AmplitudeKey__c.getValues(UserInfo.getUserId()) != null) {
            return AmplitudeKey__c.getValues(UserInfo.getUserId()).Key__c;
        } else if (AmplitudeKey__c.getValues(UserInfo.getProfileId()) != null) {
            return AmplitudeKey__c.getValues(UserInfo.getProfileId()).Key__c;
        }
        return AmplitudeKey__c.getOrgDefaults().Key__c;
    }    
}