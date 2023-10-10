import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import AmplitudeScript from '@salesforce/resourceUrl/Amplitude';
import getAmplitudeKey from '@salesforce/apex/AmplitudeHelper.getAmplitudeKey';

export default class AmplitudeBackground extends LightningElement {
    connectedCallback() {
        console.log('Fist of the north star')
        getAmplitudeKey().then(value => {
            console.log(value);
            loadScript(this, AmplitudeScript + '/Amplitude.js').then(() => {
                window.amplitude.init(value, '', {
                    apiEndpoint: 'amplitude.nav.no/collect',
                    serverZone: 'EU',
                    saveEvents: false,
                    includeUtm: true,
                    batchEvents: false,
                    includeReferrer: true
                });
            });
        })
    }

}