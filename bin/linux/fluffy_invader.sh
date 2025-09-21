#!/bin/sh
echo -ne '\033c\033]0;FurryInvader\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/fluffy_invader.x86_64" "$@"
