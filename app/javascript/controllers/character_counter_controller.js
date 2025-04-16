import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="character-counter"
export default class extends Controller {
  static targets = ["input", "count", "submit"];
  static values = { maxChars: { type: Number, default: 1000 } };

  connect() {
    this.updateCount();
  }

  updateCount() {
    const currentLength = this.inputTarget.value.length;
    this.countTarget.textContent = currentLength;

    const isEmpty = currentLength === 0;
    const exceedsLimit = currentLength > this.maxCharsValue;

    this.submitTarget.disabled = isEmpty || exceedsLimit;

    // Optional: Add visual feedback for exceeding the limit
    if (exceedsLimit) {
      this.countTarget.classList.add("text-red-500");
      this.inputTarget.classList.add("border-red-500");
    } else {
      this.countTarget.classList.remove("text-red-500");
      this.inputTarget.classList.remove("border-red-500");
    }
  }
}
