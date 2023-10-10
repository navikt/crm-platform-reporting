public with sharing class AmplitudeHelper {
    
    @AuraEnabled(cacheable=true) 
    public static String getAmplitudeKey(){
        return AmplitudeKey__c.getOrgDefaults().Key__c;
    }    
}