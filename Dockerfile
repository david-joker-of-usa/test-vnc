FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASSWORD=000000

# Install packages
RUN apt update -y && apt install --no-install-recommends -y \
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
    gnupg2 \
    ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Firefox PPA
RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' \
    > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

# Install Firefox + theme
RUN apt update -y && apt install -y \
    firefox \
    xubuntu-icon-theme && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Xauthority
RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c '\
vncserver :1 -geometry 1024x768 && \
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes \
-out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ \
--cert=self.pem 6080 localhost:5901 && \
tail -f /dev/null'
