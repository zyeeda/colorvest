var heightSizingMapping, widgetHelper,
  __slice = [].slice;

heightSizingMapping = {
  large: 'input-lg',
  "default": '',
  small: 'input-sm',
  xsmall: 'input-sm'
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
    return names;
  },
  getHeightSizing: function(sizing) {
    var heightSizing;
    heightSizing = heightSizingMapping[sizing];
    if (_.isUndefined(sizing)) {
      heightSizing = '';
    }
    return heightSizing;
  }
};

module.exports = widgetHelper;
