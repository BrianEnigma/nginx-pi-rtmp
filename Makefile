NGINX_URL=https://nginx.org/download/nginx-1.25.5.tar.gz
RTMP_URL=https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v1.2.2.tar.gz

all: build/.compiled

installclient:
	# TODO: copy webcam scripts, init scripts

installserverpi: build/.compiled
	make -C build/nginx install
	cp scripts/nginx-pi.conf /opt/nginx/conf/nginx.conf
	cp scripts/init.nginx-pi /etc/init.d/nginx
	ln -sf /etc/init.d/nginx /etc/rc3.d/S99nginx
	ln -sf /etc/init.d/nginx /etc/rc5.d/S99nginx
	cp html/* /opt/nginx/html/
	cp contrib/hls.js/dist/hls.min.js /opt/nginx/html/player.min.js
	chown -R pi /opt/nginx

installserveraws: build/.compiled
	make -C build/nginx install
	cp scripts/nginx-aws.conf /opt/nginx/conf/nginx.conf
	cp scripts/init.nginx-aws /etc/init.d/nginx
	ln -sf /etc/init.d/nginx /etc/rc3.d/S99nginx
	cp html/* /opt/nginx/html/
	cp contrib/hls.js/dist/hls.min.js /opt/nginx/html/player.min.js
	chown -R ec2-user /opt/nginx

compile: build/.compiled

build/.compiled: build/.configured
	make -C build/nginx
	touch build/.compiled

configure: build/.configured

build/.configured: build/.extracted
	cd build/nginx; ./configure --prefix=/opt/nginx --with-http_ssl_module --with-http_stub_status_module --add-module=../rtmp
	touch build/.configured

extract: build/.extracted

build/.extracted: dl/.downloaded
	mkdir -p build/nginx
	cd dl; tar -xvf `basename $(NGINX_URL)` -C../build/nginx --strip-components 1
	mkdir -p build/rtmp
	cd dl; tar -xvf `basename $(RTMP_URL)` -C../build/rtmp --strip-components 1
	touch build/.extracted

download: dl/.downloaded

dl/.downloaded:
	mkdir -p dl
	cd dl; wget $(NGINX_URL)
	cd dl; wget $(RTMP_URL)
	touch dl/.downloaded

preppi:
	apt-get install libpcre3-dev libssl-dev
	rm -rf /opt/nginx
	mkdir /opt/nginx
	chown -R pi /opt/nginx

prepaws:
	yum update -y
	yum upgrade -y
	yum install -y git openssl-devel pcre-devel gcc
	rm -rf /opt/nginx
	mkdir /opt/nginx
	chown -R ec2-user /opt/nginx

.PHONY: clean
clean:
	rm -rf build

.PHONY: distclean
distclean: clean
	rm -rf dl

