var http = require('http');
var url = require('url');
var fs = require('fs');
var Buffer = require('buffer').Buffer;

var root = fs.realpathSync('.');

var server = http.createServer(function(request, response){
    var path = url.parse(request.url).pathname;
    path = path == '/'? '/index.html' : path;
    console.log('PATH:' + path);
    fs.open(root + path, 'r', function(e, fd){
        if(e) {
            console.log(e);
            response.writeHead(404);
            response.end();
        } else {
            var buffer = new Buffer(1024), readed = 0;
            while( (readed = fs.readSync(fd, buffer, 0, 1024)) != 0 ) {
                response.write(buffer.slice(0, readed));
            }
            fs.close(fd);
            response.end();
        }
    });
});

server.listen(8000);
