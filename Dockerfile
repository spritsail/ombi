ARG OMBI_VER=3.0.4036

FROM microsoft/dotnet:2.1-sdk-alpine AS builder

ARG OMBI_VER

WORKDIR /tmp/ombi-src

RUN apk add binutils yarn \
 && wget -O- https://github.com/tidusjar/Ombi/archive/v${OMBI_VER}.tar.gz \
          | tar xz --strip-components=1  \
 && cd src/Ombi \
 && yarn install --prod \
 && yarn run publish \
 && dotnet publish -c Release -r linux-musl-x64 -o /ombi /p:FullVer=${OMBI_VER} /p:SemVer=${OMBI_VER} \
 && strip -s /ombi/*.so

# ================

FROM spritsail/alpine:3.8

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

RUN apk add --no-cache libstdc++ icu-libs libintl libssl1.0

COPY --from=builder /ombi /ombi

EXPOSE 5000

VOLUME ["/config"]

CMD ["/ombi/Ombi", "--storage", "/config"]
