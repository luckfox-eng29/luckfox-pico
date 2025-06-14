// SPDX-License-Identifier: GPL-2.0+
/*
 * FB driver for the HX8353D LCD Controller
 *
 * Copyright (c) 2014 Petr Olivka
 * Copyright (c) 2013 Noralf Tronnes
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/delay.h>
#include <video/mipi_display.h>
i
#include "fbtft.h"

#define DRVNAME "fb_gc9307"

static int init_display(struct fbtft_par *par)
{
	par->fbtftops.reset(par);
	mdelay(120);


	write_reg(par, 0xFE);
	write_reg(par, 0xEF);



	return 0;
};

static void set_addr_win(struct fbtft_par *par, int xs, int ys, int xe, int ye)
{
	/* column address */
	write_reg(par, 0x2a, xs >> 8, xs & 0xff, xe >> 8, xe & 0xff);

	/* Row address */
	write_reg(par, 0x2b, ys >> 8, ys & 0xff, ye >> 8, ye & 0xff);

	/* memory write */
	write_reg(par, 0x2c);
}

#define my BIT(7)
#define mx BIT(6)
#define mv BIT(5)
static int set_var(struct fbtft_par *par)
{
	/*
	 * madctl - memory data access control
	 *   rgb/bgr:
	 *   1. mode selection pin srgb
	 *	rgb h/w pin for color filter setting: 0=rgb, 1=bgr
	 *   2. madctl rgb bit
	 *	rgb-bgr order color filter panel: 0=rgb, 1=bgr
	 */
	switch (par->info->var.rotate) {
	case 0:
		write_reg(par, MIPI_DCS_SET_ADDRESS_MODE,
			  mx | my | (par->bgr << 3));
		break;
	case 270:
		write_reg(par, MIPI_DCS_SET_ADDRESS_MODE,
			  my | mv | (par->bgr << 3));
		break;
	case 180:
		write_reg(par, MIPI_DCS_SET_ADDRESS_MODE,
			  par->bgr << 3);
		break;
	case 90:
		write_reg(par, MIPI_DCS_SET_ADDRESS_MODE,
			  mx | mv | (par->bgr << 3));
		break;
	}

	return 0;
}

static struct fbtft_display display = {
	.regwidth = 8,
	.width = 128,
	.height = 160,
	.fbtftops = {
		.init_display = init_display,
		.set_var = set_var,
	},
};

FBTFT_REGISTER_DRIVER(DRVNAME, "sino,gc9307", &display);

MODULE_ALIAS("spi:" DRVNAME);
MODULE_ALIAS("platform:" DRVNAME);
MODULE_ALIAS("spi:gc9307");
MODULE_ALIAS("platform:gc9307");

MODULE_DESCRIPTION("FB driver for the GC9307 LCD Controller");
MODULE_AUTHOR("Luckfox");
MODULE_LICENSE("GPL");
