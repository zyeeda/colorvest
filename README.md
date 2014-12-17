## fis & 插件安装

npm install -g fis

npm install -g fis-parser-coffee-react 

npm install -g fis-parser-coffee-script

npm install -g fis-parser-sass

npm install -g fis-parser-less

npm install -g fis-parser-react

npm install -g fis-parser-marked

npm install -g fis-postprocessor-require-async

npm install -g fis-postprocessor-jswrapper

npm install -g fis-postpackager-autoload

npm install -g fis-postpackager-simple


## bower & 库安装

npm install -g bower

cd colorvest

bower install


## 编译 & 运行

cd colorvest

fis release -opm 

fis server start

## 打包 & 发布
fis release -op --dest local
