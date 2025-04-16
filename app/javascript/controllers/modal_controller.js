import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  // Called when the controller is connected to the DOM
  connect() {
    // You can add setup logic here if needed, e.g., for ESC key closing
    // console.log("Modal controller connected")
  }

  // Action to close the modal
  close(event) {
    // Prevent default link behavior if called from a link
    if (event) {
      event.preventDefault();
    }

    // Remove the modal element from the DOM
    // Assumes the controller is attached to the outermost div of the modal
    this.element.remove();

    // Optionally, you could clear the turbo-frame instead:
    // const frame = document.getElementById("modal")
    // if (frame) {
    //   frame.innerHTML = ""
    // }
  }

  // Optional: Close modal on ESC key press
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}
