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
    // Leave for TOC until devsite has something similar.
    if (currentUrl.replace("google-cloud-ruby", "").indexOf(key) !== -1) {
        var newUrl = "https://googleapis.dev/ruby/" + redirectMap[key];
        var pathname =  window.location.href.split(key).slice(-1)[0];

        // Add "/latest" to URL if there is no version.
        var regex = /[^/]/;
        if (!regex.test(pathname)) {
            pathname = "/latest";
        }
        newUrl += pathname;

        window.location.href = newUrl;
        wasRedirected = true;
        return;
    }
});

if (forwardUrl && !wasRedirected) window.location.href = forwardUrl;
