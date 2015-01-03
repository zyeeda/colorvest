fis.config.set('project.watch.exclude', []);
module.exports = {
    settings: {
        command: {
            '': 'release -d ./',  // clean: rm -rf src/*.js src/*/*.js assets/*.css
            'w': 'release -wd ./'
        }
    },
    modules: {
        parser: {
            coffee: 'coffee-react'
        }
    },
    roadmap: {
        ext : {
            coffee: 'js',
        },
        path: [
            {
                reg : /^\/assets\/(.*)\.(scss)$/i,
                release : '$&',
            },
            {
                reg : /^\/assets\/(.*)$/i,
                release : false,
            },
            {
                reg: /^\/src\/(.*)\.(coffee)$/i,
                release : '$&'
            },
            {
                reg: '**',
                release: false
            }
        ]
    }
}
