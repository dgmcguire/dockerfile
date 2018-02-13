FROM erlang:20-alpine AS base
RUN mkdir -p /usr/local/src/elixir

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.6.1" LANG=C.UTF-8

FROM base AS builder

RUN set -xe
ENV ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz"
ENV ELIXIR_DOWNLOAD_SHA256="91109a1774e9040fb10c1692c146c3e5a102e621e9c48196bfea7b828d54544c"
RUN apk add --update --no-cache curl
RUN curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL
RUN echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c -
RUN tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz
RUN rm elixir-src.tar.gz
RUN cd /usr/local/src/elixir
RUN apk add --no-cache make
RUN cd /usr/local/src/elixir && make install clean
#RUN apk del --update --no-cache curl
#RUN apk del --no-cache make

FROM base AS final_release
COPY --from=builder /usr/local/src/elixir /usr/local/src/elixir

CMD ["iex"]
