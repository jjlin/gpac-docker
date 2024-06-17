FROM ubuntu:24.04 AS build

SHELL ["/bin/bash", "-c"]

COPY deps-build.conf .
RUN . deps-build.conf \
 && apt-get update \
 && apt-get install -y "${deps[@]}"

ARG GIT_REF="master"
RUN git clone --depth 1 --branch "${GIT_REF}" https://github.com/gpac/gpac.git

WORKDIR gpac

RUN ./configure --prefix=/usr/local/gpac \
 && make \
 && make install

FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

COPY deps-runtime.conf .
RUN . deps-runtime.conf \
 && apt-get update \
 && apt-get install -y "${deps[@]}" \
 && apt-get clean \
 && rm -f deps-runtime.conf \
 && rm -rf /usr/share/{doc,man}/*

COPY --from=build /usr/local/gpac /usr/local/gpac

RUN echo /usr/local/gpac/lib > /etc/ld.so.conf.d/gpac.conf \
 && ldconfig

RUN ln -s /usr/local/gpac/bin/* /usr/local/bin

WORKDIR /gpac
