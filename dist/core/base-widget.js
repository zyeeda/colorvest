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

  BaseWidget.prototype.getLayout = function() {};

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
