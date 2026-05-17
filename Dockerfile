FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps && \
    apt clean && rm -rf /var/lib/apt/lists/*

# 👉 Firefox (PPA বাদ দিয়ে stable way)
RUN apt update -y && apt install -y xubuntu-icon-theme

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c "\
    : \${USERNAME:?USERNAME not set}; \
    : \${PASSWORD:?PASSWORD not set}; \
    PORT=\${PORT:-6080}; \
    mkdir -p /root/.vnc; \
    echo \"\$PASSWORD\" | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd; \
    vncserver :1 -geometry 1024x768; \
    echo \"\$USERNAME:\$PASSWORD\" > /root/.auth; \
    websockify --web=/usr/share/novnc/ \
      --auth-plugin websockify.auth_plugins.BasicHTTPAuth \
      --auth-source /root/.auth \
      \$PORT localhost:5901 \
"
