---
---
var jsondocTypes = {{ site.data.jsondoc_types | jsonify }};
var forwarder = new JsondocForwarder(null, "/google-cloud-ruby/", null, jsondocTypes);
var forwardUrl = forwarder.resolve(window.location.href);
if (forwardUrl) window.location.href = forwardUrl;
