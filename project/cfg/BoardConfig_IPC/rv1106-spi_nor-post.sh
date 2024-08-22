#!/bin/bash

rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/*.data # remove NPU model
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librknnmrt_rockauto.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librockauto.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librkAVS_genLut.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librkAVS_genStitch.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/rkmodel_*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/libsmartIr.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librve.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librockit_tiny.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librockit_full.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/librkAVS_stitchFor1106.so
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/libivs.so

rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/rk_*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/mp*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/vpu*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/rkisp*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/rkaiq*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/rga*
rm $RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/dump*

# delete nouse ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/gcm.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/ccm.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/sha256_generic.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/libaes.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/libsha256.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/gf128mul.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/cmac.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/libarc4.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/aes_generic.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/ctr.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/mac80211.ko
rm -f $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/atmb_iot_supplicant_demo

rm $RK_PROJECT_PACKAGE_ROOTFS_DIR/lib/libstdc++.so.6.0.25-gdb.py
rm -f $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/S50usbdevice

# insmod ko
chmod +x $RK_PROJECT_PACKAGE_OEM_DIR/usr/ko/insmod_ko.sh
target_file=$RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/init.d/S21appinit
search_string="start)"
insert_line="sh /oem/usr/ko/insmod_ko.sh"
sed -i "/$search_string/a $insert_line" "$target_file"
