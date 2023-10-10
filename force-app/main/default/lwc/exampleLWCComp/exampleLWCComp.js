import { LightningElement } from 'lwc';
import {trackAmplitudeEvent} from 'c/amplitude'



export default class ExampleLWCComp extends LightningElement {

    handleClick() {
        trackAmplitudeEvent('Example LWC event');
    }
}