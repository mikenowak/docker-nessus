FROM centos:7
MAINTAINER Mike Nowak

ENV NESSUS_VERSION="7.0.3"

VOLUME ["/opt/nessus"]

RUN set -x \
  && yum update -y \

  # Find the download-id
  && DOWNLOAD_ID=$(curl -ssl -o - "https://www.tenable.com/downloads/nessus" | sed -n -e 's/.*data-download-id="\([0-9]*\)".*data-file-name="\([a-zA-Z0-9_\.-]\+\-es7\.x86_64\.rpm\).*".*/\1/p') \

  # Import Tanable's GPG key
  && rpm --import https://static.tenable.com/marketing/RPM-GPG-KEY-Tenable \

  # Fetch the rpm
  && curl -ssL -o /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
    "https://tenable-downloads-production.s3.amazonaws.com/uploads/download/file/${DOWNLOAD_ID}/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm" \

  # Install the rpm
  && rpm -ivh /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \

  # Redirect logs to stdout
  && for lf in backend.log nessusd.messages www_server.log; do \
     ln -s /dev/stdout /opt/nessus/var/nessus/logs/${lf}; done \

  # Cleanup
  && rm /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /opt/nessus/var/nessus/{uuid,*.db*,master.key}

EXPOSE 8834
CMD ["/opt/nessus/sbin/nessus-service"]
