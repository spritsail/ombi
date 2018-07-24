ARG OMBI_VER=3.0.3477

FROM spritsail/debian-builder:stretch-slim as deps

WORKDIR /output/usr/lib

RUN apt-get update && apt-get install -y libunwind8 libcurl4-openssl-dev ca-certificates \
 && mv /usr/lib/x86_64-linux-gnu/libssl.so.1.0.2 . \
 && mv /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2 . \
 && mv /usr/lib/x86_64-linux-gnu/libstdc++.so.6* . \
 && mv /usr/lib/x86_64-linux-gnu/libicu* . \
 && mv /usr/lib/x86_64-linux-gnu/libunwind* . \
 && mv /usr/lib/x86_64-linux-gnu/libcurl.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libidn2.so* . \
 && mv /usr/lib/x86_64-linux-gnu/librtmp.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libssh2.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libpsl.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libkrb5.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libk5crypto.so* . \
 && mv /usr/lib/x86_64-linux-gnu/liblber-2.4.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libgmp.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libgnutls.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libhogweed.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libkrb5support.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libnettle.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libnghttp2.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libsasl2.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libunistring.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libtasn1.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libp11-kit.so* . \
 && mv /usr/lib/x86_64-linux-gnu/libffi.so* . \
 && mv /lib/x86_64-linux-gnu/libkeyutils.so* . \
 && mv /lib/x86_64-linux-gnu/libidn.so* . \
 && mv /lib/x86_64-linux-gnu/libgpg-error.so* . \
 && mv /lib/x86_64-linux-gnu/libgcrypt.so* . \
 && mv /lib/x86_64-linux-gnu/libz.so* . \
 && mv /lib/x86_64-linux-gnu/libcom_err.so* . \
 && mv /lib/x86_64-linux-gnu/libuuid.so* . \
 && mv /lib/x86_64-linux-gnu/liblzma.so* . \
 && mv /lib/x86_64-linux-gnu/libgcc_s.so.1 . \
 && mkdir -p /output/usr/share \
 && mv /usr/share/ca-certificates /output/usr/share/ca-certificates

# ================

FROM microsoft/dotnet:2.0-sdk AS dotnet

ARG OMBI_VER

WORKDIR /tmp/ombi-src

# No npm officially in stretch... WHY
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get update && apt-get install -y binutils nodejs \
 && wget -O- https://github.com/tidusjar/Ombi/archive/v${OMBI_VER}.tar.gz \
          | tar xz --strip-components=1  \
 && cd src/Ombi \
 && mv ClientApp/styles/Styles.scss ClientApp/styles/styles.scss \
 && npm install \
 && node node_modules/gulp/bin/gulp.js build \
 && dotnet add package ILLink.Tasks -v 0.1.5-preview-1841731 \
 && dotnet publish -c Release -r linux-x64 -o /ombi /p:FullVer=${OMBI_VER} /p:SemVer=${OMBI_VER} \
 && strip -s /ombi/*.so

# ================

FROM spritsail/busybox

WORKDIR /ombi

ARG OMBI_VER
ENV SUID=952 SGID=900

LABEL maintainer="Spritsail <ombi@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Ombi" \
      org.label-schema.url="https://ombi.io/" \
      org.label-schema.description="Ombi allows easy requesting of new media by users" \
      org.label-schema.version=${OMBI_VER} \
      io.spritsail.version.ombi=${OMBI_VER}

COPY --from=deps /output /

COPY --from=dotnet /ombi /ombi

EXPOSE 5000

VOLUME ["/config"]

CMD ["/ombi/Ombi", "--storage", "/config"]
