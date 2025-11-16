//= require arctic_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require active_admin/searchable_select

$(document).ready(function() {
  $('.datepicker').datepicker(
    {
    firstDay: 1, // Monday
    dateFormat: 'yy-mm-dd',
    showAnim: 'slideDown'
  });
});


document.addEventListener('DOMContentLoaded', function() {

  if (!/\/admin\/activities\/\d+\/results/.test(window.location.pathname)) return;

  if ('ontouchstart' in window || (navigator.maxTouchPoints && navigator.maxTouchPoints > 0) || (window.matchMedia && window.matchMedia('(pointer: coarse)').matches)) {
    console.debug('Reorder disabled on touch devices');
    return;
  }
  if (typeof Sortable === 'undefined') return; // require SortableJS

  var table = document.querySelector('table.index_table');
  if (!table) return;
  var tbody = table.querySelector('tbody');
  if (!tbody) return;


  var transparentCanvas = (function(){
    try {
      var c = document.createElement('canvas');
      c.width = 1; c.height = 1;
      var ctx = c.getContext && c.getContext('2d');
      if (ctx) ctx.clearRect(0,0,1,1);
      return c;
    } catch (e) { return null; }
  })();


  tbody.querySelectorAll('tr').forEach(function(tr) {

    try { tr.setAttribute('draggable', 'true'); } catch (e) {}
    var posCell = tr.querySelector('td.col-position');
    if (posCell && !posCell.querySelector('.drag-handle')) {
      var span = document.createElement('span');
      span.className = 'drag-handle';
      span.style.cursor = 'move';
      span.style.marginRight = '6px';
      span.textContent = '↕';
      posCell.insertBefore(span, posCell.firstChild);
    }
  });


  tbody.addEventListener('dragstart', function(e) {
    try {
      var dt = e.dataTransfer;
      if (!dt) return;

      if (dragImageEl && typeof dt.setDragImage === 'function') {
        dt.setDragImage(dragImageEl, 10, 10);
      } else if (transparentCanvas && typeof dt.setDragImage === 'function') {
        dt.setDragImage(transparentCanvas, 0, 0);
      }
    } catch (err) {
      // swallow - non-fatal
      console.debug('dragstart setDragImage failed', err);
    }
  }, true);


  var originalRows = Array.from(tbody.querySelectorAll('tr'));
  var athleteSnapshot = {};
  var dragImageEl = null;
  var sortable = new Sortable(tbody, {
    handle: '.drag-handle',
    animation: 150,
    ghostClass: 'sortable-ghost',
    onStart: function (evt) {
      try {

        athleteSnapshot = {};
        originalRows = Array.from(tbody.querySelectorAll('tr'));
        originalRows.forEach(function(row) {
          var id = row.dataset.id || row.dataset.resourceId || row.getAttribute('data-id') || row.getAttribute('data-resource-id');
          if (!id) {
            var cb = row.querySelector('input[type=checkbox]');
            if (cb && cb.value) id = cb.value;
          }
          if (!id) return;
          var athleteCell = row.querySelector('td.col-athlete') || row.querySelector('td[data-col="athlete"]');
          athleteSnapshot[id] = {
            html: athleteCell ? athleteCell.innerHTML : '',
            athleteId: athleteCell ? (athleteCell.getAttribute('data-athlete-id') || athleteCell.dataset.athleteId) : null
          };
        });


        var nativeEvent = evt.originalEvent || evt;
        if (nativeEvent && nativeEvent.dataTransfer && typeof nativeEvent.dataTransfer.setDragImage === 'function') {
          var dragged = evt.item || evt.target;
          var posCell = dragged && (dragged.querySelector('td.col-position') || dragged.querySelector('td[data-col="position"]'));
          var athleteCell = dragged && (dragged.querySelector('td.col-athlete') || dragged.querySelector('td[data-col="athlete"]'));
          dragImageEl = document.createElement('div');
          dragImageEl.style.position = 'absolute';
          dragImageEl.style.left = '-9999px';
          dragImageEl.style.top = '-9999px';
          dragImageEl.style.background = 'white';
          dragImageEl.style.border = '1px solid rgba(0,0,0,0.08)';
          dragImageEl.style.padding = '6px';
          dragImageEl.style.fontFamily = 'inherit';
          var posClone = posCell ? posCell.cloneNode(true) : document.createElement('span');
          var athClone = athleteCell ? athleteCell.cloneNode(true) : document.createElement('span');
          posClone.style.display = 'inline-block';
          posClone.style.marginRight = '8px';
          dragImageEl.appendChild(posClone);
          dragImageEl.appendChild(athClone);
          document.body.appendChild(dragImageEl);
          nativeEvent.dataTransfer.setDragImage(dragImageEl, 10, 10);
        }
      } catch (e) {
        console.debug('onStart snapshot failed', e);
      }
    },
    onEnd: function (evt) {

      try { if (dragImageEl && dragImageEl.parentNode) dragImageEl.parentNode.removeChild(dragImageEl); dragImageEl = null; } catch (e) {}

      var order = Array.from(tbody.querySelectorAll('tr')).map(function(row) {

        var id = row.dataset.id || row.dataset.resourceId || row.getAttribute('data-id') || row.getAttribute('data-resource-id');
        if (!id) {
          var cb = row.querySelector('input[type=checkbox]');
          if (cb && cb.value) id = cb.value;
        }
        return id;
      }).filter(Boolean);
      if (!order.length) return;

      try {

        originalRows.forEach(function(r) { tbody.appendChild(r); });


        originalRows.forEach(function(row, idx) {
          var targetAthleteCell = row.querySelector('td.col-athlete') || row.querySelector('td[data-col="athlete"]');
          var srcId = order[idx];
          if (!srcId) return;
          var snap = athleteSnapshot[srcId];
          if (targetAthleteCell && snap) {
            targetAthleteCell.innerHTML = snap.html;
            if (snap.athleteId) {
              try { targetAthleteCell.setAttribute('data-athlete-id', snap.athleteId); } catch (e) {}
            }
          }
        });
      } catch (e) {
        console.debug('apply visual swap failed', e);
      }

      var csrf = document.querySelector('meta[name=csrf-token]')?.getAttribute('content') || (window.jQuery && $('meta[name=csrf-token]').attr('content'));
      console.debug('reorder: sending', order);

      var onError = function(status, msg) {
        alert((msg || 'Не удалось переупорядочить позиции') + ' (' + status + ')');
      };

      if (window.jQuery && typeof $.ajax === 'function') {
        $.ajax({
          url: window.location.pathname + '/reorder',
          type: 'POST',
          data: { order: order },
          headers: { 'X-CSRF-Token': csrf },
          success: function(resp) { console.debug('Reorder saved', resp); },
          error: function(xhr, status, err) {
            var msg = 'Не удалось переупорядочить позиции';
            try { var body = xhr && xhr.responseJSON; if (body && body.error) msg = body.error; } catch (e) {}
            onError(status, msg);
          }
        });
      } else {
        var params = new URLSearchParams();
        order.forEach(function(id) { params.append('order[]', id); });
        fetch(window.location.pathname + '/reorder', {
          method: 'POST',
          credentials: 'same-origin',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-Token': csrf },
          body: params.toString()
        }).then(function(resp) {
          if (resp.ok) return resp.text().then(function(t) { console.debug('Reorder saved'); });
          return resp.text().then(function(txt){ onError(resp.status, txt || resp.statusText); });
        }).catch(function(err) { onError('network', 'Ошибка сети при переупорядочивании'); });
      }
    }
  });
});
