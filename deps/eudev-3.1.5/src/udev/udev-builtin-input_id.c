/*
 * expose input properties via udev
 *
 * Copyright (C) 2009 Martin Pitt <martin.pitt@ubuntu.com>
 * Portions Copyright (C) 2004 David Zeuthen, <david@fubar.dk>
 * Copyright (C) 2011 Kay Sievers <kay@vrfy.org>
 * Copyright (C) 2014 Carlos Garnacho <carlosg@gnome.org>
 * Copyright (C) 2014 David Herrmann <dh.herrmann@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <linux/limits.h>
#include <linux/input.h>

#include "udev.h"
#include "util.h"

/* we must use this kernel-compatible implementation */
#define BITS_PER_LONG (sizeof(unsigned long) * 8)
#define NBITS(x) ((((x)-1)/BITS_PER_LONG)+1)
#define OFF(x)  ((x)%BITS_PER_LONG)
#define BIT(x)  (1UL<<OFF(x))
#define LONG(x) ((x)/BITS_PER_LONG)
#define test_bit(bit, array)    ((array[LONG(bit)] >> OFF(bit)) & 1)

static inline int abs_size_mm(const struct input_absinfo *absinfo) {
        /* Resolution is defined to be in units/mm for ABS_X/Y */
        return (absinfo->maximum - absinfo->minimum) / absinfo->resolution;
}

static void extract_info(struct udev_device *dev, const char *devpath, bool test) {
        char width[DECIMAL_STR_MAX(int)], height[DECIMAL_STR_MAX(int)];
        struct input_absinfo xabsinfo = {}, yabsinfo = {};
        _cleanup_close_ int fd = -1;

        fd = open(devpath, O_RDONLY|O_CLOEXEC);
        if (fd < 0)
                return;

        if (ioctl(fd, EVIOCGABS(ABS_X), &xabsinfo) < 0 ||
            ioctl(fd, EVIOCGABS(ABS_Y), &yabsinfo) < 0)
                return;

        if (xabsinfo.resolution <= 0 || yabsinfo.resolution <= 0)
                return;

        snprintf(width, sizeof(width), "%d", abs_size_mm(&xabsinfo));
        snprintf(height, sizeof(height), "%d", abs_size_mm(&yabsinfo));

        udev_builtin_add_property(dev, test, "ID_INPUT_WIDTH_MM", width);
        udev_builtin_add_property(dev, test, "ID_INPUT_HEIGHT_MM", height);
}

/*
 * Read a capability attribute and return bitmask.
 * @param dev udev_device
 * @param attr sysfs attribute name (e. g. "capabilities/key")
 * @param bitmask: Output array which has a sizeof of bitmask_size
 */
static void get_cap_mask(struct udev_device *dev,
                         struct udev_device *pdev, const char* attr,
                         unsigned long *bitmask, size_t bitmask_size,
                         bool test) {
        const char *v;
        char text[4096];
        unsigned i;
        char* word;
        unsigned long val;

        v = udev_device_get_sysattr_value(pdev, attr);
        if (!v)
                v = "";

        snprintf(text, sizeof(text), "%s", v);
        log_debug("%s raw kernel attribute: %s", attr, text);

        memzero(bitmask, bitmask_size);
        i = 0;
        while ((word = strrchr(text, ' ')) != NULL) {
                val = strtoul (word+1, NULL, 16);
                if (i < bitmask_size/sizeof(unsigned long))
                        bitmask[i] = val;
                else
                        log_debug("ignoring %s block %lX which is larger than maximum size", attr, val);
                *word = '\0';
                ++i;
        }
        val = strtoul (text, NULL, 16);
        if (i < bitmask_size / sizeof(unsigned long))
                bitmask[i] = val;
        else
                log_debug("ignoring %s block %lX which is larger than maximum size", attr, val);

        if (test) {
                /* printf pattern with the right unsigned long number of hex chars */
                snprintf(text, sizeof(text), "  bit %%4u: %%0%zulX\n", 2 * sizeof(unsigned long));
                log_debug("%s decoded bit map:", attr);
                val = bitmask_size / sizeof (unsigned long);
                /* skip over leading zeros */
                while (bitmask[val-1] == 0 && val > 0)
                        --val;
                for (i = 0; i < val; ++i) {
                        DISABLE_WARNING_FORMAT_NONLITERAL;
                        log_debug(text, i * BITS_PER_LONG, bitmask[i]);
                        REENABLE_WARNING;
                }
        }
}

