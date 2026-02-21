#!/usr/bin/env bash
# Toggles between your set opacity and 1.0

SET_OPACITY=0.65
FLAG=/tmp/kitty-opacity-toggle

if [ -f "$FLAG" ]; then
  kitty @ --to "$KITTY_LISTEN_ON" set-background-opacity 1.0
  rm "$FLAG"
else
  kitty @ --to "$KITTY_LISTEN_ON" set-background-opacity "$SET_OPACITY"
  touch "$FLAG"
fi
