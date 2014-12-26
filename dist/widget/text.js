var React, Text, Widget, joinClasses,
  __slice = [].slice;

React = require('react');

Widget = require('../core/widget');

joinClasses = function() {
  var className, name, names, others, _i, _len;
  className = arguments[0], others = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  if (className == null) {
    className = '';
  }
  names = [];
  if (className !== '') {
    names.push(className);
  }
  for (_i = 0, _len = others.length; _i < _len; _i++) {
    name = others[_i];
    names.push(name);
  }
  return names.join(' ');
};

Text = React.createClass({
  onBlur: function(e) {},
  renderHelp: function() {
    if (this.props.help != null) {
      return React.createElement("span", {
        "className": "help-block",
        "key": "help"
      }, this.props.help);
    }
  },
  render: function() {
    return React.createElement("div", {
      "className": joinClasses('form-group', this.props.color)
    }, React.createElement("label", {
      "className": "control-label"
    }, this.props.text), React.createElement("input", {
      "type": "text",
      "ref": "input",
      "key": "input",
      "readOnly": (this.props.readonly === 'readonly' ? 'readonly' : void 0),
      "className": joinClasses('form-control'),
      "placeholder": this.props.placeholder
    }), this.renderHelp());
  }
});

module.exports = Text;
