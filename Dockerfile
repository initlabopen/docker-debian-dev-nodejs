FROM buildpack-deps:jessie
#
#
#
MAINTAINER "Kirill Müller" <krlmlr+docker@mailbox.org>

ENV USER_PASSW = ${USER_PASSW}
ENV ROOT_PASSW = ${ROOT_PASSW}

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory, but also be able to sudo
RUN useradd docker \
        && mkdir /home/docker \
        && chown docker:docker /home/docker \
        && addgroup docker staff \
        && addgroup docker sudo \
        && true

RUN echo 'docker:${USER_PASSW}' | chpasswd
RUN echo 'root:${ROOT_PASSW}' | chpasswd

EXPOSE 22
EXPOSE 8080
CMD ["/run.sh"]
