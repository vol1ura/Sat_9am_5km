//= require arctic_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require active_admin/searchable_select

$(document).ready(function () {
  $('.datepicker').datepicker({
    firstDay: 1, // Monday
    dateFormat: 'yy-mm-dd',
    showAnim: 'slideDown'
  });


  const originalAddEventListener = EventTarget.prototype.addEventListener;
  EventTarget.prototype.addEventListener = function (type, listener, options) {
    if (type === 'click' && listener.name === 'sidebarToggle') {
      const wrappedListener = function (e) {
        try {
          listener.apply(this, arguments);
        } catch (error) {
          if (error.message.includes('insideSection is null') || error.message.includes('insideSection is undefined')) {
            console.warn('Suppressed Arctic Admin sidebar error:', error);
            // Fallback: Toggle sidebar manually
            const sidebar = document.querySelector('#sidebar');
            if (sidebar) {
              sidebar.classList.toggle('active_sidebar'); // Try common class
              document.body.classList.toggle('active_sidebar'); // Try body class
            }
          } else {
            throw error;
          }
        }
      };
      return originalAddEventListener.call(this, type, wrappedListener, options);
    }
    return originalAddEventListener.call(this, type, listener, options);
  };
});
