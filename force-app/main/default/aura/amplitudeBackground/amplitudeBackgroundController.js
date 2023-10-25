({
    doInit: function (component, event, helper) {
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
    onTabFocused: function (component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        //console.log(focusedTabId);
        if(focusedTabId == null) {
            console.log('Nullie');
            return;
        }

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo({
            tabId: focusedTabId
        }).then(function (response) {
            
            console.log('onTabFocused');
            console.log(response);
            console.log(response.recordId);
            console.log(response.isSubtab);
            let outputLog;
            const logEvent = 'Focused tab';
            console.log(response.pageReference.type)
            switch (response.pageReference.type) {
                case 'standard__recordPage':
                    outputLog = { isSubtab: response.isSubtab, recordId: response.recordId, type: 'Record page', objectApiName: response.pageReference.attributes.objectApiName}
                    break;

                case 'standard__objectPage':
                    //LIst view har attribute actionName: 'List', create har actionName 'new'
                    const pageType = response.pageReference.attributes.actionName === 'new' ? 'Create New Record' : 'List View';
                    outputLog = { isSubtab: response.isSubtab, type: pageType, objectApiName: response.pageReference.attributes.objectApiName}
                    break;
                    
                case 'standard__navItemPage':
                    //  response.pageReference.state.ws inneholder URL til parent tab (? teste det), så vi kan splite for å få ID.
                    outputLog = { isSubtab: response.isSubtab, apiName: response.pageReference.attributes.apiName, type: 'Lightning Tab'}
                    break;

                case 'standard__recordRelationshipPage':
                    //  Related list
                    outputLog = { isSubtab: response.isSubtab, type: 'Related List', ...response.pageReference.attributes}
                        
                    break;
                default:
                    outputLog = {isSubtab: response.isSubtab, recordId: response.recordId, type: 'Unknown Type ' + response.pageReference.type, objectApiName: response.pageReference.attributes}
            }
            console.log(JSON.stringify(outputLog));
        });
        // TODO: Anonymize recordId and put in map (do that in helper file)
        component.find('amplitude').trackAmplitudeEvent('Tab focused');
        console.log(event);
    },
    logMessage : function(component, event, helper) {
        // TODO: Anonymize recordId and put in map
        console.log('');
    }
})
