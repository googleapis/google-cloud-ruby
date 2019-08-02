---
---
var jsondocTypes = {{ site.data.jsondoc_types | jsonify }};
var forwarder = new JsondocForwarder(null, "/google-cloud-ruby/", null, jsondocTypes);
var forwardUrl = forwarder.resolve(window.location.href);

var currentUrl = forwardUrl ? forwardUrl : window.location.href;

var gemData = {{ site.data.jsondoc_types | jsonify }};
var devsiteForwarder = new DevsiteForwarder(gemData);
var newUrl = devsiteForwarder.getDevsiteUrl(currentUrl);

if (newUrl !== devsiteForwarder.noEndSlash(window.location.href)) {
    window.location.href = newUrl;
}
