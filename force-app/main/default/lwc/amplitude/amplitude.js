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

// Functions related to logging events for Innboks
export const AnalyticsEvents = {
    NAVIGATION: 'navigere',
    ACC_EXPAND: 'accordion åpnet',
    ACC_COLLAPSE: 'accordion lukket',
    MODAL_OPEN: 'modal åpnet',
    MODAL_CLOSE: 'modal lukket',
    FORM_STEP_COMPLETED: 'Skjemassteg fullført',
    FORM_COMPLETED: 'Skjema fullført'
};

export function logAmplitudeEvent(eventName, eventData) {
    const origin = 'crm-innboks';
    const analytics = window.dekoratorenAmplitude;
    if (analytics) {
        analytics({ eventName, origin, eventData });
    }
}

export function changeParameter(key, value) {
    const message = {
        source: 'decoratorClient',
        event: 'params',
        payload: { [key]: value }
    };
    window.postMessage(message, window.location.origin);
}

const waitForRetry = async () =>
    // eslint-disable-next-line @lwc/lwc/no-async-operation, @locker/locker/distorted-window-set-timeout
    new Promise((resolve) => setTimeout(resolve, 500));

export async function validateAmplitudeFunction(retries = 5) {
    if (typeof window.dekoratorenAmplitude === 'function') {
        return Promise.resolve(true);
    }

    if (retries === 0) {
        return Promise.resolve(false);
    }

    await waitForRetry();

    return validateAmplitudeFunction(retries - 1);
}

export function logNavigationEvent(contentType, component, section, destination, linkText) {
    logAmplitudeEvent(AnalyticsEvents.NAVIGATION, {
        komponent: component,
        lenkegruppe: 'innboks lenker',
        seksjon: section,
        destinasjon: destination,
        lenketekst: linkText,
        målgruppe: 'privatperson',
        innholdstype: contentType
    });
}

export function logAccordionEvent(isOpen, title, contentType, component) {
    logAmplitudeEvent(isOpen ? AnalyticsEvents.ACC_EXPAND : AnalyticsEvents.ACC_COLLAPSE, {
        tittel: title,
        komponent: component,
        målgruppe: 'privatperson',
        innholdstype: contentType
    });
}

export function logModalEvent(isOpen, title, contentType, component, section) {
    logAmplitudeEvent(isOpen ? AnalyticsEvents.MODAL_OPEN : AnalyticsEvents.MODAL_CLOSE, {
        tittel: title,
        komponent: component,
        seksjon: section,
        målgruppe: 'privatperson',
        innholdstype: contentType
    });
}

export function logButtonEvent(eventType, label, contentType, component, section) {
    logAmplitudeEvent(eventType, {
        komponent: component,
        seksjon: section,
        label: label,
        målgruppe: 'privatperson',
        innholdstype: contentType
    });
}
