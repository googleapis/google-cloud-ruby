---
---
{% capture header %}
{% include header.html %}
{% endcapture %}

$(document).ready(function() {
  var gem = location.pathname.split('/')[3];
  var version = location.pathname.split('/')[4];
  var releases = {{ site.data.releases | jsonify }};
  if (version == 'latest') {
    // Get the most recent version when viewing latest
    version = releases[gem][0];
    if (version == undefined) {
      // Use master when we don't have a release
      version = 'master'
    }
  }

  // Add gem links to breadcrumb
  $('#main #header #menu').prepend('<a href="/google-cloud-ruby/docs">Google Cloud gems</a> » <span class="title"><a href="/google-cloud-ruby/docs/' + gem + '">' + gem + '</a> <small>(' + version + ')</small></span><br>')
});
