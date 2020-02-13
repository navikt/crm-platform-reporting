@IsTest
public  class TestDataFactory_Reporting {
    private static List<User> users;

    public static List<User> getUsers(Integer numberOfUsers, String profileName,Boolean doInsert) {
        if (users != null) return users;
        users = new List<User>();
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = :profileName LIMIT 1];

        for (Integer i = 1; i <= numberOfUsers; i++) {
            String firstName = 'User';
            String lastName = String.valueOf(i);
            String email = firstName + lastName + '@nav.apextest';
            User user = new User(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email,
                    Username = email,
                    Alias = lastName,
                    LanguageLocaleKey = 'no',
                    LocaleSidKey = 'no_NO',
                    TimeZoneSidKey = 'Europe/Paris',
                    EmailEncodingKey = 'UTF-8',
                    ProfileId = profile.Id,
                    Region__c='Viken'
            );

        }
        if (doInsert) insert users;
        return users;
    }
}