export const trackAmplitudeEvent = (eventName, options = null) => {
    const amplitude = window.amplitude;
    if (amplitude) {
        amplitude.logEvent(eventName, options);
    }
}

/**
 * Log Global Search Events 
 */
export const logClickEvents = () => {
    window.onclick = (event) => {
        let clickedSearch =  event.target.innerText.includes('Search');
       
        if (clickedSearch) {
            trackAmplitudeEvent('Search Event', {
                type: 'Click on global search'
            });
        } 

        // Just for test
        let clickedFavorites = event.target.innerText === 'Favorites list';
        let clickedHelp = event.target.innerText === 'Salesforce Help';
        if (clickedFavorites) {
            trackAmplitudeEvent('Search Event', {type: 'Click on favorites'});
        }
        if (clickedHelp) {
            trackAmplitudeEvent('Search Event', {type: 'Click on Salesforce Help'});
        }
    }
}