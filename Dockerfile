FROM debian:bookworm-slim

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y guile-json qpdf poppler-utils

RUN mkdir -p /opt/addon
COPY src/addon.scm /opt/addon/
RUN chmod 755 /opt/addon/addon.scm

# test
RUN qpdf --version && pdftotext -h

# let it compile into the compile cache
RUN /opt/addon/addon.scm || true
ENTRYPOINT [ "/opt/addon/addon.scm" ]
