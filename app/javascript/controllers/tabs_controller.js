import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { activeClass: String, inactiveClass: String }
  static targets = ["tabLink", "tabContent"]

  change(event) {
    event.preventDefault();

    const targetIndex = event.currentTarget.dataset.tabIndex;

    this.tabLinkTargets.forEach(link => {
      if (link.dataset.tabIndex === targetIndex) {
        link.className = this.activeClassValue;
      } else {
        link.className = this.inactiveClassValue;
      }
    });

    this.tabContentTargets.forEach(content => {
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
