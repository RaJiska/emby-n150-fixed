ARG EMBY_TAG=4.9.1.0
ARG LIBVA_VERSION=2.22.0
ARG GMMLIB_VERSION=22.7.2
ARG MEDIA_DRIVER_VERSION=25.1.4

# Ensures quick-fail if new there is a new release but not image tag pushed yet (saving on that Github Actions build times)
FROM emby/embyserver:${EMBY_TAG}

FROM ubuntu:18.04 AS builder

WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y \
	build-essential \
	git \
	cmake \
	automake \
	autoconf \
	libtool \
	m4 \
	pkg-config \
	libdrm-dev

RUN mkdir build build/usr build/lib

# Libva
RUN \
	git clone https://github.com/intel/libva.git  && \
	cd libva && \
	git checkout ${LIBVA_VERSION} && \
	./autogen.sh --prefix=/workspace/build/usr --libdir=/workspace/build/lib && \
	make -j$(nproc) && \
	make install && \
	cd -

# Gmmlib
RUN \
	git clone https://github.com/intel/gmmlib.git && \
	cd gmmlib && \
	git checkout ${GMMLIB_VERSION} && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=/workspace/build/usr -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_LIBDIR=/workspace/build/lib -DCMAKE_BUILD_TYPE=ReleaseInternal .. && \
	make -j$(nproc) && \
	make install && \
	cd ../../

# Media Driver
RUN \
	git clone https://github.com/intel/media-driver.git && \
	cd media-driver && \
	git checkout ${MEDIA_DRIVER_VERSION} && \
	mkdir build && \
	cd build && \
	export PKG_CONFIG_PATH=/workspace/build/lib/pkgconfig && \
	cmake -DCMAKE_LIBRARY_PATH=/workspace/build/lib -DCMAKE_INSTALL_PREFIX=/workspace/build/usr -DCMAKE_INSTALL_LIBDIR=/workspace/build/lib .. && \
	make -j$(nproc) && \
	make install

RUN find /workspace/build -name "*.so" -exec strip --strip-unneeded {} \;

FROM emby/embyserver:${EMBY_TAG} AS emby

COPY --from=builder /workspace/build/lib /lib