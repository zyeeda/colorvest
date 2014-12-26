var App, BaseWidget, React,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

React = require('react');

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
