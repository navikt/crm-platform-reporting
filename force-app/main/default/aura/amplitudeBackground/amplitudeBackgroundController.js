({
    doInit: function (component) {
        component.set('v.recordIdMap', new Map()); // Setting recordId anonymization map as a component attribute
    },

    onTabFocused: function (component, event, helper) {
        helper.handleTabFocused(component, event, helper);
    },

    onLogMessage: function (component, message, helper) {
        helper.handleLogMessage(component, message, helper);
    },

    reloadAmplitude: function (component, event, helper) {
        helper.loadAmplitude(component);
    }
});
