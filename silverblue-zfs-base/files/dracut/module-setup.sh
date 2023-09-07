#!/usr/bin/bash

# called by dracut
install() {
    local _i

    # Fixme: would be nice if we didn't have to guess, which rules to grab....
    # ultimately, /lib/initramfs/rules.d or somesuch which includes links/copies
    # of the rules we want so that we just copy those in would be best
    inst_multiple udevadm cat uname blkid
    inst_dir /etc/udev
    inst_multiple -o /etc/udev/udev.conf

    [[ -d ${initdir}/$systemdutildir ]] || mkdir -p "${initdir}/$systemdutildir"
    for _i in "${systemdutildir}"/systemd-udevd "${udevdir}"/udevd /sbin/udevd; do
        [[ -x $dracutsysrootdir$_i ]] || continue
        inst "$_i"

        if ! [[ -f ${initdir}${systemdutildir}/systemd-udevd ]]; then
            ln -fs "$_i" "${initdir}${systemdutildir}"/systemd-udevd
        fi
        break
    done
    if ! [[ -e ${initdir}${systemdutildir}/systemd-udevd ]]; then
        derror "Cannot find [systemd-]udevd binary!"
        exit 1
    fi

    inst_rules "$moddir/10-samsung-usb.rules"

    prepare_udev_rules 10-samsung-usb.rules
}
