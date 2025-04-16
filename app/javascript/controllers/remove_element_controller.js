import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { delay: Number };

  connect() {
    if (this.hasDelayValue) {
      this.timeout = setTimeout(() => {
        this.remove();
      }, this.delayValue);
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  remove() {
    this.element.remove();
  }
}
