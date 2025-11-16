import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { url: String };
  static targets = ['input', 'hidden', 'results'];
  static timeout = null;

  search(event) {
    if (this.inputTarget.value.length < 3) {
      this.closeAutoComplete();
      return;
    }
    this.handle_choice(event);
  }

  select(event) {
    this.selectAthlete(event.target);
  }

  handle_choice(event) {
    const current_choice = this.resultsTarget.querySelector('li.active');
    if (event.which === 40) {
      const next_item = current_choice ? current_choice.nextElementSibling : this.resultsTarget.querySelector('li:first-child');
      if (next_item) {
        next_item.classList.add('active');
        current_choice?.classList.remove('active');
      }
    } else if (event.which === 38) {
      if (!current_choice) return;
      current_choice.previousElementSibling?.classList.add('active');
      current_choice.classList.remove('active');
    } else if (event.which === 13) {
      event.preventDefault();
      if (current_choice) this.selectAthlete(current_choice);
    } else if (event.which === 27) {
      this.closeAutoComplete();
    } else {
      this.handle_search();
    }
  }

  handle_search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      fetch(`${this.urlValue}?q=${encodeURIComponent(this.inputTarget.value)}`)
        .then(response => response.json())
        .then(data => this.fillDropDown(data.athletes));
    }, 350);
  }

  fillDropDown(athletes) {
    this.resultsTarget.innerHTML = '';
    athletes.forEach((athlete, i) => {
      if (i >= 10) return;
      const list_item = `<li class="list-group-item" athlete_id="${athlete.id}" name="${athlete.name}"><span class="badge bg-secondary">A${athlete.code}</span> ${athlete.name}${this.additionalData(athlete)}</li>`;
      this.resultsTarget.insertAdjacentHTML('beforeend', list_item);
    });
  }

  additionalData(athlete) {
    const data = athlete.home_event || athlete.club;
    return data ? ` (${data})` : '';
  }

  closeAutoComplete() {
    this.resultsTarget.innerHTML = '';
  }

  selectAthlete(item) {
    this.hiddenTarget.value = item.getAttribute('athlete_id');
    this.inputTarget.value = item.getAttribute('name');
    this.closeAutoComplete();
  }
}
