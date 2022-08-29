@isTest
public class EventTriggerTest {

    @isTest 
    static void testThatWhenAProductWithTrainingRecordTypeIsInsertedATrainingEventIsCreatedAndJobIsScheduled() {
        Id trainingEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId();
        Id trainingProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Trainings_Provider').getRecordTypeId();
        Id trainingRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();

        Account trainingsProvider = new Account(
            Name = 'Test training provider',
            RecordTypeId = trainingProviderRecordTypeId
        );
        insert trainingsProvider;

        Product2 training = new Product2(
            Name = 'Test training',
            Start__c = Datetime.newInstance(Date.today().addDays(3), Time.newInstance(16, 0, 0, 0)),
            End__c = Datetime.newInstance(Date.today().addDays(3), Time.newInstance(16, 30, 0, 0)),
            Provider__c = trainingsProvider.Id,
            RecordTypeId = trainingRecordTypeId
        );

        Integer initalJobsCount = [
            SELECT COUNT()
            FROM CronTrigger
        ];

        Test.startTest();
        insert training;
        Test.stopTest();

        List<Event> events = [
            SELECT RecordTypeId
            FROM Event 
        ];
        System.assertEquals(1, events.size());
        System.assertEquals(trainingEventRecordTypeId, events[0].RecordTypeId);

        Integer finalJobsCount = [
            SELECT COUNT()
            FROM CronTrigger
        ];

        System.assertEquals(initalJobsCount + 1, finalJobsCount);
    }

    @isTest 
    static void ifEventWithRecordTypeDifferentToTrainingEventIsInsertedJobIsNotScheduled() {
        User testUser = new User(
            Alias = 'testuser', 
            Email='testuser@testuser.test', 
            UserName='testuser889123009@testuser.test',
            LastName='Testing', 
            EmailEncodingKey='UTF-8', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id, 
            TimeZoneSidKey='America/Los_Angeles'
        );
        insert testUser;

        Event ev = new Event(
            Subject = 'Test event',
            StartDateTime = Datetime.newInstance(Date.today().addDays(3), Time.newInstance(16, 0, 0, 0)),
            EndDateTime = Datetime.newInstance(Date.today().addDays(3), Time.newInstance(16, 30, 0, 0))
        );

        Integer initalJobsCount = [
            SELECT COUNT()
            FROM CronTrigger
        ];

        Test.startTest();
        // Run as this new user because has Master Record Type as Default for Events
        System.runAs(testUser) {
            insert ev;
        }
        Test.stopTest();

        List<Event> events = [
            SELECT RecordTypeId
            FROM Event 
        ];

        Integer finalJobsCount = [
            SELECT COUNT()
            FROM CronTrigger
        ];

        System.assertEquals(initalJobsCount, finalJobsCount);
    }
   

}
