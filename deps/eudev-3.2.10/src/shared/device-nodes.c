/***
  This file is part of eudev, forked from systemd.

  Copyright 2008-2011 Kay Sievers

  systemd is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1 of the License, or
  (at your option) any later version.

  systemd is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with systemd; If not, see <http://www.gnu.org/licenses/>.
***/

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>

#include "device-nodes.h"
#include "utf8.h"

int whitelisted_char_for_devnode(char c, const char *white) {

        if ((c >= '0' && c <= '9') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= 'a' && c <= 'z') ||
            strchr("#+-.:=@_", c) != NULL ||
            (white != NULL && strchr(white, c) != NULL))
                return 1;

        return 0;
}

int encode_devnode_name(const char *str, char *str_enc, size_t len) {
        size_t i, j;

        if (str == NULL || str_enc == NULL)
                return -EINVAL;

        for (i = 0, j = 0; str[i] != '\0'; i++) {
                int seqlen;

                seqlen = utf8_encoded_valid_unichar(&str[i]);
                if (seqlen > 1) {

                        if (len-j < (size_t)seqlen)
                                return -EINVAL;

                        memcpy(&str_enc[j], &str[i], seqlen);
                        j += seqlen;
                        i += (seqlen-1);

                } else if (str[i] == '\\' || !whitelisted_char_for_devnode(str[i], NULL)) {

                        if (len-j < 4)
                                return -EINVAL;

                        sprintf(&str_enc[j], "\\x%02x", (unsigned char) str[i]);
                        j += 4;

                } else {
                        if (len-j < 1)
                                return -EINVAL;

                        str_enc[j] = str[i];
                        j++;
                }
        }

        if (len-j < 1)
                return -EINVAL;

        str_enc[j] = '\0';
        return 0;
}
