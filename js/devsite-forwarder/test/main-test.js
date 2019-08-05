// Copyright 2019 Google LLC

// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

var DevsiteForwarder = require("../main.js");
var assert = require("assert");
var YAML = require("yaml");
var fs = require("fs");

describe("DevsiteForwarder", function() {
  var releases = fs.readFileSync("../../_data/releases.yaml", "utf8");
  var gemData = YAML.parse(releases);
  var ghBase = "https://googleapis.github.io/google-cloud-ruby/docs";
  var ghBaseAlt = "https://googleapis.github.io/google-cloud-ruby/#/docs";
  var devBase = "https://googleapis.dev/ruby";

  var logger = "/google-cloud-logging/latest/Google/Cloud/Logging/Logger";
  var assetAuth = "/google-cloud-asset/latest/file.AUTHENTICATION.html";
  var anchor = "#datetime_format-instance_method";
  var capAnchor = "#Creating_a_Service_Account";

  var stackCore = "stackdriver-core/latest/Stackdriver/Core/TraceContext";
  var stack = "stackdriver/latest/Stackdriver";

  before(function() {
    this.forwarder = new DevsiteForwarder(gemData);
  });

  describe("getDevsiteUrl()", function() {
    it("translates gh-pages urls to their devsite equivalent", function() {
      var urls = Object.entries({
        "/google-cloud-asset": devBase + "/google-cloud-asset/latest",
        ghBase: ghBase,
        ghBaseAlt: ghBase,
        [ghBase + logger + anchor]: devBase + logger + ".html" + anchor,
        [ghBase + assetAuth + capAnchor]: devBase + assetAuth + capAnchor,
        'http:googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-pubsub/latest/google/cloud/pubsub':
        'http:googleapis.dev/ruby/google-cloud-pubsub/latest/google/cloud/pubsub'
      });
      for (var i = 0; i < urls.length; i++) {
        assert.equal(this.forwarder.getDevsiteUrl(urls[i][0]), urls[i][1]);
      }
    });
  });

  describe("getVersion()", function() {
    it("returns the version if there is one", function() {
      assert.equal(
        this.forwarder.getVersion(ghBase + "stackdriver/v11.2.12/Stackdriver"),
        "v11.2.12"
      );
      assert.equal(
        this.forwarder.getVersion(
          ghBase + "/google-cloud-logging/v0.1.9/Google/Cloud/Logging/Logger"
        ),
        "v0.1.9"
      );
      assert.equal(this.forwarder.getVersion(ghBaseAlt + stackCore), "latest");
    });

    it('returns the "latest" if there is no version, or if the version is "master"', function() {
      assert.equal(
        this.forwarder.getVersion(
          ghBase +
            "/google-cloud-asset/master/file.AUTHENTICATION.html" +
            capAnchor
        ),
        "latest"
      );
      assert.equal(
        this.forwarder.getVersion(ghBaseAlt + "/google-cloud-logging"),
        "latest"
      );
    });
  });

  describe("getTail()", function() {
    it('returns the after-version url with ".html" appended, excepting the anchor', function() {
      assert.equal(
        this.forwarder.getTail(
          ghBase + logger + anchor,
          "google-cloud-logging",
          "latest",
          anchor
        ),
        "Google/Cloud/Logging/Logger.html"
      );
      assert.equal(
        this.forwarder.getTail(
          ghBase + assetAuth + capAnchor,
          "google-cloud-asset",
          "latest",
          capAnchor
        ),
        "file.AUTHENTICATION.html"
      );
      assert.equal(
        this.forwarder.getTail(
          ghBaseAlt + assetAuth + capAnchor,
          "google-cloud-asset",
          "latest",
          capAnchor
        ),
        "file.AUTHENTICATION.html"
      );
      assert.equal(
        this.forwarder.getTail(
          ghBase + logger,
          "google-cloud-logging",
          "latest",
          ""
        ),
        "Google/Cloud/Logging/Logger.html"
      );
    });
  });

  describe("getGem()", function() {
    it("returns 'google-cloud' only if there are no other matches", function() {
      var cloud = "google-cloud/latest/Google/Cloud";
      assert.equal(this.forwarder.getGem(ghBase + cloud), "google-cloud");
      assert.equal(this.forwarder.getGem(ghBaseAlt + cloud), "google-cloud");
    });

    it("returns the longest gemname in the url if more than one match", function() {
      assert.equal(
        this.forwarder.getGem(ghBase + stackCore),
        "stackdriver-core"
      );
      assert.equal(
        this.forwarder.getGem(ghBaseAlt + stackCore),
        "stackdriver-core"
      );
      assert.equal(this.forwarder.getGem(ghBase + stack), "stackdriver");
      assert.equal(this.forwarder.getGem(ghBaseAlt + stack), "stackdriver");
    });

    it("returns an empty string if there are no matches", function() {
      assert.equal(this.forwarder.getGem(ghBase), "");
      assert.equal(this.forwarder.getGem(ghBaseAlt), "");
    });
  });

  describe("getAnchor()", function() {
    it("returns the anchor from a url containing one", function() {
      assert.equal(this.forwarder.getAnchor(ghBase + logger + anchor), anchor);
      assert.equal(
        this.forwarder.getAnchor(ghBase + assetAuth + capAnchor),
        capAnchor
      );
      assert.equal(
        this.forwarder.getAnchor(ghBaseAlt + logger + anchor),
        anchor
      );
      assert.equal(
        this.forwarder.getAnchor(ghBaseAlt + assetAuth + capAnchor),
        capAnchor
      );
    });

    it("returns empty string if url contains no anchor", function() {
      assert.equal(this.forwarder.getAnchor(ghBase + logger), "");
      assert.equal(this.forwarder.getAnchor(ghBase + assetAuth), "");
      assert.equal(this.forwarder.getAnchor(ghBaseAlt + logger), "");
      assert.equal(this.forwarder.getAnchor(ghBaseAlt + assetAuth), "");
    });
  });

  describe("#noEndSlash()", function() {
    it("removes trailing forward slash when there is one", function() {
      assert.equal(this.forwarder.noEndSlash(ghBase + "/"), ghBase);
    });

    it("does nothing if the url doesn't end with a slash", function() {
      assert.equal(this.forwarder.noEndSlash(ghBase), ghBase);
    });

    it("removes all trailing forward slashes when there are more than one", function() {
      assert.equal(this.forwarder.noEndSlash(ghBase + "//"), ghBase);
    });
  });
});
