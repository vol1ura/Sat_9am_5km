import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['form', 'submitButton', 'loadingState', 'initialState', 'successState'];

  submit(event) {
    this.initialStateTarget.classList.add('d-none');
    this.loadingStateTarget.classList.remove('d-none');
    
    this.submitButtonTarget.disabled = true;

    setTimeout(() => {
      this.loadingStateTarget.classList.add('d-none');
      this.successStateTarget.classList.remove('d-none');
    }, 3000);
  }
}
