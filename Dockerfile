# OpenVAS
# Based on: http://hackertarget.com/install-openvas-7-ubuntu/

FROM ubuntu
MAINTAINER Mike Splain mike.splain@gmail.com

RUN apt-get update -y && \
    apt-get install build-essential \
                    bison \
                    flex \
                    cmake \
                    rpm \
                    alien \
                    nsis \
                    pkg-config \
                    libglib2.0-dev \
                    libgnutls-dev \
                    libpcap0.8-dev \
                    libgpgme11 \
                    libgpgme11-dev \
                    openssh-client \
                    doxygen \
                    libuuid1 \
                    uuid-dev \
                    sqlfairy \
                    xmltoman \
                    sqlite3 \
                    libsqlite3-dev \
                    libsqlite3-tcl \
                    libxml2-dev \
                    libxslt1.1 \
                    libxslt1-dev \
                    libhiredis-dev \
                    heimdal-dev \
                    libssh-dev \
                    libpopt-dev \
                    mingw32 \
                    xsltproc \
                    libmicrohttpd-dev \
                    wget \
                    rsync \
                    texlive-latex-base \
                    texlive-latex-recommended \
                    texlive-latex-extra \
                    unzip \
                    wapiti \
                    nmap \
                    -y --no-install-recommends && \
    mkdir /openvas-src && \
    cd /openvas-src && \
        wget http://wald.intevation.org/frs/download.php/2191/openvas-libraries-8.0.5.tar.gz -O openvas-libraries.tar.gz && \
        wget http://wald.intevation.org/frs/download.php/2129/openvas-scanner-5.0.4.tar.gz -O openvas-scanner.tar.gz && \
        wget http://wald.intevation.org/frs/download.php/2195/openvas-manager-6.0.6.tar.gz -O openvas-manager.tar.gz && \
        wget http://wald.intevation.org/frs/download.php/2200/greenbone-security-assistant-6.0.6.tar.gz -O greenbone-security-assistant.tar.gz && \
        wget http://wald.intevation.org/frs/download.php/2209/openvas-cli-1.4.3.tar.gz -O openvas-cli.tar.gz && \
        wget http://wald.intevation.org/frs/download.php/1975/openvas-smb-1.0.1.tar.gz -O openvas-smb.tar.gz && \
    cd /openvas-src/ && \
        tar zxvf openvas-libraries.tar.gz && \
        tar zxvf openvas-scanner.tar.gz && \
        tar zxvf openvas-manager.tar.gz && \
        tar zxvf greenbone-security-assistant.tar.gz && \
        tar zxvf openvas-cli.tar.gz && \
        tar zxvf openvas-smb.tar.gz && \
    cd /openvas-src/openvas-libraries-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    cd /openvas-src/openvas-scanner-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    cd /openvas-src/openvas-manager-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    cd /openvas-src/greenbone-security-assistant-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    cd /openvas-src/openvas-cli-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    mkdir /redis && \
        cd /redis && \
        wget http://download.redis.io/releases/redis-2.8.19.tar.gz  && \
            tar zxvf redis-2.8.19.tar.gz && \
            cd redis-2.8.19 && \
            make -j $(nproc)&& \
            make install && \
            rm -fr /redis && \
    apt-get remove heimdal-dev -y && \
    apt-get install curl \
            libcurl4-gnutls-dev \
            libkrb5-dev -y && \
    cd /openvas-src/openvas-smb-* && \
        mkdir source && \
        cd source && \
        cmake .. && \
        make && \
        make install && \
    rm -rf /openvas-src && \
    mkdir /dirb && \
    cd /dirb && \
    wget http://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz && \
        tar -zxvf dirb222.tar.gz && \
        cd dirb222 && \
        chmod 700 -R * && \
        ./configure && \
        make && \
        make install && \
    cd / && \
    cd /tmp && \
    wget https://github.com/Arachni/arachni/releases/download/v1.3.2/arachni-1.3.2-0.5.9-linux-x86_64.tar.gz && \
        tar -zxvf arachni-1.3.2-0.5.9-linux-x86_64.tar.gz && \
        mv arachni-1.3.2-0.5.9 /opt/arachni && \
        ln -s /opt/arachni/bin/* /usr/local/bin/ && \
    cd ~ && \
    wget https://github.com/sullo/nikto/archive/master.zip && \
    unzip master.zip -d /tmp && \
    mv /tmp/nikto-master/program /opt/nikto && \
    rm -rf /tmp/nikto-master && \
    echo "EXECDIR=/opt/nikto\nPLUGINDIR=/opt/nikto/plugins\nDBDIR=/opt/nikto/databases\nTEMPLATEDIR=/opt/nikto/templates\nDOCDIR=/opt/nikto/docs" >> /opt/nikto/nikto.conf && \
    ln -s /opt/nikto/nikto.pl /usr/local/bin/nikto.pl && \
    ln -s /opt/nikto/nikto.conf /etc/nikto.conf && \
    mkdir -p /openvas && \
    wget https://svn.wald.intevation.org/svn/openvas/trunk/tools/openvas-check-setup --no-check-certificate -O /openvas/openvas-check-setup && \
    chmod a+x /openvas/openvas-check-setup && \
    apt-get clean -yq && \
    apt-get autoremove -yq && \
    apt-get purge -y --auto-remove build-essential cmake && \
    rm -rf /var/lib/apt/lists/*

ADD bin/* /openvas/
RUN chmod 700 /openvas/*.sh && \
    bash /openvas/setup.sh
ADD config/redis.config /etc/redis/redis.config

CMD bash /openvas/start.sh

# Expose UI
EXPOSE 443 9390 9391 9392
