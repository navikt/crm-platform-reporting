({
    doInit: function (component, event, helper) {
        component.set('v.recordIdMap', new Map()); // Setting recordId anonymization map as a component attribute
        var action = component.get("c.getAmplitudeKey");
        action.setCallback(this, function (response) {
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
    },

    onTabFocused: function(component, event, helper) {
        console.log('onTabFocused controller');
        helper.handleTabFocused(component, event, helper);
    }
})
