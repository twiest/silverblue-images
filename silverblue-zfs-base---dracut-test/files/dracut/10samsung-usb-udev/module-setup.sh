#!/usr/bin/bash

# called by dracut
install() {
    inst_rules "$moddir/10-samsung-usb.rules"

    prepare_udev_rules 10-samsung-usb.rules
}
