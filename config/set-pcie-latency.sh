#!/bin/bash
# PCIe latency tweaks (CachyOS style)

# All devices
setpci -v -s '*:*' latency_timer=20

# Host bridge
setpci -v -s '0:0' latency_timer=0

# PCIe audio devices (class 04xx)
setpci -v -d "*:*:04xx" latency_timer=80

