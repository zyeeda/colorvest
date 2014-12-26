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
