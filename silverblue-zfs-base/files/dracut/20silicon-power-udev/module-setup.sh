#!/usr/bin/bash

# called by dracut
install() {
    inst_rules "$moddir/20-silicon-power.rules"

    prepare_udev_rules 20-silicon-power.rules
}
