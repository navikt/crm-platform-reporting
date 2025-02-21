import { createMessageContext, publish } from 'lightning/messageService';
import AMPLITUDE_CHANNEL from '@salesforce/messageChannel/amplitude__c';

export const trackAmplitudeEvent = (eventName, options = null) => {
    const amplitude = window.amplitude;
    if (amplitude) {
        amplitude.logEvent(eventName, options);
    }
};

let messageContext = createMessageContext();
export function publishToAmplitude(eventType, properties, recordId) {
    const message = {
        eventType,
        properties,
        recordId
    };
    publish(messageContext, AMPLITUDE_CHANNEL, message);
}
