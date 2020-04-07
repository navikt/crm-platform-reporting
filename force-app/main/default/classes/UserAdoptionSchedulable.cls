global class UserAdoptionSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        UserAdoptionService.insertReportingData(Date.today().addDays(-1));
    }
}