FROM centos:stream9

RUN dnf install -y \
        epel-release

RUN dnf install -y \
        uwsgi \
        uwsgi-plugin-python3 \
        uwsgi-router-http \
        git \
        python3-pip \
        gcc \
        python3-devel

ENV PBR_VERSION=0.0.0.dev0

COPY octavia /src/octavia
COPY ovn-octavia-provider /src/ovn-octavia-provider
COPY etc/octavia.conf /etc/octavia/octavia.conf
COPY etc/octavia-uwsgi.ini /etc/octavia/octavia-uwsgi.ini

RUN pip3 install -c https://opendev.org/openstack/requirements/raw/tag/wallaby-eol/upper-constraints.txt \
        redis python-memcached \
        /src/octavia \
        /src/ovn-octavia-provider

ENV PYTHONPATH=/src/octavia:/src/ovn-octavia-provider
