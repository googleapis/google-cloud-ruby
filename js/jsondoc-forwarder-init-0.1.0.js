---
---
var jsondocTypes = {{ site.data.jsondoc_types | jsonify }};
var forwarder = new JsondocForwarder(null, "/google-cloud-ruby/", null, jsondocTypes);
var forwardUrl = forwarder.resolve(window.location.href);

var currentUrl = forwardUrl ? forwardUrl : window.location.href;
currentUrl = currentUrl.replace("google-cloud-ruby", "ruby");

var newUrl = "https://googleapis.dev/ruby/" + redirectMap[key];
var pathname = currentUrl.split("google-cloud-ruby/").slice(-1)[0];
var regex = /[^/]/;

if (!regex.test(pathname)) {
    pathname += "/latest";
}

newUrl += pathname;
window.location.href = newUrl;
