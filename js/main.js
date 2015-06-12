---
---
$('.nav-current').click(function(){
  $('.main-nav').toggleClass('open');
});

$('.faq-btn').click(function(){
	$(this).toggleClass('open');
});

// Releases Dropdown
$(document).ready(function() {
  var meta = $('.side-nav--meta');
  if (meta) {
    // Add the release switcher HTML
    meta.prepend($.parseHTML('<div id="release-nav">Browsing Version <select>' +
      {% for release in site.data.releases %}
        '<option value="/gcloud-ruby/docs/{{ release.version }}">{{ release.version }}</option>' +
      {% endfor %}
      '<option value="/gcloud-ruby/docs/master">master</option>' +
      '</select></div>'));
    // Select the current option
    var switcher = meta.find('#release-nav').find('select');
    switcher.find('option').each(function(index,element) {
      if (window.location.pathname.startsWith(element.value)) {
        element.selected = true;
      }
    });
    // Navigate when selection is changed
    switcher.change(function() {
      window.location = this.value;
    });
  }
});
