FROM registry.access.redhat.com/ubi8/ubi:latest

ENV pip_packages "ansible"

# Disable Subscription Manager Nag
RUN echo "enabled=0" >> /etc/yum/pluginconf.d/subscription-manager.conf

# Install systemd
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements
RUN yum makecache --timer \
 && yum -y install initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      which \
      hostname \
      python3 \
      openssh-clients \
      sshpass \
 && yum clean all

# Install Ansible via Pip
RUN pip3 install -U pip
RUN pip3 install $pip_packages

# Disable requiretty
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]