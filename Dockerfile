FROM ubuntu:14.04

MAINTAINER Muukii <m@muukii.me>

ENV HOSTNAME [Swift]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV DOCKER_CONTAINER YES

# env
RUN sudo apt-get update -y && apt-get dist-upgrade -fy
RUN apt-get install -y \
	build-essential \
	mercurial \
	git \
	wget \
	curl \
	zsh \
	vim \
	tmux

# Generate User
RUN useradd -s /bin/zsh -m muukii
RUN echo 'muukii ALL=(ALL:ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/dev
RUN gpasswd -a muukii root
ENV HOME /home/muukii

# Swift
ENV SWIFT_BRANCH development
ENV SWIFT_VERSION DEVELOPMENT-SNAPSHOT-2016-02-08-a
ENV SWIFT_PLATFORM ubuntu14.04

# Install related packages
RUN apt-get update && \
    apt-get install -y build-essential wget clang libedit-dev python2.7 python2.7-dev libicu52 rsync libxml2 git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install Swift Ubuntu 14.04 Snapshot
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget $SWIFT_URL && \
    wget $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*

# Set Swift Path
ENV PATH /usr/bin:$PATH

# Print Installed Swift Version
RUN swift --version

# User env
USER muukii
WORKDIR /home/muukii/
RUN git clone https://github.com/muukii/dotfiles.git ~/dotfiles
WORKDIR /home/muukii/dotfiles
RUN make symlink
RUN make vim
WORKDIR /home/muukii
RUN mkdir .ssh

# Volume
VOLUME ["~/develop"]

# Expose ports.
EXPOSE 22 3306

# Define default command.
CMD ["/bin/zsh"]
