ARG OMBI_VER=4.0.381
ARG OMBI_COMMIT=cc5bbd5042e6b394762be40d2046ef29b54f8f04

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS builder

ARG OMBI_VER
ARG OMBI_COMMIT

SHELL ["/bin/sh", "-exc"]

WORKDIR /tmp/ombi-src

RUN apk add \
        binutils \
        g++ \
        gcc \
        git \
        make \
        python2 \
        yarn

RUN git clone https://github.com/tidusjar/Ombi.git -b feature/v4 . \
 && git -c advice.detachedHead=false checkout "${OMBI_COMMIT}"

# Build ClientApp webpack into wwwroot/dist
WORKDIR /tmp/ombi-src/src/Ombi/ClientApp
RUN yarn install \
 && yarn run build --outputPath /ombi/ClientApp/dist

WORKDIR /tmp/ombi-src/src/Ombi
RUN dotnet publish \
        -c Release \
        -r linux-musl-x64 \
        -o /ombi \
        /p:FullVer=${OMBI_VER} \
        /p:SemVer=${OMBI_VER}

# ================

FROM spritsail/alpine:3.12

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

RUN apk add --no-cache \
        icu-libs \
        libintl \
        libssl1.1 \
        libstdc++

COPY --from=builder /ombi /ombi

EXPOSE 5000

VOLUME ["/config"]

CMD ["/ombi/Ombi", "--storage", "/config", "--host", "http://0.0.0.0:5000;http://[::]:5000"]
