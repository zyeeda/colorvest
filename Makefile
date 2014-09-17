clean:
	rm -rf build/cdeio
	find cdeio ! -path "cdeio/vendors/*" -name "*.js" | xargs rm -f
	#find cdeio/themes/ace/css/ -name "bootstrap*.css" | xargs rm -f

compile:
	coffee -c .
	coffee -b -c cdeio/require-config.coffee
	#make bootstrap-cdeio

#THEME_PATH = cdeio/themes/ace
#bootstrap-cdeio:
#	recess --compile ${THEME_PATH}/less/theme.less > ${THEME_PATH}/css/bootstrap.css
#	recess --compile ${THEME_PATH}/less/theme-responsive.less > ${THEME_PATH}/css/bootstrap-responsive.css
#
package:
	make clean
	make compile
	mkdir -p build/cdeio/vendors/
	cp -R cdeio/themes build/cdeio/
	cd build/cdeio/themes/ace/css && \
		r.js -o cssIn=main.css out=main-build.css && \
		rm main.css && \
		cleancss -o main.css main-build.css && \
		rm main-build.css
	cp cdeio/vendors/modernizr.js build/cdeio/vendors/
	cp cdeio/vendors/html5shiv.js build/cdeio/vendors/
	cp cdeio/require-config.js build/cdeio/
	cp -R cdeio/vendors/require build/cdeio/vendors/
	cd build && r.js -o build.js name=cdeio/applications/default
	rm -rf build/cdeio/themes/ace/less
	find build -name ".DS_Store" | xargs rm -f
	find build/cdeio/themes/ace/css ! -name "main.css" -name "*.css" | xargs rm -f
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
#	cp build/spacelab/bootswatch/swatchmaker/swatch/bootstrap.css cdeio/themes/default/bootstrap/css/
#	cp build/spacelab/bootswatch/swatchmaker/swatch/bootstrap-responsive.css cdeio/themes/default/bootstrap/css/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.eot cdeio/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.woff cdeio/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.svg cdeio/themes/default/bootstrap/font/
#	cp build/spacelab/elusive-iconfont/font/Elusive-Icons.ttf cdeio/themes/default/bootstrap/font/
