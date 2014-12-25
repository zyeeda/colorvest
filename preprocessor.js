var transform = require('coffee-react-transform');
var coffee = require('coffee-script');

module.exports = {
    process: function(src, path) {
        if (path.match(/\.coffee$/)) {
        	var ccode = transform(src);
            var code = coffee.compile(ccode, {
                'bare': true
            });
            return code;
        }
        return src;
    }
};
