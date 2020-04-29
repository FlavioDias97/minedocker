FROM ubuntu:trusty

# Setup Container
VOLUME ["/minecraft"]
EXPOSE 25565

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y openjdk-8-jre

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
  apt-get -y install  libmozjs-24-bin wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/js js /usr/bin/js24 100

#RUN apt install htop

RUN wget -q -O /usr/bin/jsawk https://github.com/micha/jsawk/raw/master/jsawk

RUN chmod +x /usr/bin/jsawk

RUN useradd -M -s /bin/false minecraft --uid 1000 && \
  mkdir -p /minecraft && \
  chown -R minecraft:minecraft /minecraft && \
  chmod -R 755 /minecraft
  
COPY server.properties /minecraft
COPY start.sh /start.sh
RUN chmod 755 /start.sh

CMD ["/start.sh"]
