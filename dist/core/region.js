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
