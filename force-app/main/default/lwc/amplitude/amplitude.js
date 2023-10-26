export const trackAmplitudeEvent = (eventName, options = null) => {
    const amplitude = window.amplitude;
    if (amplitude) {
        amplitude.logEvent(eventName, options);
    }
}