#!/bin/bash

# remove unused files
function remove_data()
{
	if [ "$RK_BUILD_APP_TO_OEM_PARTITION" != "y" ];then
		# delete except app1, app2, app3, do like this: delete_except=".*/\|.*/app1\|.*/app2\|.*app3"
		delete_except=".*/\|.*/smart_door\|.*/fastboot_server"
		find "$RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/bin" ! -regex $delete_except -delete

		# both smart_door and fastboot_server need the so
		delete_except=".*/\|.*/librkaiq.so"
		find "$RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/lib" ! -regex $delete_except -delete

		local unused_in_oem=(\
			# wifi ko
			"usr/ko/cfg80211.ko" \
			"usr/ko/gf128mul.ko" \
			"usr/ko/ctr.ko"  \
			"usr/ko/libaes.ko" \
			"usr/ko/sha256_generic.ko" \
			"usr/ko/aes_generic.ko" \
			"usr/ko/ccm.ko" \
			"usr/ko/libarc4.ko" \
			"usr/ko/cmac.ko" \
			"usr/ko/mac80211.ko" \
			"usr/ko/ghash-generic.ko" \
			"usr/ko/libsha256.ko" \
			"usr/ko/gcm.ko" \
			# vendor_storage ko
			"usr/ko/rk_vendor_storage.ko" \
			"usr/ko/mtd_vendor_storage.ko" \
			# rve.ko
			"usr/ko/rve.ko" \
			# emmc flash
			"usr/ko/jbd2.ko" \
			"usr/ko/mbcache.ko" \
			"usr/ko/crc16.ko" \
			"usr/ko/ext4.ko" \
			# unuesd scripts
			"usr/ko/*.sh" \
			# unused data files
			"usr/lib/*.data" \
			)

		for i in ${unused_in_oem[@]}
		do
			rm -rf $RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/$i
		done
	fi

	local unused_in_rootfs=(\
		"lib/libatomic.so*" \
		"etc/iqfiles/*" \
		"etc/services" \
		"etc/protocols"  \
		"lib/libstdc++.so.6.0.25-gdb.py" \
		"lib/libitm.so*" \
		"usr/share/udhcpc" \
		"usr/bin/flash*" \
		"usr/bin/dnsmasq" \
		"usr/bin/hostapd" \
		"usr/bin/iperf" \
		"usr/bin/wifi_start.sh" \
		"mnt/sdcard" \
		)

	# if HI3861L wifi chip, remove wpa_cli, wpa_supplicant, wpa_supplicant.conf, wpa_supplicant_nl80211
	if [ "$RK_ENABLE_WIFI_CHIP" = "HI3861L" ];then
		local unused_in_rootfs=("${unused_in_rootfs[@]}" "usr/bin/wpa_*" "etc/wpa_*")
	fi

	for i in ${unused_in_rootfs[@]}
	do
		rm -rf $RK_PROJECT_PACKAGE_ROOTFS_DIR/$i
	done
}

function copy_data()
{
	# for writable, package them to userdata parition
	mkdir -p $RK_PROJECT_PACKAGE_USERDATA_DIR
	cp -r $RK_PROJECT_PATH_APP/userdata/* $RK_PROJECT_PACKAGE_USERDATA_DIR
}

function change_mode()
{
	# uvc related files
	chmod a+x $RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/bin/usb_config.sh
}

function rewrite_script()
{
# export default rk_log_level for app
echo "export rt_log_level=4" >> $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/profile.d/RkEnv.sh

# remove unused scripts
rm $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/S21appinit*
rm $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/S20urandom*

# rewite rcS
cat > $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcS <<EOF
#!/bin/sh
echo 256 > /proc/sys/kernel/threads-max

if [ -f "/etc/profile.d/RkEnv.sh" ]; then
	source /etc/profile.d/RkEnv.sh
fi

echo "start server" > /dev/kmsg
test -n "\$persist_camera_engine_log" && \
	fastboot_server &>/tmp/rkaiq0.log || \
	fastboot_server

cd /oem/usr/ko
test ! -f mtd_blkdevs.ko || insmod mtd_blkdevs.ko
test ! -f mtdblock.ko || insmod mtdblock.ko
test ! -f spi-nor.ko || insmod spi-nor.ko
sh /etc/init.d/S20linkmount start &

echo "start app" > /dev/kmsg
test -n "\$persist_camera_engine_log" && \
	smart_door &>/tmp/rkaiq1.log || \
	smart_door &

test ! -f snd-soc-rv1106.ko || insmod snd-soc-rv1106.ko
test ! -f rknpu.ko || insmod rknpu.ko

test ! -f usb-common.ko || insmod usb-common.ko
test ! -f udc-core.ko || insmod udc-core.ko
test ! -f dwc3-of-simple.ko || insmod dwc3-of-simple.ko
test ! -f dwc3.ko || insmod dwc3.ko
test ! -f extcon-core.ko || insmod extcon-core.ko
test ! -f phy-rockchip-inno-usb2.ko || insmod phy-rockchip-inno-usb2.ko
test ! -f configfs.ko || insmod configfs.ko
test ! -f libcomposite.ko || insmod libcomposite.ko
test ! -f usb_f_uvc.ko || insmod usb_f_uvc.ko
usb_config.sh &

test ! -f dw_mmc-rockchip.ko || insmod dw_mmc-rockchip.ko
EOF

if [ -n "${RK_WIFI_IRQ_GPIO}" ]; then
	echo "test ! -f hichannel.ko || insmod hichannel.ko hi_rk_irq_gpio=${RK_WIFI_IRQ_GPIO}" >> $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcS
else
	echo "test ! -f hichannel.ko || insmod hichannel.ko hi_rk_irq_gpio=40" >> $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcS
fi
echo "rkwifi_server start &" >> $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcS

chmod +x $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcS

# rewite rcK
cat > $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcK <<EOF
#!/bin/sh
echo "Start to killall task!!!"

while true
do
        if ps |grep -v grep  |grep smart_door;then
                echo "killall -9 smart_door"
                killall -9 smart_door
        else
                break
        fi
        sleep .5
done

killall fastboot_server
killall rkwifi_server
umount /data
EOF
chmod +x $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/rcK

}

#=========================
# post
#=========================
remove_data
copy_data
change_mode
rewrite_script
