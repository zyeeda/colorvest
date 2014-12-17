//项目排除掉_xxx.scss，这些属于框架文件，不用关心
fis.config.set('project.exclude', '**/_*.scss');
fis.config.set('settings.postpackager.simple.autoCombine', true);
fis.config.set('settings.postpackager.simple.output', 'dist/colorvest');

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

fis.config.merge({
    modules: {
        parser: {
            //coffee后缀的文件使用fis-parser-coffee-react插件编译
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
            exclude : /\/lib|styles|modules|widgets|vendor|main.js|require.js|index.html|README.md/
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
                reg : /^\/widgets\/([^\/]+)\/assets\/main\.(scss)$/i,
                id : 'widgets/$1.css',
                release : 'styles/$1/main.css'
            },
            {
                reg : /^\/widgets\/([^\/]+)\/assets\/(.*)$/i,
                release : '/img/$1/$2'
            },
            {
                reg : /^\/widgets\/([^\/]+)\/main\.(coffee)$/i,
                isMod : true,
                id : 'widgets/$1',
                release : '/$&'
            },
            {
                reg : /^\/widgets\/(.*)\.(coffee)$/i,
                isMod : true,
                id : 'widgets/$1',
                release : '/$&'
            },
            {
                id: 'bootstrap.css',
                reg: '/bower_components/bootstrap/dist/css/bootstrap.min.css',
                release: 'styles/bootstrap.css'
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
                id: 'mod',
                reg: '/bower_components/mod/mod.js',
                release: 'dist/mod.js',
                useHash: false
            },
            {
                id: 'require',
                reg: 'require.coffee',
                release: 'require.js'
            },
            {
                id: 'main',
                reg: 'main.coffee',
                release: 'main.js',
                isMod: true
            }
        ]
    }
});

var path = require('./fis-path').path;

path = fis.config.data.roadmap.path.concat(path || []);

fis.config.data.roadmap.path = path.concat([
    {
        reg: '**/*.coffee',
        release: false
    },
    {
        reg: '/bower_components/**',
        release: false
    },
    {
        reg: '/lib/**',
        release: false
    },
    {
        reg: '/bower.json',
        release: false
    },
    {
        reg: 'map.json',
        release: false
    }
]);