/* pointer devices */
static bool test_pointers(struct udev_device *dev,
                          const unsigned long* bitmask_ev,
                          const unsigned long* bitmask_abs,
                          const unsigned long* bitmask_key,
                          const unsigned long* bitmask_rel,
                          const unsigned long* bitmask_props,
                          bool test) {
        int is_mouse = 0;
        int is_touchpad = 0;
        bool ret = false;

        if (test_bit(INPUT_PROP_ACCELEROMETER, bitmask_props)) {
                udev_builtin_add_property(dev, test, "ID_INPUT_ACCELEROMETER", "1");
                return true;
        }

        if (!test_bit(EV_KEY, bitmask_ev)) {
                if (test_bit(EV_ABS, bitmask_ev) &&
                    test_bit(ABS_X, bitmask_abs) &&
                    test_bit(ABS_Y, bitmask_abs) &&
                    test_bit(ABS_Z, bitmask_abs)) {
                        udev_builtin_add_property(dev, test, "ID_INPUT_ACCELEROMETER", "1");
                        ret = true;
                }
                return ret;
        }

        if (test_bit(EV_ABS, bitmask_ev) &&
            test_bit(ABS_X, bitmask_abs) && test_bit(ABS_Y, bitmask_abs)) {
                if (test_bit(BTN_STYLUS, bitmask_key) || test_bit(BTN_TOOL_PEN, bitmask_key)) {
                        udev_builtin_add_property(dev, test, "ID_INPUT_TABLET", "1");
                        ret = true;
                } else if (test_bit(BTN_TOOL_FINGER, bitmask_key) && !test_bit(BTN_TOOL_PEN, bitmask_key)) {
                        is_touchpad = 1;
                } else if (test_bit(BTN_MOUSE, bitmask_key)) {
                        /* This path is taken by VMware's USB mouse, which has
                         * absolute axes, but no touch/pressure button. */
                        is_mouse = 1;
                } else if (test_bit(BTN_TOUCH, bitmask_key)) {
                        udev_builtin_add_property(dev, test, "ID_INPUT_TOUCHSCREEN", "1");
                        ret = true;
                /* joysticks don't necessarily have to have buttons; e. g.
                 * rudders/pedals are joystick-like, but buttonless; they have
                 * other fancy axes */
                } else if (test_bit(BTN_TRIGGER, bitmask_key) ||
                           test_bit(BTN_A, bitmask_key) ||
                           test_bit(BTN_1, bitmask_key) ||
                           test_bit(ABS_RX, bitmask_abs) ||
                           test_bit(ABS_RY, bitmask_abs) ||
                           test_bit(ABS_RZ, bitmask_abs) ||
                           test_bit(ABS_THROTTLE, bitmask_abs) ||
                           test_bit(ABS_RUDDER, bitmask_abs) ||
                           test_bit(ABS_WHEEL, bitmask_abs) ||
                           test_bit(ABS_GAS, bitmask_abs) ||
                           test_bit(ABS_BRAKE, bitmask_abs)) {
                        udev_builtin_add_property(dev, test, "ID_INPUT_JOYSTICK", "1");
                        ret = true;
                }
        }

        if (test_bit(INPUT_PROP_POINTING_STICK, bitmask_props)) {
                udev_builtin_add_property(dev, test, "ID_INPUT_POINTINGSTICK", "1");
                ret = true;
        }

        if (test_bit(EV_REL, bitmask_ev) &&
            test_bit(REL_X, bitmask_rel) && test_bit(REL_Y, bitmask_rel) &&
            test_bit(BTN_MOUSE, bitmask_key))
                is_mouse = 1;

        if (is_mouse) {
                udev_builtin_add_property(dev, test, "ID_INPUT_MOUSE", "1");
                ret = true;
        }
        if (is_touchpad) {
                udev_builtin_add_property(dev, test, "ID_INPUT_TOUCHPAD", "1");
                ret = true;
        }

        return ret;
}

