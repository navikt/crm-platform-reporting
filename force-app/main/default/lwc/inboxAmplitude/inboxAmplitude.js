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
        analytics({ eventName, origin, eventData: eventData || {} });
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
 * Logs a filter selection event.
 * @param {string} category - The category of the selected filter.
 * @param {string} filterName - The name of the selected filter option.
 * @param {string} component
 * @param {string} section
 */
export function logFilterEvent(category, filterName, component, section) {
    logAmplitudeEvent(AnalyticsEvents.FILTER, {
        kategori: category,
        filternavn: filterName,
        komponent: component,
        seksjon: section,
        målgruppe: 'privatperson'
    });
}

/**
 * Sends page type and page theme parameters.
 * @param {string} pageType - The type of page, e.g., "Skriv til oss" or "Beskjed til oss".
 * @param {string} pageTheme - The category for the STO or BTO, e.g. "Familie og barn"
 */
export function setDecoratorParams(pageType, pageTheme) {
    window.postMessage({
        source: 'nksInnboks',
        event: 'params',
        payload: { pageType, pageTheme }
    });
}

/**
 * Sends a list of breadcrumbs.
 * @param {Array<Object>} breadcrumbs - An array of breadcrumb objects, each with the format: { url: "/test", title: "Test" }.
 */
export function updateBreadcrumbs(breadcrumbs) {
    if (Array.isArray(breadcrumbs) && breadcrumbs.every((b) => b.url && b.title)) {
        window.postMessage({ source: 'decoratorClient', event: 'params', payload: { breadcrumbs } });
    }
}

/**
 * Converts a component's `localName` (e.g., "c-test-component") into camelCase.
 * @param {string} localName - The local name of the component, typically in the form of
 *                             "namespace-component-name" (e.g., "c-test-component").
 * @returns {string} The component name in camelCase format (e.g., "testComponent").
 */
export function getComponentName(localName) {
    return localName
        .split('-')
        .slice(1)
        .reduce((a, b) => a + b.charAt(0).toUpperCase() + b.slice(1));
}
