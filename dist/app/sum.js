var avg, count, sum;

count = require('./count');

sum = function(value1, value2) {
  return value1 + value2;
};

avg = function(value1, value2) {
  return sum(value1, value2) / count;
};

module.exports = avg;
