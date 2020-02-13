global class UserAdoptionSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        UserAdoptionService.insertReportingDataLastWeek();
    }
}