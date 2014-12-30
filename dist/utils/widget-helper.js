var sizeMapping, typeMapping, widgetHelper, _,
  __slice = [].slice;

_ = require('lodash');

sizeMapping = {
  large: 'lg',
  "default": '',
  small: 'sm',
  xsmall: 'xs'
};

typeMapping = {
  button: 'btn',
  input: 'input'
};

widgetHelper = {
  joinClasses: function() {
    var className, name, names, others, _i, _len;
    className = arguments[0], others = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (className == null) {
      className = '';
    }
    names = [];
    for (_i = 0, _len = others.length; _i < _len; _i++) {
      name = others[_i];
      names.push(name);
    }
    if (className !== '') {
      names.push(className);
    }
    return names.join(' ');
  },
  getHeightSize: function(type, size) {
    var heightSize, sz, tp;
    if (type == null) {
      type = "input";
    }
    if (size == null) {
      size = "default";
    }
    sz = sizeMapping[size];
    tp = typeMapping[type];
    if ((sz != null) && (tp != null)) {
      heightSize = tp + "-" + sz;
    }
    if (heightSize != null) {
      heightSize = '';
    }
    return heightSize;
  }
};

module.exports = widgetHelper;
