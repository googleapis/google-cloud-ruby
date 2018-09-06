// Copyright 2018 Chris Smith (quartzmo)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
(function (global, factory) {

  if (typeof exports === 'object' && typeof module !== 'undefined') {
    module.exports = factory(global)
  } else {
    global.JsondocForwarder = factory(global);
  }
}(this, (function(global) {
  'use strict';

  function getPath(url) {
    var split = url.split('#');
    var pathWithQuery =  split[split.length - 1];
    return pathWithQuery.split('?')[0]; // exclude query
  }

  function getQuery(url) {
    var split = url.split('?');
    if (split.length < 2) return null;
    var queryString = split[1];
    // From: https://stackoverflow.com/questions/8648892/convert-url-parameters-to-a-javascript-object
    var queryJson = '{"' + decodeURI(queryString).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}';
    return JSON.parse(queryJson);
  }

  function addTrailiingSlash(url) {
    if (url.substr(-1) !== '/') return url += '/';
    return url;
  }

  function stripTrailiingSlash(url) {
    if (url.substr(-1) === '/') return url.slice(0, url.length-1);
    return url;
  }

  function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  function capitalizeModuleNames(arr, moduleNames) {
    for (var i = 3; i < arr.length; i++) {
      arr[i] = capitalizeModuleName(arr[i], moduleNames)
    }
  }

  function capitalizeModuleName(name, moduleNames) {
    var camelCaseName = moduleNames[name];
    if (camelCaseName) {
      return camelCaseName;
    } else {
      return capitalize(name);
    }
  }

  function getAnchorFromQuery(query) {
    var key = 'method';
    var val = query[key];
    if (!val) return ''; // No support for query types other than 'method'.
    var split = val.split('-'); // Split off type suffix from 'event_time-instance'.
    var name = split[0];
    var type = split[1];
    if (type === 'constructor') type = 'instance';
    return '#' + name + '-' + type + '_method';
  }

  function isMasterOrLatestVersion(str) {
    return str === 'master' || str === 'latest';
  }

  function isVersion(str) {
    return isMasterOrLatestVersion(str) || /^v\d/.test(str);
  }

  /**
   * Constructs a new instance of JsondocForwarder.
   *
   * @param {string} origin Optional, may be null. If not provided, will be
   *   obtained from window.location.origin.
   *   For example: "https://googlecloudplatform.github.io".
   * @param {string} appPath Optional, may be null. Any additional path that
   *   should be added to origin to form the entire path to the jsondoc site app.
   *   For example: "/google-cloud-ruby/".
   * @param {string} targetUrl Optional, may be null. Primarily used for testing.
   *   The entire path to the root of the target YARD site.
   *   For example: "https://googlecloudplatform.github.io/google-cloud-ruby".
   * @param {string} moduleNames Optional, may be null. A JavaScript object
   *   mapping lowercase jsondoc module names to camel-case YARD module names.
   *   Produced using the jsondoc_types.rb script in the repo for this library.
   */
  function JsondocForwarder(origin, appPath, targetUrl, moduleNames) {
    if (origin) {
      this.origin = origin;
    } else if (typeof window !== 'undefined') {  // browser
      if (window.location.origin) {
        this.origin = window.location.origin;
      } else {
        // IE workaround
        this.origin = window.location.protocol + "//"
        + window.location.hostname
        + (window.location.port ? ':' + window.location.port : '');
      }
    } else {
      throw new Error('origin is required');
    }

    this.appPath = appPath ? appPath : "";
    this.baseUrl = this.origin + this.appPath;
    this.targetUrl = targetUrl ? targetUrl : stripTrailiingSlash(this.baseUrl);
    this.moduleNames = moduleNames ? moduleNames : {};
  }

  JsondocForwarder.prototype = {
    /**
     * Converts a jsondoc site app URL to a YARD site app URL.
     *
     * @param {string} url A full jsondoc site app URL, typically obtained from window.location.href.
     * @returns {string} A full YARD site app URL, typically provided to window.location.href =.
     */
    resolve: function resolve(url) {
      if (url.indexOf('#') === -1) return null;
      if (url.split('#')[0] !== addTrailiingSlash(this.baseUrl)) return null;
      var path = getPath(url);
      var query = getQuery(url);
      // Remove leading and trailing slashes to prevent empty strings in split array.
      path = path.replace(/^\//, '').replace(/\/$/, '');
      var pathElements = path.split('/');

      // Return base url if /# or /#/
      if (pathElements.length === 1 && !pathElements[0]) return this.targetUrl;

      if (pathElements.length === 3 && pathElements[1] === 'guides') {
        // Remove 'guides' from /docs/guides/*
        pathElements.splice(1, 1);

      } else if (pathElements.length > 2 && !isVersion(pathElements[2])) {
        // Add 'latest' if version is missing from path that includes modules.
        pathElements.splice(2, 0, 'latest');
      }

      // The first three elements are 'docs', gem, and version and do not require camel-casing.
      if (pathElements.length > 3) {
        if (pathElements[1] === 'google-cloud') {
          // Special case: 'google-cloud' paths must all be redirected to the google-cloud version root.
          pathElements = pathElements.slice(0, 3);
        } else if (pathElements[3] == 'guides' && isMasterOrLatestVersion(pathElements[2])) {
          // Master and latest '/guides/' paths can be redirected to yard files.
          var guide = "file." + pathElements[4].toUpperCase();
          pathElements = pathElements.slice(0, 3);
          pathElements.push(guide);
        } else if (pathElements[3] == 'guides') {
          // Special case: Existing version '/guides/' paths must all be redirected to the gem/version root.
          pathElements = pathElements.slice(0, 3);
        } else {
          capitalizeModuleNames(pathElements, this.moduleNames); // This mutates pathElements.
        }
      }

      var newPath = addTrailiingSlash(this.targetUrl) + pathElements.join('/');
      if (query) newPath += getAnchorFromQuery(query);
      return newPath;
    }
  };

  return JsondocForwarder;

})));