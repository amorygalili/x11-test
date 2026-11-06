FROM oraclelinux:8

# openbox, novnc and websockify come from EPEL; Xvnc comes from AppStream.
RUN dnf -y install oracle-epel-release-el8 \
 && dnf -y install --setopt=install_weak_deps=False \
      openbox \
      tigervnc-server-minimal \
      novnc \
      python3-websockify \
      xterm \
      xorg-x11-fonts-misc \
      dejavu-sans-fonts \
      dejavu-sans-mono-fonts \
 && dnf clean all \
 && rm -rf /var/cache/dnf

COPY openbox/ /etc/xdg/openbox/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Strip CRLFs so the scripts still run when the repo is edited on Windows.
# The index page makes http://host:6080/ connect straight away.
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh /etc/xdg/openbox/autostart \
 && chmod +x /usr/local/bin/entrypoint.sh \
 && echo '<!doctype html><meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=1&resize=remote">' \
      > /usr/share/novnc/index.html \
 && mkdir -p /tmp/.X11-unix \
 && chmod 1777 /tmp/.X11-unix \
 && useradd -m -u 1000 desktop

USER desktop
WORKDIR /home/desktop

ENV VNC_RESOLUTION=1280x800

EXPOSE 6080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -fsS -o /dev/null http://127.0.0.1:6080/vnc.html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
