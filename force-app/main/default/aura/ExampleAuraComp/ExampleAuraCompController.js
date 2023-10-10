({
    handleClick : function(component, event, helper) {
        var amplitude = component.find("amplitude");
		amplitude.trackAmplitudeEvent('Aura event');
    }
})
