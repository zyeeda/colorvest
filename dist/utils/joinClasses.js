var joinClasses,
  __slice = [].slice;

joinClasses = function() {
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
};

module.exports = joinClasses;
