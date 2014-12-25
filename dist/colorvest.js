(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var App, StackApp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('../core/app');

StackApp = (function(_super) {
  __extends(StackApp, _super);

  function StackApp() {
    return StackApp.__super__.constructor.apply(this, arguments);
  }

  StackApp.prototype.mapRegions = function(item) {
    return React.createElement("div", {
      "id": item.region,
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



},{"../core/app":3}],2:[function(require,module,exports){
var Colorvest, StackApp;

StackApp = require('./app/stack');

Colorvest = {
  StackApp: StackApp
};

window.Colorvest = Colorvest;



},{"./app/stack":1}],3:[function(require,module,exports){
var App, BaseWidget,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseWidget = require('./base-widget');

App = (function(_super) {
  __extends(App, _super);

  function App() {
    return App.__super__.constructor.apply(this, arguments);
  }

  App.prototype.start = function() {
    return React.render(this.render(), document.body);
  };

  return App;

})(BaseWidget);

module.exports = App;



},{"./base-widget":4}],4:[function(require,module,exports){
var BaseWidget, Layout, Region;

Layout = require('./layout');

Region = require('./region');

BaseWidget = (function() {
  function BaseWidget(options) {
    this.options = options;
    this.name = options.name;
    this.initLayout();
    this.initRegions();
  }

  BaseWidget.prototype.getLayout = function() {
    return this.layout;
  };

  BaseWidget.prototype.getParent = function() {
    var region, _i, _len, _ref;
    _ref = this.layout.regions;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      region = _ref[_i];
      if (region.widget.name === this.name) {
        return region;
      }
    }
  };

  BaseWidget.prototype.find = function() {};

  BaseWidget.prototype.findRegion = function(name) {
    var region, _i, _len, _ref;
    _ref = this.layout.regions;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      region = _ref[_i];
      if (region.widget.name === this.name) {
        return region;
      }
    }
    return this.layout.regions[name];
  };

  BaseWidget.prototype.findWidget = function(name) {
    var region, _i, _len, _ref;
    _ref = this.layout.regions;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      region = _ref[_i];
      if (region.widget.name === name) {
        return region.widget;
      }
    }
  };

  BaseWidget.prototype.initLayout = function() {
    this.layout = new Layout({
      name: this.options.layout,
      parent: this
    });
    return this.layout;
  };

  BaseWidget.prototype.initRegions = function() {
    var region, _i, _len, _ref, _results;
    this.layout.regions = [];
    _ref = this.options.regions;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      region = _ref[_i];
      _results.push(this.layout.regions.push(new Region({
        name: region.region,
        height: region.height,
        content: region.content,
        parent: this.layout
      })));
    }
    return _results;
  };

  return BaseWidget;

})();

module.exports = BaseWidget;



},{"./layout":5,"./region":6}],5:[function(require,module,exports){
var Layout;

Layout = (function() {
  function Layout(options) {
    this.options = options;
    this.name = options.name;
    this.parent = options.parent;
  }

  Layout.prototype.getParent = function() {
    return this.parent;
  };

  Layout.prototype.getRegions = function() {
    return this.regions;
  };

  return Layout;

})();

module.exports = Layout;



},{}],6:[function(require,module,exports){
var Region;

Region = (function() {
  function Region(options) {
    this.options = options;
    this.name = options.name;
    this.height = options.height;
    this.content = options.content;
    this.parent = options.parent;
  }

  Region.prototype.getParent = function() {
    return this.parent;
  };

  Region.prototype.getWidget = function() {
    return this.widget;
  };

  Region.prototype.mountWidget = function(widget) {
    return this.widget = widget;
  };

  Region.prototype.unmountWidget = function() {
    return this.widget = void 0;
  };

  return Region;

})();

module.exports = Region;



},{}]},{},[2])