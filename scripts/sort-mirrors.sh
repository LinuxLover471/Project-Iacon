#!/bin/bash
# get-new-mirrorlist.sh
#
# Update arch mirrorlist
#
declare -- protocol='https'
declare -- use_mirror_status='on'
declare -- number_of_servers=5
declare -- timestamp="$( date '+%Y%m%dT%H%M' )"
declare -- mirror_file='mirrorlist'
declare -- mirror_dir='/etc/pacman.d'
declare -- mirror_list_url="https://archlinux.org/mirrorlist/"
declare -- mirror_list_options="?protocol=${protocol}&use_mirror_status=${use_mirror_status}"

if (( EUID == 0 )); then
  cd  "${mirror_dir}" || exit 0
else
  printf -- 'Must be root\n'
  exit
fi

# Save previous list
cp --verbose --archive "${mirror_file}" "${mirror_file}.${timestamp}"

# Get new list, prepare file, and rank
curl --silent \
     --show-error \
     --write-out '%{stderr}
%header{date}
%{time_total} seconds %{size_download} bytes %{speed_download} bytes/second
%{exitcode} exit %{response_code} response\n' \
     "${mirror_list_url}${mirror_list_options}" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' \
  | rankmirrors -n "${number_of_servers}" - >"${mirror_file}"

# Add timestamp
sed -i '1 i\# Created on '"${timestamp}"'\n#' "${mirror_file}"

echo
cat --number "${mirror_file}"
