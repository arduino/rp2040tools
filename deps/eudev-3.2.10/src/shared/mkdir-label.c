/***
  This file is part of eudev, forked from systemd.

  Copyright 2010 Lennart Poettering
  Copyright 2013 Kay Sievers

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

#include <assert.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

#include "label.h"
#include "util.h"
#include "path-util.h"
#include "mkdir.h"

int mkdir_safe_label(const char *path, mode_t mode, uid_t uid, gid_t gid) {
        return mkdir_safe_internal(path, mode, uid, gid, mkdir_label);
}

int mkdir_parents_label(const char *path, mode_t mode) {
        return mkdir_parents_internal(NULL, path, mode, mkdir_label);
}
