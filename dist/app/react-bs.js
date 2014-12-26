var App, ReactBsApp, Text,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('../core/app');

Text = require('../widget/text');

ReactBsApp = (function(_super) {
  __extends(ReactBsApp, _super);

  function ReactBsApp() {
    return ReactBsApp.__super__.constructor.apply(this, arguments);
  }

  ReactBsApp.prototype.render = function() {
    return React.createElement("div", {
      "className": "container-fluid"
    }, React.createElement(Text, {
      "id": 'name',
      "text": '姓名',
      "name": 'name',
      "color": 'has-success',
      "placeholder": '请填写姓名',
      "defaultValue": '123',
      "help": 'i need some help!'
    }), React.createElement(Text, {
      "id": 'name',
      "text": '性别',
      "name": 'sex',
      "color": 'has-warning',
      "placeholder": '请填写性别',
      "help": 'i need some help!'
    }));
  };

  return ReactBsApp;

})(App);

module.exports = ReactBsApp;