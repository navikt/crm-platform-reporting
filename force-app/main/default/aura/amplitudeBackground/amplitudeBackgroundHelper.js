({
    handleTabFocused: function (component, event, helper) {
        console.log('onTabFocused');
        let focusedTabId = event.getParam('currentTabId');
        if (focusedTabId == null) {
            console.log('null');
            return;
        }
        let outputLog;
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo({
            tabId: focusedTabId
        }).then(function (response) {
            console.log(response);
            console.log(response.recordId);
            console.log(response.isSubtab);
            console.log(response.pageReference.type)
            switch (response.pageReference.type) {
                case 'standard__recordPage':
                    // Record view
                    outputLog = { isSubtab: response.isSubtab, recordId: response.recordId, type: 'Record page', objectApiName: response.pageReference.attributes.objectApiName }
                    break;
    
                case 'standard__objectPage':
                    // List View / Create new record -  har attributes.actionName: 'List', Create har actionName 'new'
                    outputLog = { isSubtab: response.isSubtab, type: response.pageReference.attributes.actionName === 'new' ? 'Create New Record' : 'List View', objectApiName: response.pageReference.attributes.objectApiName }
                    break;
    
                case 'standard__recordRelationshipPage': 
                    //  Related list
                    outputLog = { isSubtab: response.isSubtab, type: 'Related List' };
                    outputLog = Object.assign(outputLog, response.pageReference.attributes); // Spread operator is not supported so Object.assign does the job.
                    break;
    
                case 'standard__navItemPage':
                    // A page that displays the content mapped to a custom tab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs are supported.
                    outputLog = { isSubtab: response.isSubtab, recordId: response.pageReference.state.ws.split('/')[4], apiName: response.pageReference.attributes.apiName, type: 'Lightning Tab'}
                    break;
    
                default:
                    outputLog = { isSubtab: response.isSubtab, recordId: response.recordId, type: 'Unknown Type ' + response.pageReference.type, objectApiName: response.pageReference.attributes }
            }
            outputLog.recordId = helper.anonymizeRecordId(component, outputLog.recordId);
            console.log('outputLog: ', JSON.stringify(outputLog));
            component.find('amplitude').trackAmplitudeEvent('Tab focused', outputLog);
        });
    },

    logMessage : function(component, event, helper) {
        console.log('logMessage');
        let currentRecordId = event.getParam('recordId');
        let objectToLog = event.getParam('options');
        console.log('currentRecordId: ', currentRecordId);
        console.log('objectToLog: ', objectToLog);
        objectToLog.recordId = helper.anonymizeRecordId(component, currentRecordId);
        component.find('amplitude').trackAmplitudeEvent('Tab focused', objectToLog);
    },

    anonymizeRecordId : function(component, recordId) {
        console.log('anonymizeRecordId');
        console.log('recordId: ', recordId);
        if (recordId === undefined) {
            return null;
        }
        var recordIdMap = component.get('v.recordIdMap'); // Accessing the map from the component attribute
        console.log('recordIdMap: ', recordIdMap);
        console.log(typeof recordIdMap);
        if (recordIdMap.get(recordId) === undefined) {
            recordIdMap.set(recordId, crypto.randomUUID());
            component.set('v.recordIdMap', recordIdMap);
        }
        return recordIdMap.get(recordId);
    }
})