FROM ghcr.io/cgwalters/fedora-silverblue:37

# Install the basics
RUN rpm-ostree install \
    distrobox iotop screen snapper strace terminator thunderbird vim gnome-tweak-tool neofetch && \
    #cleanup and verification stage
    rm -rf /var/lib/unbound && \ 
    ostree container commit

RUN echo "Defaults timestamp_timeout=30" > /etc/sudoers.d/timeout && \
    chmod 660 /etc/sudoers.d/timeout
