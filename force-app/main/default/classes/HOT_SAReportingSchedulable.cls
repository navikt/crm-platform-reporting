global class HOT_SAReportingSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        HOT_ServiceAppointmentReportController.upsertReportingData(Date.today().addDays(-1), Date.today());
    }
}
