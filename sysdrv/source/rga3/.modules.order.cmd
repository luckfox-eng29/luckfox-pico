cmd_drivers/video/rockchip/rga3/modules.order := {   echo drivers/video/rockchip/rga3/rga3.ko; :; } | awk '!x[$$0]++' - > drivers/video/rockchip/rga3/modules.order
