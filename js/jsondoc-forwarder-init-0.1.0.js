---
---
var jsondocTypes = {{ site.data.jsondoc_types | jsonify }};
var forwarder = new JsondocForwarder(null, "/google-cloud-ruby/", null, jsondocTypes);
var forwardUrl = forwarder.resolve(window.location.href);

var currentUrl = forwardUrl ? forwardUrl : window.location.href;

var newUrl = getDevsiteUrl(currentUrl);

if (noEndSlash(newUrl) !== noEndSlash(window.location.href)) {
    window.location.href = newUrl;
}

function getDevsiteUrl(url) {
    url = url.replace("master", "latest");
    var newUrl = "https://googleapis.dev/ruby/";
    var gem = findGem(url);
    if (!gem) {
        return url;
    }
    var version = findVersion(url);
    newUrl += noEndSlash(gem + "/" + version);
    if (!url.includes(version)) {
        return newUrl;
    }
    if (noEndSlash(url.substring(url.indexOf(version) + version.length)).length === 0) {
        return newUrl;
    }
    var tail = noEndSlash(url.split(version + "/").slice(-1)[0]);
    if (tail.match(/file\.\w+/) && !tail.endsWith(".html")) {
        tail = tail.replace(".md", "");
        tail += ".html"
    }
    return noEndSlash(newUrl + "/" + tail);
};

function findGem(url) {
    if (url.split("docs/").length > 1) {
        return url.split("docs/").slice(-1)[0].split("/")[0];
    }
    return "";
};

function findVersion(url) {
    regex = /(v\d+\.\d+\.\d+)/;
    if (url.match(regex)) {
        match = regex.exec(url);
        return match[0];
    }
    return "latest";
}

function noEndSlash(url) {
    var newUrl = url;
    while (newUrl.endsWith("/")) {
        newUrl = newUrl.slice(0, -1);
    }
    return newUrl;
}