/* key like devices */
static bool test_key(struct udev_device *dev,
                     const unsigned long* bitmask_ev,
                     const unsigned long* bitmask_key,
                     bool test) {
        unsigned i;
        unsigned long found;
        unsigned long mask;
        bool ret = false;

        /* do we have any KEY_* capability? */
        if (!test_bit(EV_KEY, bitmask_ev)) {
                log_debug("test_key: no EV_KEY capability");
                return false;
        }

        /* only consider KEY_* here, not BTN_* */
        found = 0;
        for (i = 0; i < BTN_MISC/BITS_PER_LONG; ++i) {
                found |= bitmask_key[i];
                log_debug("test_key: checking bit block %lu for any keys; found=%i", (unsigned long)i*BITS_PER_LONG, found > 0);
        }
        /* If there are no keys in the lower block, check the higher block */
        if (!found) {
                for (i = KEY_OK; i < BTN_TRIGGER_HAPPY; ++i) {
                        if (test_bit(i, bitmask_key)) {
                                log_debug("test_key: Found key %x in high block", i);
                                found = 1;
                                break;
                        }
                }
        }

        if (found > 0) {
                udev_builtin_add_property(dev, test, "ID_INPUT_KEY", "1");
                ret = true;
        }

        /* the first 32 bits are ESC, numbers, and Q to D; if we have all of
         * those, consider it a full keyboard; do not test KEY_RESERVED, though */
        mask = 0xFFFFFFFE;
        if ((bitmask_key[0] & mask) == mask) {
                udev_builtin_add_property(dev, test, "ID_INPUT_KEYBOARD", "1");
                ret = true;
        }

        return ret;
}

static int builtin_input_id(struct udev_device *dev, int argc, char *argv[], bool test) {
        struct udev_device *pdev;
        unsigned long bitmask_ev[NBITS(EV_MAX)];
        unsigned long bitmask_abs[NBITS(ABS_MAX)];
        unsigned long bitmask_key[NBITS(KEY_MAX)];
        unsigned long bitmask_rel[NBITS(REL_MAX)];
        unsigned long bitmask_props[NBITS(INPUT_PROP_MAX)];
        const char *sysname, *devnode;
        bool is_pointer;
        bool is_key;

        /* walk up the parental chain until we find the real input device; the
         * argument is very likely a subdevice of this, like eventN */
        pdev = dev;
        while (pdev != NULL && udev_device_get_sysattr_value(pdev, "capabilities/ev") == NULL)
                pdev = udev_device_get_parent_with_subsystem_devtype(pdev, "input", NULL);

        if (pdev) {
                /* Use this as a flag that input devices were detected, so that this
                 * program doesn't need to be called more than once per device */
                udev_builtin_add_property(dev, test, "ID_INPUT", "1");
                get_cap_mask(dev, pdev, "capabilities/ev", bitmask_ev, sizeof(bitmask_ev), test);
                get_cap_mask(dev, pdev, "capabilities/abs", bitmask_abs, sizeof(bitmask_abs), test);
                get_cap_mask(dev, pdev, "capabilities/rel", bitmask_rel, sizeof(bitmask_rel), test);
                get_cap_mask(dev, pdev, "capabilities/key", bitmask_key, sizeof(bitmask_key), test);
                get_cap_mask(dev, pdev, "properties", bitmask_props, sizeof(bitmask_props), test);
                is_pointer = test_pointers(dev, bitmask_ev, bitmask_abs,
                                           bitmask_key, bitmask_rel,
                                           bitmask_props, test);
                is_key = test_key(dev, bitmask_ev, bitmask_key, test);
                /* Some evdev nodes have only a scrollwheel */
                if (!is_pointer && !is_key && test_bit(EV_REL, bitmask_ev) &&
                    (test_bit(REL_WHEEL, bitmask_rel) || test_bit(REL_HWHEEL, bitmask_rel)))
                        udev_builtin_add_property(dev, test, "ID_INPUT_KEY", "1");
        }

        devnode = udev_device_get_devnode(dev);
        sysname = udev_device_get_sysname(dev);
        if (devnode && sysname && startswith(sysname, "event"))
                extract_info(dev, devnode, test);

        return EXIT_SUCCESS;
}

const struct udev_builtin udev_builtin_input_id = {
        .name = "input_id",
        .cmd = builtin_input_id,
        .help = "Input device properties",
};
