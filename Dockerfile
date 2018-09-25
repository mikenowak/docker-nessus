FROM centos:7
MAINTAINER Mike Nowak

ENV NESSUS_VERSION="7.1.3"

VOLUME ["/opt/nessus"]

RUN set -x \
  && yum update -y \
  \
  # Find the data-page-id and data-download-id
  && DOWNLOAD_PAGE=$(curl -sSL -o - "https://www.tenable.com/downloads/nessus" | sed -n -e 's/.*data-page-id="\([0-9]*\)".*data-download-id="\([0-9]*\)".*data-file-name="\([a-zA-Z0-9_\.-]\+\-es7\.x86_64\.rpm\).*".*/\1:\2/p') \
  && PAGE_ID=${DOWNLOAD_PAGE%:*} \
  && DOWNLOAD_ID=${DOWNLOAD_PAGE#*:} \
  \
  # Import Tanable's GPG key
  && rpm --import https://static.tenable.com/marketing/RPM-GPG-KEY-Tenable \
  \
  # Get a token before hitting the download page
  && TOKEN=$(curl --cookie-jar /tmp/cookie -sSL -o - https://www.tenable.com/downloads/nessus | sed -n -e 's/.*name="authenticity_token" value="\(.*\)".*/\1/p') \
  \
  # Fetch the rpm
  && curl -sSL "https://www.tenable.com/downloads/pages/${PAGE_ID}/downloads/${DOWNLOAD_ID}/get_download_file" \
    -o "/tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm" \
    -H 'Origin: https://www.tenable.com' \
    -H 'Referer: https://www.tenable.com/downloads/nessus' \
    --cookie /tmp/cookie \
    --data-urlencode "authenticity_token=${TOKEN}" \
    --data 'utf8=%E2%9C%93&_method=get_download_file&i_agree_to_tenable_license_agreement=true&commit=I+Agree' \
    --compressed
  \
  # Install the rpm
  && rpm -ivh /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
  \
  # Redirect logs to stdout
  && for lf in backend.log nessusd.messages www_server.log; do \
     ln -s /dev/stdout /opt/nessus/var/nessus/logs/${lf}; done \
  \
  # Cleanup
  && rm /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
  && rm -f /tmp/cookie \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /opt/nessus/var/nessus/{uuid,*.db*,master.key}

EXPOSE 8834
CMD ["/opt/nessus/sbin/nessus-service"]
