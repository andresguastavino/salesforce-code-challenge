public class SendEventReminderSchedulable implements Schedulable {

    Id eventId;
    Id attendeeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Attendee').getRecordTypeId();

    public SendEventReminderSchedulable(Id eventId) {
        this.eventId = eventId;
    }

    public void execute(SchedulableContext sc) {
        Event event = [
            SELECT WhatId, StartDateTime, Related_To_Name__c
            FROM Event 
            WHERE Id = :eventId
            AND WhatId != null
            LIMIT 1
        ];

        if(event.WhatId.getSObjectType() != Product2.SObjectType)
            return;

        List<Messaging.Email> emails = new List<Messaging.Email>();
        for(Asset attendee : [
            SELECT Account.Name, Account.PersonEmail
            FROM Asset
            WHERE Product2Id = :event.WhatId
            AND AccountId != null
            AND Account.PersonEmail != null 
            AND Account.Name != null
            AND Account.RecordTypeId = :attendeeRecordTypeId
        ]) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { attendee.Account.PersonEmail });
            email.setSubject('Registered to event '+event.Related_To_Name__c+' reminder');

            String emailBody = 
                '<h4>Greetings '+attendee.Account.Name+'!</h4>'+
                '<p>Hope you are doing great!</p>'+
                '<p>This is a reminder so you don\'t forget that you are registered to the training event <b>"'+event.Related_To_Name__c+'"</b> '+
                'that is taking place next '+event.StartDateTime.format('EEEE')+' '+event.StartDateTime.day()+'/'+event.StartDateTime.month()+' '+
                'at '+event.StartDateTime.hour()+':'+event.StartDateTime.minute()+'hs</p>'+
                '<p>Hope to see you there!</p>'+
                '<p>Regards,</p>'+
                '<p><b>Universal Training Inc</b></p>';

            email.setHtmlBody(emailBody);
            emails.add(email);
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

}
