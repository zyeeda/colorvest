clean:
	rm -rf build/coala
	find coala ! -path "coala/vendors/*" -name "*.js" | xargs rm -f
	find coala/themes/spacelab/css/ -name "bootstrap*.css" | xargs rm -f

compile:
	coffee -c .
	coffee -b -c coala/require-config.coffee
	make bootstrap-coala

THEME_PATH = coala/themes/spacelab
bootstrap-coala:
	recess --compile ${THEME_PATH}/less/swatchmaker.less > ${THEME_PATH}/css/bootstrap.css
	recess --compile ${THEME_PATH}/less/swatchmaker-responsive.less > ${THEME_PATH}/css/bootstrap-responsive.css

package:
	make clean
	make compile
	mkdir -p build/coala/vendors/
	cp -R coala/themes build/coala/
	cd build/coala/themes/spacelab/css && \
		r.js -o cssIn=main.css out=main-build.css && \
		rm main.css && \
		cleancss -o main.css main-build.css && \
		rm main-build.css
	cp coala/vendors/modernizr.js build/coala/vendors/
	cp coala/vendors/html5shiv.js build/coala/vendors/
	cp coala/require-config.js build/coala/
	cp -R coala/vendors/require build/coala/vendors/
	cd build && r.js -o build.js name=coala/applications/default
	rm -rf build/coala/themes/spacelab/less
	find build -name ".DS_Store" | xargs rm -f
	find build/coala/themes/spacelab/css ! -name "main.css" -name "*.css" | xargs rm -f
	find build -type d -empty | xargs rm -rf

#spacelab:
#	mkdir -p build/spacelab
#	test -d build/spacelab/bootswatch || ( \
#		curl --location -o build/spacelab/bootswatch.tar.gz http://localhost:8080/bootswatch.tar.gz && \
#		cd build/spacelab && \
#		tar -xzf bootswatch.tar.gz && \
#		mv thomaspark-bootswatch* bootswatch && \
#		rm bootswatch.tar.gz)
#	test -d build/spacelab/elusive-iconfont || ( \
#		curl --location -o build/spacelab/elusive-iconfont.tar.gz http://localhost:8080/aristath-elusive-iconfont.tar.gz && \
#		cd build/spacelab && \
#		tar -xzf elusive-iconfont.tar.gz && \
#		mv aristath-elusive-iconfont* elusive-iconfont && \
#		rm elusive-iconfont.tar.gz)
#	test -d build/spacelab/bootswatch/swatchmaker/bootstrap || ( \
#		curl --location -o build/spacelab/bootswatch/swatchmaker/bootstrap.tar.gz http://localhost:8080/twitter-bootstrap.tar.gz && \
#		cd build/spacelab/bootswatch/swatchmaker && \
#		tar -xzf bootstrap.tar.gz && \
#		mv twitter-bootstrap* bootstrap && \
#		rm bootstrap.tar.gz)
#	cp build/spacelab/elusive-iconfont/less/elusive-webfont.less build/spacelab/bootswatch/swatchmaker/bootstrap/less/sprites.less
#	cp build/spacelab/bootswatch/spacelab/variables.less build/spacelab/bootswatch/swatchmaker/swatch/
#	cp build/spacelab/bootswatch/spacelab/bootswatch.less build/spacelab/bootswatch/swatchmaker/swatch/
#	cd build/spacelab/bootswatch/swatchmaker && make bootswatch
#	cp build/spacelab/bootswatch/swatchmaker/swatch/bootstrap.css coala/themes/default/bootstrap/css/
#	cp build/spacelab/bootswatch/swatchmaker/swatch/bootstrap-responsive.css coala/themes/default/bootstrap/css/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.eot coala/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.woff coala/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.svg coala/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.ttf coala/themes/default/bootstrap/font/

