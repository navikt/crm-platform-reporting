({
    doInit: function (component) {
        component.set('v.recordIdMap', new Map()); // Setting recordId anonymization map as a component attribute
        component.set('v.tabMap', new Map()); // Map of tabIds because we cannot get info from WorkSpace API on a closed tab (apart from tab id)
    },

    onTabFocused: function (component, event, helper) {
        console.log('onTabFocused');
        helper.handleTabEvent(component, event, helper, 'Tab focused');
    },

    onTabCreated: function (component, event, helper) {
        console.log('onTabCreated');
        helper.handleTabEvent(component, event, helper, 'Tab created');
    },
    
    onTabClosed: function (component, event, helper) {
        console.log('onTabClosed');
        helper.handleTabEvent(component, event, helper, 'Tab closed');
    },

    onLogMessage: function (component, message, helper) {
        helper.handleLogMessage(component, message, helper);
    },

    reloadAmplitude: function (component, event, helper) {
        helper.loadAmplitude(component);
    }
});
