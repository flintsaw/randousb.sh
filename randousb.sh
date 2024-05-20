#!/bin/bash

# Reads random bytes from Adafruit's RP2040 QT + Trust M breakout and presents them as decimal characters according to user input.
# User defines range via minimum value and maximum value, quantity of results, and location of usb device.
# The Trinkey must be configured to output raw bytes per this tutorial:
# https://learn.adafruit.com/trinkey-qt2040-true-random-number-generator

# Prompt for USB device location
read -p "Enter the USB device location (e.g., /dev/ttyACM0): " usb_device

# Check if the device exists
if [[ ! -e $usb_device ]]; then
  echo "Error: Device $usb_device not found."
  exit 1
fi

# Prompt for desired decimal range
read -p "Enter the minimum decimal value: " min_val
read -p "Enter the maximum decimal value: " max_val

# Prompt for number of results
read -p "Enter the number of decimal characters to output: " num_results

# Calculate the range
range=$((max_val - min_val + 1))

# Validate input
if [[ $range -le 0 ]]; then
  echo "Invalid range. Maximum value must be greater than minimum value."
  exit 1
fi

# Read from the specified USB device and process the bytes
dd if="$usb_device" bs=1 count=$((num_results * 2)) 2>/dev/null | od -An -t u1 | awk -v min_val="$min_val" -v range="$range" -v num_results="$num_results" '{
    for (i = 1; i <= NF && count < num_results; i++) {
        printf("%d\n", ( ($i % range) + min_val ));
        count++;
    }
}'
