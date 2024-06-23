//= require active_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require active_admin/searchable_select

$(document).ready(function() {
  $('.datepicker').datepicker(
    {
    firstDay: 1,  // Monday
    dateFormat: 'yy-mm-dd',
    showAnim: 'slideDown'
  });
});
