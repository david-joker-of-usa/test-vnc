FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# User Config
ENV USERNAME=admin
ENV PASSWORD=admin123
ENV PORT=7681

# Install packages
RUN apt update -y && \
    apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    software-properties-common \
    gnupg \
    gnupg2 \
    gpg-agent \
    ca-certificates \
    openssl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Firefox PPA
RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' \
    | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

# Install Firefox
RUN apt update -y && \
    apt install -y firefox xubuntu-icon-theme && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install ttyd
RUN wget -O /bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Create user
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    adduser $USERNAME sudo

# Setup VNC
RUN mkdir -p /home/$USERNAME/.vnc && \
    touch /home/$USERNAME/.Xauthority && \
    echo "$PASSWORD" | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.vnc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.Xauthority

EXPOSE 5901
EXPOSE 6080
EXPOSE 7681

CMD ["/bin/bash", "-c", "\
echo \"export PS1='\\\\[\\\\033[01;32m\\\\]$USERNAME@\\\\h\\\\[\\\\033[00m\\\\]:\\\\[\\\\033[01;34m\\\\]\\\\w\\\\[\\\\033[00m\\\\]\\\\$ '\" >> /home/$USERNAME/.bashrc && \
su - $USERNAME -c 'vncserver :1 -geometry 1024x768 -localhost no && \
openssl req -new -subj \"/C=JP\" -x509 -days 365 -nodes -out /home/$USERNAME/self.pem -keyout /home/$USERNAME/self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=/home/$USERNAME/self.pem 6080 localhost:5901' && \
/bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]
