@isTest
public class SendEventReminderSchedulableTest {

    @isTest 
    static void createAnEventAndScheduleClassToRunNow() {
        Id trainingProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Trainings_Provider').getRecordTypeId();
        Id attendeeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Attendee').getRecordTypeId();
        Id trainingRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();

        Account trainingsProvider = new Account(
            Name = 'Test training provider',
            RecordTypeId = trainingProviderRecordTypeId
        );
        insert trainingsProvider;

        Product2 training = new Product2(
            Name = 'Test training',
            Start__c = Datetime.now().addHours(48).addMinutes(5),
            End__c = Datetime.now().addHours(48).addMinutes(10),
            Provider__c = trainingsProvider.Id,
            RecordTypeId = trainingRecordTypeId
        );
        insert training;

        Account attendee = new Account(
            LastName = 'Test attendee',
            PersonEmail = 'test.attendee@test.com',
            RecordTypeId = attendeeRecordTypeId
        );
        insert attendee;

        Asset asset = new Asset(
            Name = 'Test asset',
            Product2Id = training.Id,
            AccountId = attendee.Id
        );
        insert asset;

        Event trainingEvent = [
            SELECT Id 
            FROM Event 
            LIMIT 1
        ];

        Test.startTest();

        System.schedule('Test schedule class', '0 35 11 ? 6 3', new SendEventReminderSchedulable(trainingEvent.Id));
        
        Test.stopTest();
    }

}
