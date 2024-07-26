import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { activeClass: String, inactiveClass: String }

  change(event) {
    event.preventDefault();

    const tabLinks = this.element.querySelectorAll('[data-tab-index]');
    const tabContents = this.element.querySelectorAll('[data-tabs-target="tab"]');
    const targetIndex = event.currentTarget.dataset.tabIndex;

    tabLinks.forEach(link => {
      if (link.dataset.tabIndex === targetIndex) {
        link.className = this.activeClassValue;
      } else {
        link.className = this.inactiveClassValue;
      }
    });

    tabContents.forEach(content => {
      if (content.dataset.tabIndex === targetIndex) {
        content.classList.remove('hidden');
        content.classList.add('block');
      } else {
        content.classList.remove('block');
        content.classList.add('hidden');
      }
    });
  }
}
