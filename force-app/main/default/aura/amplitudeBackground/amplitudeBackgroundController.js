({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAmplitudeKey");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.amplitude.init(response.getReturnValue(), '', {
                    apiEndpoint: 'amplitude.nav.no/collect',
                    serverZone: 'EU',
                    saveEvents: false,
                    includeUtm: true,
                    batchEvents: false,
                    includeReferrer: true,
                    defaultTracking: {
                        pageViews: false,
                      },
                });
            }
        });
        $A.enqueueAction(action);
    }
})
