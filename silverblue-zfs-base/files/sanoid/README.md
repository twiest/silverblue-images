# Description

I build this package using the included spec file in the tar ball.

I built it in a podman container like so:
podman run -it --rm -v $PWD:/build:z fedora:38 bash

rpmbuild --target noarch -bb sanoid.spec


I use this walkthrough to figure out the correct setup / commands:
https://opensource.com/article/18/9/how-build-rpm-packages
