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
<<<<<<< HEAD
            // {
            //     //less的mixin文件无需发布
            //     reg : /^(.*)mixin\.less$/i,
            //     release : false
            // },
            // {
            //     //其他css文件
            //     reg : /^(.*)\.(css|less)$/i,
            //     release : '/$&'
            // },
            // {
            //     //前端模板
            //     reg : '**.tmpl',
            //     //当做类js文件处理，可以识别__inline, __uri等资源定位标识
            //     isJsLike : true,
            //     //只是内嵌，不用发布
            //     release : false
            // },
            // {
            //     reg : /.*\.(html|jsp|tpl|vm|htm|asp|aspx|php)/,
            //     useCache : false,
            //     release : '$&'
            // },
            {
                id: 'bootstrap.css',
                reg: '/bower_components/bootstrap/dist/css/bootstrap.min.css',
                release: 'vendor/bootstrap/css/bootstrap.css'
            },
            {
                reg: /\/bower_components\/bootstrap\/dist\/fonts\/(.*)/,
                release: '/font/$1'
            },
            {
                id: 'jquery',
                reg: '/bower_components/jquery/dist/jquery.js',
                release: 'vendor/jquery/jquery.js'
            },
            {
                id: 'bootstrap',
                reg: '/bower_components/bootstrap/dist/js/bootstrap.js',
                release: 'vendor/bootstrap/bootstrap.js',
                requires: ['bootstrap.css']
            },
            {
                id: 'underscore',
                reg: '/bower_components/lodash/dist/lodash.underscore.js',
                release: 'vendor/underscore/underscore.js'
            },
            {
                id: 'backbone',
                reg: '/bower_components/backbone/backbone.js',
                release: 'vendor/backbone/backbone.js',
            },
            {
                id: 'react',
                reg: '/bower_components/react/react.js',
                release: 'vendor/react/react.js',
            },
            {
                id: 'text',
                reg: '/modules/widget/text.coffee',
                release: '/$&',
            },
            {
                id: 'backbone.localStorage',
                reg: '/bower_components/backbone.localStorage/backbone.localStorage.js',
                release: 'vendor/backbone.localStorage/backbone.localStorage.js',
            },
=======
>>>>>>> eb419c9f16f3e6d0d38eb2b31bfa654137711ce8
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