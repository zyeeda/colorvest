fis.config.set('pack', {
    'pkg/lib.js': [
        '/lib/bootstrap/bootstrap.js',
        '/lib/react/react.js',
        '/lib/zepto/zepto.js',
        '/lib/underscore/underscore.js',
        '/lib/backbone/backbone.js'
    ]
});

fis.config.set('roadmap.path', [
    {
        id: 'bootstrap.css',
        reg: '/lib/bootstrap/dist/css/bootstrap.css',
        release: '/lib/bootstrap/css/bootstrap.css'
    },
    {
        reg: /\/lib\/bootstrap\/dist\/fonts\/(.*)/,
        release: '/font/$1'
    },
    {
        id: 'bootstrap',
        reg: '/lib/bootstrap/dist/js/bootstrap.js',
        release: '/lib/bootstrap/bootstrap.js',
        requires: ['bootstrap.css']
    },
    {
        id: 'react',
        reg: '/lib/react/react.js',
        release: '/lib/react/react.js'
    },
    {
        id: 'zepto',
        reg: '/lib/zepto/zepto.js',
        release: '/lib/zepto/zepto.js'
    },
    {
        id: 'underscore',
        reg: '/lib/lodash/dist/lodash.underscore.js',
        release: '/lib/underscore/underscore.js'
    },
    {
        id: 'backbone',
        reg: '/lib/backbone/backbone.js',
        release: '/lib/backbone/backbone.js',
        requires: ['zepto', 'underscore']
    },
    {
        id: 'backbone.localStorage',
        reg: '/lib/backbone.localStorage/backbone.localStorage.js',
        release: '/lib/backbone.localStorage/backbone.localStorage.js'
    },
    {
        id: 'mod',
        reg: '/lib/mod/mod.js',
        release: '/lib/mod/mod.js'
    },
    {
        id: 'main',
        reg: '/app/main.js',
        release: '/app/main.js'
    },
    {
        reg: '**/*.coffee',
        release: false
    },
    {
        reg: '/lib/**',
        release: false
    },
    {
        reg: '/bower.json',
        release: false
    }
]);

//项目排除掉_xxx.scss，这些属于框架文件，不用关心
fis.config.set('project.exclude', '**/_*.scss');
//scss后缀的文件，用fis-parser-sass插件编译
fis.config.set('modules.parser.scss', 'sass');
//scss文件产出为css文件
fis.config.set('roadmap.ext.scss', 'css');

//静态资源域名，使用pure release命令时，添加--domains或-D参数即可生效
//fis.config.set('roadmap.domain', 'http://127.0.0.1:8080');

//如果要兼容低版本ie显示透明png图片，请使用pngquant作为图片压缩器，
//否则png图片透明部分在ie下会显示灰色背景
//使用spmx release命令时，添加--optimize或-o参数即可生效
//fis.config.set('settings.optimzier.png-compressor.type', 'pngquant');

//设置jshint插件要排除检查的文件，默认不检查lib、jquery、backbone、underscore等文件
//使用pure release命令时，添加--lint或-l参数即可生效
// fis.config.set('settings.lint.jshint.ignored', [ 'lib/**', /jquery|zepto|bootstrap|react|lodash|backbone|underscore|backbone.localStorage/i ]);

//csssprite处理时图片之间的边距，默认是3px
// fis.config.set('settings.spriter.csssprites.margin', 20);