var BaseWidget, Widget,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseWidget = require('./base-widget');

Widget = (function(_super) {
  __extends(Widget, _super);

  function Widget() {
    return Widget.__super__.constructor.apply(this, arguments);
  }

  Widget.prototype.mountWidget = function(widget, regionName) {
    var region;
    region = this.findRegion(regionName);
    return region.mountWidget(widget);
  };

  Widget.prototype.unmountWidget = function(layout) {
    var region;
    region = this.findRegion(regionName);
    return region.unmountWidget();
  };

  Widget.prototype.activeRegion = function(regionName) {};

  Widget.prototype.render = function() {};

  return Widget;

})(BaseWidget);

module.exports = Widget;
