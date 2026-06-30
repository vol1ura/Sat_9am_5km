import '@popperjs/core';
import 'bootstrap';
import 'controllers';

import '@hotwired/turbo-rails';

// Turbo can repaint the page out from under an open Bootstrap modal: on
// back/forward navigation (turbo:before-cache) and on any broadcasted page
// refresh or stream render (turbo:before-render). Either one rewrites the
// modal's DOM straight to its hidden markup without going through Bootstrap's
// own hide() lifecycle, so its JS instance never learns the modal closed and
// the backdrop / body lock are left stuck. Force a real hide() first so
// Bootstrap's state and the DOM agree before Turbo touches anything.
function closeOpenModals() {
  document.querySelectorAll('.modal.show').forEach(el => {
    bootstrap.Modal.getInstance(el)?.hide();
  });
  document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
  document.body.classList.remove('modal-open');
  document.body.style.removeProperty('overflow');
  document.body.style.removeProperty('padding-right');
}

document.addEventListener('turbo:before-cache', closeOpenModals);
document.addEventListener('turbo:before-render', closeOpenModals);
document.addEventListener('turbo:before-stream-render', closeOpenModals);
