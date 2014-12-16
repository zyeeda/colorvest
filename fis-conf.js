//项目排除掉_xxx.scss，这些属于框架文件，不用关心
fis.config.set('project.exclude', '**/_*.scss');

fis.config.merge({
    modules: {
        parser: {
            //coffee后缀的文件使用fis-parser-coffee-react插件编译
            coffee : 'coffee-react',
            jsx: 'react',
            less : 'less',
            scss: 'sass',
            md : 'marked'
        },
        postprocessor: {
            js: "jswrapper, require-async",
            // html: "require-async"
        },
        postpackager : ['autoload', 'simple']
    },
    roadmap: {
         ext : {
            //less后缀的文件将输出为css后缀
            less : 'css',
            scss: 'css',
            coffee : 'js',
            jsx: 'js',
            md : 'html'
        },
        path: [{
                reg : /^\/page\/(.*)$/i,
                useCache : false,
                release : '$1'
            },
            {
                //一级同名组件，可以引用短路径，比如modules/jquery/juqery.js
                //直接引用为var $ = require('jquery');
                reg : /^\/modules\/([^\/]+)\/\1\.(coffee)$/i,
                //是组件化的，会被jswrapper包装
                isMod : true,
                //id为文件夹名
                id : '$1',
                release : '/$&'
            },
            {
                //modules目录下的其他脚本文件
                reg : /^\/modules\/(.*)\.(coffee)$/i,
                //是组件化的，会被jswrapper包装
                isMod : true,
                //id是去掉modules和.js后缀中间的部分
                id : '$1',
                release : '/$&'
            },
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
                id: 'backbone.localStorage',
                reg: '/bower_components/backbone.localStorage/backbone.localStorage.js',
                release: 'vendor/backbone.localStorage/backbone.localStorage.js',
            },
            {
                id: 'mod',
                reg: '/bower_components/mod/mod.js',
                release: 'vendor/mod/mod.js',
                useHash: false
            },
            {
                id: 'v',
                reg: '/v.coffee',
                release: 'vendor/v.js'
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
                reg: '/bower.json',
                release: false
            }
        ]
    },
    settings: {
        postprocessor: {
            jswrapper: {
                type: 'amd'
            }
        }
    }  
});

/*
fis.config.set('pack', {
    'pkg/vendor.js': [
        '/bower_components/mod/mod.js',
        '/bower_components/jquery/dist/jquery.js',
        '/bower_components/bootstrap/dist/js/bootstrap.js',
        '/bower_components/lodash/dist/lodash.underscore.js',
        '/bower_components/backbone/backbone.js',
        '/bower_components/react/react.js'
    ]
});
*/

fis.config.set('settings.postpackager.simple.autoCombine', true);

//静态资源域名，使用pure release命令时，添加--domains或-D参数即可生效
//fis.config.set('roadmap.domain', 'http://127.0.0.1:8080');

//如果要兼容低版本ie显示透明png图片，请使用pngquant作为图片压缩器，
//否则png图片透明部分在ie下会显示灰色背景
//使用spmx release命令时，添加--optimize或-o参数即可生效
//fis.config.set('settings.optimzier.png-compressor.type', 'pngquant');

//设置jshint插件要排除检查的文件，默认不检查bower_components、jquery、backbone、underscore等文件
//使用pure release命令时，添加--lint或-l参数即可生效
// fis.config.set('settings.lint.jshint.ignored', [ 'bower_components/**', /jquery|zepto|bootstrap|react|lodash|backbone|underscore|backbone.localStorage/i ]);

//csssprite处理时图片之间的边距，默认是3px
// fis.config.set('settings.spriter.csssprites.margin', 20);
