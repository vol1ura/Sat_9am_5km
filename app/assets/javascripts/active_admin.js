//= require arctic_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require active_admin/searchable_select
//= require admin/results_drag

$(document).ready(function() {
  $('.datepicker').datepicker(
    {
    firstDay: 1, // Monday
    dateFormat: 'yy-mm-dd',
    showAnim: 'slideDown'
  });
});
