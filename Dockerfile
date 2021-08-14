# Runtime stage
FROM 1-base-ubuntu:focal

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

#Define display vars
ENV VNCPASSWD=testen
ENV DISPLAY=:99
ENV DISPLAY_WIDTH=1280
ENV DISPLAY_HEIGHT=768
#Color depth 
ENV DEPTH=24

RUN \
 echo "### enable src repos ##" && \
 sed -i "/^#.*deb.*main restricted$/s/^# //g" /etc/apt/sources.list && \
 sed -i "/^#.*deb.*universe$/s/^# //g" /etc/apt/sources.list && \

#echo "Adding nginx repo to fetch latest version of nginx for ${REL}" && \
#echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" > /etc/apt/sources.list.d/nginx.list && \
#echo "deb-src http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" >> /etc/apt/sources.list.d/nginx.list && \

#curl -o /tmp/nginx_signing.key http://nginx.org/keys/nginx_signing.key && \
#apt-key add /tmp/nginx_signing.key && \
#rm -rf /tmp/nginx_signing.key && \
 
 # sed -i "/^#.*deb.*multiverse$/s/^# //g" /etc/apt/sources.list && \
 # fix issue when installing certen build-dep sources
 mkdir /usr/share/man/man1/ && \
 echo "**** install packages for building and running/using noVNC ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	### For building ###
	git \
	cmake \
	### For running ###
    openbox \
	#obconf \
	#python3-numpy \
	#python-minimal \
	#python-xdg \
	#xterm \
	#openssh-client \
	net-tools \
	nginx \
	xvfb && \
	
# remove temp sourcelist en update source list
rm -rf /etc/apt/sources.list.d/nginx.list && \
#apt update && \

#build xvfb from source (maby for future build):
#apt-get build-dep -y -o APT::Get::Build-Dep-Automatic=true xvfb && \
#cd /tmp && \
#apt-get source xvfb && \
#apt-get install libgl1-mesa-dev && \
#cd /tmp/xorg-server-* && \
#./configure --enable-shared=yes && \
#make install && \

# install noVNC to usr/share. When starting the container for the first time we move this to: /config/www
cd /usr/share && \
git clone https://github.com/novnc/noVNC && \
rm -rf /usr/share/noVNC/.git* .esl* && \
rm -rf /usr/share/noVNC/.esl* && \
# build and install libvncserver
apt-get build-dep -y -o APT::Get::Build-Dep-Automatic=true libvncserver && \
cd / && \
git clone https://github.com/LibVNC/libvncserver && \
cd /libvncserver && \
cmake . && \
make install && \
#cmake --build .

# build and install x11vnc
apt-get build-dep -o APT::Get::Build-Dep-Automatic=true -y x11vnc && \
cd / && \
git clone https://github.com/LibVNC/x11vnc && \
cd /x11vnc && \
autoreconf -v --install  && \
./configure  && \
make install  && \

# config
#openbox
cp /etc/xdg/openbox/menu.xml /var/lib/openbox/debian-menu.xml && \
mkdir -p ~/.config/openbox && \
#echo "${APP}" > ~/.config/openbox/autostart && \
echo "**** cleanup ****" && \
apt-get autoremove -y --purge git build-essential cmake make linux-libc-dev nettle-dev libx11-dev libssl-dev && \
apt install -y --no-install-recommends \
	libxtst6 \
	libavahi-client3 \
	#libgl1 \
	#libunwind8 \
	python-numpy \
	python-xdg \
	liblzo2-2 \
	openbox \
	libxdamage1 && \
apt-get autoremove -y --purge && \
apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/cache/apt/* \
	/var/tmp/* \
	/var/log/* \
	/usr/share/doc/* \
	/usr/share/info/* \
	/var/cache/debconf/* \
	/usr/share/man/* \
	# remove stuff
	/libvncserver \
	/x11vnc \
	# clean nginx, we replace tese later on
	/etc/nginx/sites-available/default \
	/etc/nginx/nginx.conf \
	# remove libs
	/usr/lib/x86_64-linux-gnu/libLLVM-10.so.1
	
# add local files
COPY root/ /

ENTRYPOINT ["/init"]