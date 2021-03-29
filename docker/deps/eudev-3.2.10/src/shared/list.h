/*-*- Mode: C; c-basic-offset: 8; indent-tabs-mode: nil -*-*/

#pragma once

/***
  This file is part of systemd.

  Copyright 2010 Lennart Poettering

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

/* The head of the linked list. Use this in the structure that shall
 * contain the head of the linked list */
#define LIST_HEAD(t,name)                                               \
        t *name

/* The pointers in the linked list's items. Use this in the item structure */
#define LIST_FIELDS(t,name)                                             \
        t *name##_next, *name##_prev

/* Initialize the list's head */
#define LIST_HEAD_INIT(head)                                            \
        do {                                                            \
                (head) = NULL; }                                        \
        while(false)

/* Initialize a list item */
#define LIST_INIT(name,item)                                            \
        do {                                                            \
                typeof(*(item)) *_item = (item);                        \
                assert(_item);                                          \
                _item->name##_prev = _item->name##_next = NULL;         \
        } while(false)

/* Prepend an item to the list */
#define LIST_PREPEND(name,head,item)                                    \
        do {                                                            \
                typeof(*(head)) **_head = &(head), *_item = (item);     \
                assert(_item);                                          \
                if ((_item->name##_next = *_head))                      \
                        _item->name##_next->name##_prev = _item;        \
                _item->name##_prev = NULL;                              \
                *_head = _item;                                         \
        } while(false)

/* Remove an item from the list */
#define LIST_REMOVE(name,head,item)                                     \
        do {                                                            \
                typeof(*(head)) **_head = &(head), *_item = (item);     \
                assert(_item);                                          \
                if (_item->name##_next)                                 \
                        _item->name##_next->name##_prev = _item->name##_prev; \
                if (_item->name##_prev)                                 \
                        _item->name##_prev->name##_next = _item->name##_next; \
                else {                                                  \
                        assert(*_head == _item);                        \
                        *_head = _item->name##_next;                    \
                }                                                       \
                _item->name##_next = _item->name##_prev = NULL;         \
        } while(false)

/* Find the head of the list */
#define LIST_FIND_HEAD(name,item,head)                                  \
        do {                                                            \
                typeof(*(item)) *_item = (item);                        \
                if (!_item)                                             \
                        (head) = NULL;                                  \
                else {                                                  \
                        while (_item->name##_prev)                      \
                                _item = _item->name##_prev;             \
                        (head) = _item;                                 \
                }                                                       \
        } while (false)

/* Find the tail of the list */
#define LIST_FIND_TAIL(name,item,tail)                                  \
        do {                                                            \
                typeof(*(item)) *_item = (item);                        \
                if (!_item)                                             \
                        (tail) = NULL;                                  \
                else {                                                  \
                        while (_item->name##_next)                      \
                                _item = _item->name##_next;             \
                        (tail) = _item;                                 \
                }                                                       \
        } while (false)

/* Insert an item after another one (a = where, b = what) */
#define LIST_INSERT_AFTER(name,head,a,b)                                \
        do {                                                            \
                typeof(*(head)) **_head = &(head), *_a = (a), *_b = (b); \
                assert(_b);                                             \
                if (!_a) {                                              \
                        if ((_b->name##_next = *_head))                 \
                                _b->name##_next->name##_prev = _b;      \
                        _b->name##_prev = NULL;                         \
                        *_head = _b;                                    \
                } else {                                                \
                        if ((_b->name##_next = _a->name##_next))        \
                                _b->name##_next->name##_prev = _b;      \
                        _b->name##_prev = _a;                           \
                        _a->name##_next = _b;                           \
                }                                                       \
        } while(false)

#define LIST_JUST_US(name,item)                                         \
        (!(item)->name##_prev && !(item)->name##_next)                  \

#define LIST_FOREACH(name,i,head)                                       \
        for ((i) = (head); (i); (i) = (i)->name##_next)

#define LIST_FOREACH_SAFE(name,i,n,head)                                \
        for ((i) = (head); (i) && (((n) = (i)->name##_next), 1); (i) = (n))

#define LIST_FOREACH_BEFORE(name,i,p)                                   \
        for ((i) = (p)->name##_prev; (i); (i) = (i)->name##_prev)

#define LIST_FOREACH_AFTER(name,i,p)                                    \
        for ((i) = (p)->name##_next; (i); (i) = (i)->name##_next)

/* Loop starting from p->next until p->prev.
   p can be adjusted meanwhile. */
#define LIST_LOOP_BUT_ONE(name,i,head,p)                                \
        for ((i) = (p)->name##_next ? (p)->name##_next : (head);        \
             (i) != (p);                                                \
             (i) = (i)->name##_next ? (i)->name##_next : (head))
