/**   wrapper class to represent LightningUriEvent object. 
sObject LightningUriEvent is not available in scratch org **/

public with sharing class UriEvent {
   
    private DateTime eventDateField;
    public Id RecordId {get;set;}
    public DateTime EventDate {
        get {return eventDateField.addHours(1);}
        set {eventDateField=value;}
    }
    public String QueriedEntities {get;set;}
    public String Operation {get;set;}
    public String Username {get;set;}
    public String UserType {get;set;}

    public UriEvent(Id recordId, DateTime eventDate, String queriedEntities, String operation, String username, String userType){
        this.Recordid=recordId;
        this.EventDate=eventDate;
        this.QueriedEntities=queriedEntities;
        this.Operation=operation;
        this.Username=username;
        this.UserType=userType;
    }
}