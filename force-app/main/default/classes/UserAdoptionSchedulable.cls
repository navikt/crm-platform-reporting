global class UserAdoptionSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        UserAdoptionService.insertReportingData(Date.today().addDays(-1));
        HOT_ServiceAppointmentReportController.upsertReportingData(Date.today().addDays(-1), Date.today());
    }
}