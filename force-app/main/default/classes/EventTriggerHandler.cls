public class EventTriggerHandler extends TriggerHandler {

    Id trainingEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId();
    
    public override void afterInsert() {
        for(Event newEvent : (List<Event>) Trigger.new) {
            if(newEvent.RecordTypeId != trainingEventRecordTypeId) {
                continue;
            }

            Datetime sendReminderDatetime = newEvent.StartDateTime.addHours(-48);

            String cronExpressionUnformatted = '0 {0} {1} {2} {3} ? {4}';
            String cronExpressionFormated = String.format(cronExpressionUnformatted, new List<String> {
                String.valueOf(sendReminderDatetime.minute()),
                String.valueOf(sendReminderDatetime.hour()),
                String.valueOf(sendReminderDatetime.day()),
                String.valueOf(sendReminderDatetime.month()),
                String.valueOf(sendReminderDatetime.year())
            });

            String jobName = 'Job to send reminder for event ' + newEvent.Related_To_Name__c;

            System.schedule(jobName, cronExpressionFormated, new SendEventReminderSchedulable(newEvent.Id));
        }
    }

}
