fis.config.set('pack', {
    'colorvest.js': [
        '/bower_components/mod/mod.js',
        '/modules/**',
        '/jswrapper.coffee'
    ]
});

//项目排除掉_xxx.scss，这些属于框架文件，不用关心
fis.config.set('project.exclude', '**/_*.scss');

fis.config.merge({
    modules: {
        parser: {
            coffee : 'coffee-react',
            jsx: 'react',
            less : 'less',
            scss: 'sass'
            // md : 'marked'
        },
        postprocessor: {
            js: "jswrapper, require-async",
            // html: "require-async"
        },
        postpackager : ['autoload', 'simple']
    },
    settings: {
        postprocessor: {
            jswrapper: {
                type: 'amd'
            }
        }
    },
    deploy : {
        local : {
            to : './lib',
            exclude : /\/lib|styles|modules|widgets|vendor|main.js|require.js|index.html|README.md|map.json/
        }
    },
    roadmap: {
         ext : {
            //less后缀的文件将输出为css后缀
            less : 'css',
            scss: 'css',
            coffee : 'js',
            jsx: 'js'
            // md : 'html'
        },
        path: [
            {
                //比如modules/app/index.coffee 可以直接引用为var app = require('app');
                reg : /^\/modules\/([^\/]+)\/main\.(coffee)$/i,
                isMod : true,
                id : '$1',
                release : '/$&'
            },
            {
                //modules目录下的其他脚本文件
                reg : /^\/modules\/(.*)\.(coffee)$/i,
                isMod : true,
                id : '$1',
                release : '/$&'
            },
            {
                id: 'mod',
                reg: '/bower_components/mod/mod.js',
                release: 'vendor/mod/mod.js',
                useHash: false
            },
            {
                id: 'jswrapper',
                reg: 'jswrapper.coffee',
                release: 'jswrapper.js',
                useHash: false
            },
            {
                reg: '**/*.coffee',
                release: false
            },
            {
                reg: '/bower_components/**',
                release: false
            },
            {
                reg: '/node_modules/**',
                release: false
            },
            {
                reg: '/lib/**',
                release: false
            }
        ]
    }
});