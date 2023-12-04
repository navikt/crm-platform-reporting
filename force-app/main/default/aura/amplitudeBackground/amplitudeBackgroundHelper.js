({
    handleTabEvent: function (component, event, helper, tabActionType) {
        const currentTabId = event.getParam('currentTabId'); // On focus
        const tabId = event.getParam ('tabId'); // On close / create
        const activeTabId = tabId == null ? currentTabId : tabId;
        if (activeTabId == null) {
            return;
        }
        let recordId;
        let objectToLog = {};
        component.set('v.recordId', null); // Reset
        // If tab info already exists in map or tab is closed -> do not invoke WorkSpace API
        if (helper.getTabMapValue(component, activeTabId) || tabActionType === 'Tab closed') {
            helper.sendToAmplitude(component, helper, tabActionType, activeTabId, component.get('v.tabMap').get(activeTabId));
            if (tabActionType === 'Tab closed') {
                helper.deleteTabMapValue(component, activeTabId);
            }
            return;
        }
        let workspaceAPI = component.find('workspace');
        workspaceAPI
            .getTabInfo({
                tabId: activeTabId
            })
            .then(function (response) {
                switch (response.pageReference.type) {
                    case 'standard__recordPage':
                        // Record view
                        objectToLog = {
                            isSubtab: response.isSubtab,
                            tabType: 'Record Page',
                            record: (recordId = response.recordId),
                            objectApiName: response.pageReference.attributes.objectApiName
                        };
                        break;

                    case 'standard__objectPage':
                        // List View / Create new record -  har attributes.actionName: 'List', Create har actionName 'new'
                        objectToLog = {
                            isSubtab: response.isSubtab,
                            tabType:
                                response.pageReference.attributes.actionName === 'new'
                                    ? 'Create New Record'
                                    : 'List View',
                            objectApiName: response.pageReference.attributes.objectApiName
                        };
                        break;

                    case 'standard__recordRelationshipPage':
                        //  Related list
                        objectToLog = { isSubtab: response.isSubtab, type: 'Related List' };
                        objectToLog = Object.assign(objectToLog, response.pageReference.attributes); // Spread operator is not supported so Object.assign does the job.
                        delete Object.assign(objectToLog, { ['record']: objectToLog['recordId'] })['recordId']; // Rename key from recordId to record so Proxy does not remove the attribute
                        recordId = objectToLog.record; // Set recordId var for logMessage defaulting
                        break;

                    case 'standard__navItemPage':
                        // A page that displays the content mapped to a custom tab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs are supported.
                        objectToLog = {
                            isSubtab: response.isSubtab,
                            tabType: 'Lightning Tab',
                            record: (recordId = response.pageReference.state.ws.split('/')[4]),
                            apiName: response.pageReference.attributes.apiName
                        };
                        break;

                    case 'standard__directCmpReference':
                        // Global search result
                        objectToLog = {
                            isSubtab: response.isSubtab,
                            tabType: 'Global Search',
                            appName: response.pageReference.attributes.attributes.context.debugInfo.appName,
                            scope: response.pageReference.attributes.attributes.scopeMap.label
                        };
                        break;

                    default:
                        objectToLog = {
                            isSubtab: response.isSubtab,
                            tabType: 'Unknown Type ' + response.pageReference.type,
                            record: (recordId = response.recordId),
                            objectApiName: response.pageReference.attributes
                        };
                }
                component.set('v.recordId', recordId); // Set current recordId in case it is not sent in logMessage to have fallback
                helper.sendToAmplitude(component, helper, tabActionType, activeTabId, objectToLog);
            });
    },

    handleLogMessage: function (component, message, helper) {
        const eventType = message.getParam('eventType');
        const objectToLog = Object.assign({}, message.getParam('properties'));
        objectToLog.record =
            message.getParam('recordId') === null || message.getParam('recordId') === undefined
                ? component.get('v.recordId')
                : message.getParam('recordId');
        helper.sendToAmplitude(component, helper, eventType, null, objectToLog);
    },

    sendToAmplitude: function (component, helper, eventType, tabId, objectToLog) {
        objectToLog.record = helper.anonymizeRecordId(component, objectToLog.record);
        helper.setTabMapValue(component, helper, tabId, objectToLog);
        console.log('tabId: ', tabId);
        console.log('eventType: ', eventType);
        console.log('tabMap: ', component.get('v.tabMap'));
        console.log('tabMap value: ', JSON.stringify(component.get('v.tabMap').get(tabId)));
        component.find('amplitude').trackAmplitudeEvent(eventType, objectToLog);
    },

    anonymizeRecordId: function (component, recordId) {
        if (recordId == null || recordId === '') {
            return '';
        }
        const recordIdMap = component.get('v.recordIdMap'); // Accessing the map from the component attribute
        if (recordIdMap.get(recordId) == undefined) {
            recordIdMap.set(recordId, crypto.randomUUID());
            component.set('v.recordIdMap', recordIdMap);
        }
        return recordIdMap.get(recordId);
    },

    setTabMapValue: function (component, helper, tabId, objectToLog) {
        if (helper.getTabMapValue(component, tabId) || tabId == null) { // Exists in map or no tabId
            return;
        }
        const tabMap = component.get('v.tabMap');
        tabMap.set(tabId, objectToLog);
        component.set('v.tabMap', tabMap);
    },

    getTabMapValue: function (component, tabId) {
        if (tabId == null) {
            return false;
        }
        const tabMap = component.get('v.tabMap');
        if (tabMap.get(tabId) == null) {
            return false; // tabId not in tabMap
        }
        return true;
    },

    deleteTabMapValue: function (component, tabId) {
        const tabMap = component.get('v.tabMap');
        tabMap.delete(tabId);
        component.set('v.tabMap', tabMap);
    },

    loadAmplitude: function (component) {
        var action = component.get('c.getAmplitudeKey');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'ERROR') {
                component
                    .find('loggerUtility')
                    .logError(
                        'NKS',
                        'Amplitude',
                        response.getError(),
                        'Kunne ikke laste Amplitude',
                        component.get('v.recordId')
                    );
            }
            if (state === 'SUCCESS') {
                console.log('Loading Amplitude...');
                try {
                    window.amplitude.init(response.getReturnValue(), '', {
                        apiEndpoint: 'amplitude.nav.no/collect',
                        serverZone: 'EU',
                        saveEvents: false,
                        includeUtm: true,
                        batchEvents: false,
                        includeReferrer: true,
                        defaultTracking: {
                            pageViews: false
                        },
                        trackingOptions: {
                            city: false,
                            ip_address: false
                        }
                    });
                } catch (err) {
                    console.error('Error happened when loading Amplitude: ', JSON.stringify(err));
                }
            }
        });
        $A.enqueueAction(action);
    }
});
