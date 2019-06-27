---
---
var jsondocTypes = {{ site.data.jsondoc_types | jsonify }};
var forwarder = new JsondocForwarder(null, "/google-cloud-ruby/", null, jsondocTypes);
var forwardUrl = forwarder.resolve(window.location.href);

var currentUrl = forwardUrl ? forwardUrl : window.location.href;
var wasRedirected = false;

var redirectMap = {{ site.data.devsite_redirects | jsonify }};
Object.keys(redirectMap).forEach(key => {
    // Redirect to devsite for all gem docs.
    // Leave for TOC until devsite has something similar;
    if (currentUrl.indexOf(key) !== -1) {
        var newURL = "https://googleapis.dev/ruby/" + redirectMap[key];
        newURL += window.location.href.split(key).slice(-1)[0];
        window.location.href = newURL;
        wasRedirected = true;
        return;
    }
});

if (forwardUrl && !wasRedirected) window.location.href = forwardUrl;
