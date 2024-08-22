#!/bin/bash

# remove unused files
function remove_data()
{
	if [ "$RK_BUILD_APP_TO_OEM_PARTITION" = "y" ];then
		# delete except app1, app2, app3, do like this: delete_except=".*/\|.*/app1\|.*/app2\|.*app3"
		delete_except=".*/\|.*/smart_door"
		find "$RK_PROJECT_PACKAGE_OEM_DIR/usr/bin/" ! -regex $delete_except -delete

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
			# rve.ko
			"usr/ko/rve.ko" \
			# unuesd scripts
			"usr/ko/*.sh" \
			# use static-link for app
			"usr/lib/*.so*" \
			# unused data files
			"usr/lib/*.data" \
			)

		for i in ${unused_in_oem[@]}
		do
			rm -rf $RK_PROJECT_PACKAGE_OEM_DIR/$i
		done
	fi
}

#=========================
# pre oem
#=========================
remove_data
