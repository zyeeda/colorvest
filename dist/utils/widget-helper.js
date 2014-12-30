var heightSizeMapping, sizeMapping, widgetHelper, _,
  __slice = [].slice;

_ = require('lodash');

heightSizeMapping = {
  large: 'input-lg',
  "default": '',
  small: 'input-sm',
  xsmall: 'input-sm'
};

sizeMapping = {
  large: 'btn-lg',
  small: 'btn-sm',
  xsmall: 'btn-xs',
  "default": ''
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
  getHeightSize: function(sizing) {
    var heightSizing;
    heightSizing = heightSizeMapping[sizing];
    if (_.isUndefined(sizing)) {
      heightSizing = '';
    }
    return heightSizing;
  },
  getSize: function(s) {
    var size;
    size = sizeMapping[s];
    if (_.isUndefined(s)) {
      size = '';
    }
    return size;
  }
};

module.exports = widgetHelper;
