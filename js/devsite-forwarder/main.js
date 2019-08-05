function DevsiteForwarder(gemData) {
  this.gems = Object.keys(gemData);

  this.noEndSlash = function(url) {
    var newUrl = url;
    while (newUrl.endsWith("/")) {
      newUrl = newUrl.slice(0, -1);
    }
    return newUrl;
  };

  this.getAnchor = function(url) {
    var lastWord = url
      .split("docs")
      .pop()
      .split("/")
      .pop();
    var anchor = "";
    if (lastWord.indexOf("#") !== -1) {
      lastWord = lastWord.split("#").pop();
      if (lastWord.length > 0) {
        anchor = this.noEndSlash("#" + lastWord);
      }
    }
    return anchor;
  };

  this.getGem = function(url) {
    var gem = "";
    for (var i = 0; i < this.gems.length; i++) {
      if (this.gems[i] === "google-cloud") {
        i++;
      }
      if (
        url.indexOf(this.gems[i]) !== -1 &&
        this.gems[i].length > gem.length
      ) {
        gem = this.noEndSlash(this.gems[i]);
      }
    }
    if (
      gem.length < 1 &&
      url
        .split("google-cloud-ruby")
        .pop()
        .indexOf("google-cloud") !== -1
    ) {
      gem = "google-cloud";
    }
    return gem;
  };

  this.getTail = function(url, gem, version, anchor) {
    var workingUrl = url.split(gem + "/").pop();
    var tailParts = [];
    workingUrl = workingUrl.split(version).pop();
    if (anchor.length > 0) {
      workingUrl = workingUrl.split(anchor).shift();
    }
    workingUrl = workingUrl.split("/");
    for (var i = 0; i < workingUrl.length; i++) {
      if (
        workingUrl[i].length > 0 &&
        workingUrl[i][0] === workingUrl[i][0].toUpperCase()
      ) {
        tailParts.push(workingUrl[i]);
      }
    }
    var lastWord = workingUrl.pop();
    if (lastWord.indexOf("file.") !== -1) {
      lastWord = lastWord
        .split("file.")
        .pop()
        .split(".")
        .shift();
      tailParts.push("file." + lastWord);
    }
    if (tailParts.length > 0) {
      lastWord = tailParts.pop();
      if (lastWord.indexOf(".html") === -1) {
        lastWord += ".html";
      }
      tailParts.push(lastWord);
      return this.noEndSlash(tailParts.join("/"));
    }
    return "";
  };

  this.getVersion = function(url) {
    var regex = /(v\d+\.\d+\.\d+)/;
    if (url.match(regex)) {
      match = regex.exec(url);
      return match[0];
    } else {
      return "latest";
    }
  };

  this.getDevsiteUrl = function(url) {
    var url = this.noEndSlash(url);
    var newUrl = "https://googleapis.dev/ruby";
    var gem = this.getGem(url);
    if (gem.length < 1) {
      return "https://googleapis.github.io/google-cloud-ruby/docs";
    }
    console.log(gem);
    var version = this.getVersion(url);
    var anchor = this.getAnchor(url);
    var tail = this.getTail(url, gem, version, anchor);
    newUrl += "/" + gem;
    newUrl += "/" + version;
    if (tail.length > 0) {
      newUrl += "/" + tail;
    }
    newUrl += anchor;
    return newUrl;
  };
}

module.exports = DevsiteForwarder;
