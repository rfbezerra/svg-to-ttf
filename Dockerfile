FROM rfbezerra/fontcustom:latest

LABEL maintainer="rfbezerra@gmail.com"

RUN apk add nodejs yarn parallel inkscape xvfb woff2 curl gcc libc-dev zlib-dev make && \
    apk add fontforge --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    mkdir -p /fonts/input && \
    mkdir -p /fonts/build && \
    curl -o code.zip -Ls http://pkgs.fedoraproject.org/repo/pkgs/woff/woff-code-latest.zip/1dcdbc9a7f48086185740c185d822279/woff-code-latest.zip && \
    mkdir -p sfnt2woff && \
    unzip -d sfnt2woff code.zip && rm code.zip && \
    make -C sfnt2woff && \
    mv sfnt2woff/sfnt2woff /usr/local/bin/ && \
    rm -rf sfnt2woff && \
    apk del gcc libc-dev zlib-dev make && \
    rm -rf /var/cache/apk/*

COPY convert-icons.sh /fonts

WORKDIR /fonts

VOLUME /fonts

ENTRYPOINT ["/fonts/convert-icons.sh"]
