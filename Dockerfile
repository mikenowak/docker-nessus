FROM centos:7
MAINTAINER Mike Nowak

ENV NESSUS_VERSION="6.11.1"

RUN set -x \
  # Update the base image
  && yum update -y \

  # Find the token 
  && TOKEN=$(curl -ssl -o - "https://www.tenable.com/products/nessus/select-your-operating-system" | sed -n -e 's/.*id="timecheck" class="hidden">\(.*\)<\/div>.*/\1/p') \

  # Import GPG for Tanable
  && rpm --import https://static.tenable.com/marketing/RPM-GPG-KEY-Tenable \

  # Fetch the rpm
  && curl -ssL -o /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
    "http://downloads.nessus.org/nessus3dl.php?file=Nessus-${NESSUS_VERSION}-es7.x86_64.rpm&licence_accept=yes&t=${TOKEN}" \

  # Install the rpm
  && rpm -ivh /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \

  # Cleanup
  && rm /tmp/Nessus-${NESSUS_VERSION}-es7.x86_64.rpm \
  && yum clean all \
  && rm -rf /var/cache/yum

VOLUME ["/opt/nessus"]
EXPOSE 8834
CMD ["/opt/nessus/sbin/nessus-service"]
