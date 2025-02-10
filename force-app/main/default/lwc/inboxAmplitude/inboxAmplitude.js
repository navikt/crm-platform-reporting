export const AnalyticsEvents = {
    NAVIGATION: 'navigere',
    ACC_EXPAND: 'accordion åpnet',
    ACC_COLLAPSE: 'accordion lukket',
    MODAL_OPEN: 'modal åpnet',
    MODAL_CLOSE: 'modal lukket',
    FORM_STEP_COMPLETED: 'Skjemassteg fullført',
    FORM_COMPLETED: 'Skjema fullført',
    FILTER: 'filtervalg'
};

export function logAmplitudeEvent(eventName, eventData) {
    const origin = 'crm-innboks';
    const analytics = window.dekoratorenAmplitude;
    if (analytics) {
        analytics({ eventName, origin, eventData });
    }
}

export function logNavigationEvent(component, section, destination, linkText) {
    logAmplitudeEvent(AnalyticsEvents.NAVIGATION, {
        komponent: component,
        lenkegruppe: 'innboks lenker',
        seksjon: section,
        destinasjon: destination,
        lenketekst: linkText,
        målgruppe: 'privatperson'
    });
}

export function logAccordionEvent(isOpen, text, component) {
    logAmplitudeEvent(isOpen ? AnalyticsEvents.ACC_EXPAND : AnalyticsEvents.ACC_COLLAPSE, {
        tekst: text,
        komponent: component,
        målgruppe: 'privatperson'
    });
}

export function logModalEvent(isOpen, title, component, section) {
    logAmplitudeEvent(isOpen ? AnalyticsEvents.MODAL_OPEN : AnalyticsEvents.MODAL_CLOSE, {
        tittel: title,
        komponent: component,
        seksjon: section,
        målgruppe: 'privatperson'
    });
}

export function logButtonEvent(eventType, label, component, section, messageType = null) {
    logAmplitudeEvent(eventType, {
        komponent: component,
        seksjon: section,
        label: label,
        målgruppe: 'privatperson',
        meldingstype: messageType
    });
}

/**
 * @param {*} category text for filter which is used
 * @param {*} filterName text for alternative filter which is used
 * @param {*} component
 * @param {*} section
 */
export function logFilterEvent(category, filterName, component, section) {
    logAmplitudeEvent(AnalyticsEvents.FILTER, {
        kategory: category,
        filternavn: filterName,
        komponent: component,
        seksjon: section,
        målgruppe: 'privatperson'
    });
}

/**
 * Function to send pageType and pageTheme
 * @param {string} pageType pageType is a "Skriv til oss" or "Beskjed til oss"
 * @param {string} pageTheme pageTheme is category for STO or BTO
 */
export function setDecoratorParams(pageType, pageTheme) {
    window.postMessage({
        source: 'nksInnboks',
        event: 'params',
        payload: { pageType: pageType, pageTheme: pageTheme }
    });
}

/**
 * Function to send a list of breadcrumbs
 * @param {list} breadcrumbs breadcrumb should be sendt in form of a object as {url: "/test", title: "Test"}
 */
export function updateBreadcrumbs(breadcrumbs) {
    window.postMessage({ source: 'decoratorClient', event: 'params', payload: { breadcrumbs } });
}
