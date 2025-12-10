//= require active_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require active_admin/searchable_select

$(document).ready(function () {
  $('.datepicker').datepicker(
    {
      firstDay: 1, // Monday
      dateFormat: 'yy-mm-dd',
      showAnim: 'slideDown'
    });
});

function showConfirmModal(formId, message) {
  var modalId = formId === 'event_csv_form' ? 'confirm_modal_event' : 'confirm_modal_volunteers';
  var messageId = formId === 'event_csv_form' ? 'confirm_modal_event_message' : 'confirm_modal_volunteers_message';

  document.getElementById(messageId).textContent = message;
  document.getElementById(modalId).style.display = 'flex';
}

function hideConfirmModal(formId) {
  var modalId = formId === 'event_csv_form' ? 'confirm_modal_event' : 'confirm_modal_volunteers';
  document.getElementById(modalId).style.display = 'none';
}

function submitConfirmedForm(formId) {
  hideConfirmModal(formId);
  document.getElementById(formId).submit();
}
