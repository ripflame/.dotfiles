#!/bin/bash
# Pull every Granola window onto the currently focused workspace (floating)
# and focus it, instead of jumping the user to wherever Granola lives.
ws=$(aerospace list-workspaces --focused)
ids=$(aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' \
        | awk -F'|' '$2 ~ /com.granola.app/ {print $1}')
if [ -z "$ids" ]; then
  open -a Granola
  exit 0
fi
for id in $ids; do
  aerospace layout --window-id "$id" floating
  aerospace move-node-to-workspace --window-id "$id" "$ws"
done
aerospace focus --window-id "$(echo "$ids" | head -1)"
