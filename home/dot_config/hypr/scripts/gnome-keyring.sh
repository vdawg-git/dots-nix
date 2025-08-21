#!/bin/sh
eval $(gnome-keyring-daemon --start --components=ssh,secrets)
export SSH_AUTH_SOCK