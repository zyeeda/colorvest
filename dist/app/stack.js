var App, React, StackApp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

React = require('react');

App = require('../core/app');

StackApp = (function(_super) {
  __extends(StackApp, _super);

  function StackApp() {
    return StackApp.__super__.constructor.apply(this, arguments);
  }

  StackApp.prototype.mapRegions = function(item) {
    return React.createElement("div", {
      "id": item.region,
      "key": Math.random(),
      "style": {
        height: item.height
      },
      "className": "col-xs-12"
    }, item.content);
  };

  StackApp.prototype.render = function() {
    return React.createElement("div", {
      "className": "container-fluid"
    }, React.createElement("div", {
      "className": "row"
    }, this.options.regions.map(this.mapRegions)));
  };

  return StackApp;

})(App);

module.exports = StackApp;
