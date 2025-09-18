#!/bin/bash

LEFT="/dev/video0"
RIGHT="/dev/video2"

apply_settings() {
  DEV=$1
  echo "Applying settings to $DEV..."

  # Disable auto modes first
  v4l2-ctl -d $DEV --set-ctrl=focus_automatic_continuous=0
  # v4l2-ctl -d $DEV --set-ctrl=white_balance_automatic=0
  # v4l2-ctl -d $DEV --set-ctrl=auto_exposure=1

  # Now apply absolute values
  v4l2-ctl -d $DEV --set-ctrl=focus_absolute=0
  # v4l2-ctl -d $DEV --set-ctrl=white_balance_temperature=3500 #4500
  # v4l2-ctl -d $DEV --set-ctrl=exposure_time_absolute=30 #155
  # 이상하게 /dev/videoRight exposure_time_absolute: 156으로 고정
}

# Optional: delay to let USB cameras initialize
sleep 1

apply_settings $LEFT
apply_settings $RIGHT

echo "✅ Camera settings applied."

