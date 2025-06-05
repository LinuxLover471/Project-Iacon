#!/bin/bash
dir="$(dirname "$(readlink -f "$0")")"
cd ${dir}/dxvk-sarek-async-v1.10.9
WINEPREFIX=~/.wine
cp -v x64/*.dll $WINEPREFIX/drive_c/windows/system32
cp -v x32/*.dll $WINEPREFIX/drive_c/windows/syswow64
echo "Please add d3d9 d3d10core d3d11 dxgi"
winecfg
