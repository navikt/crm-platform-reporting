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

export function logButtonEvent(eventType, label, contentType, component, section, messageType = null) {
    logAmplitudeEvent(eventType, {
        komponent: component,
        seksjon: section,
        label: label,
        målgruppe: 'privatperson',
        innholdstype: contentType,
        meldingstype: messageType
    });
}

export function getComponentName(className) {
    return className?.constructor.name;
}
