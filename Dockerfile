FROM swiftdocker/swift:latest

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
VOLUME ["/home/muukii/develop"]

# Expose ports.
EXPOSE 22 3306

# Define default command.
CMD ["/bin/zsh"]
