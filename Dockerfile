FROM centos:7

ENV NESSUS_VERSION="6.9.2"

RUN set -x \
    && yum update -y \
    && curl -ssl -o /tmp/nessus.html "https://www.tenable.com/products/nessus/select-your-operating-system" \
    && TOKEN=$(sed -n -e 's/.*id="timecheck" class="hidden">\(.*\)<\/div>.*/\1/p' /tmp/nessus.html) \
    && curl -ssL -o /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
      "http://downloads.nessus.org/nessus3dl.php?file=Nessus-${NESSUS_VERSION}-es7.x86_64.rpm&licence_accept=yes&t=${TOKEN}" \
    && rpm -ivh /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
    && rm /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm /tmp/nessus.html

VOLUME /opt/nessus

EXPOSE 8834
CMD ["/opt/nessus/sbin/nessus-service"]
