# fetch_package.sh
############
# This section fetches a package from $download_url and verifies its metadata.
#
# Inputs:
# $download_url:
# $tmp_dir:
# Optional Inputs:
# $cmdline_filename: Name of the package downloaded on local disk.
# $cmdline_dl_dir: Name of the directory downloaded package will be saved to on local disk.
#
# Outputs:
# $download_filename: Name of the downloaded file on local disk.
# $filetype: Type of the file downloaded.
############

filename=`echo $download_url | sed -e 's/?.*//' | sed -e 's/^.*\///'`
filetype=`echo $filename | sed -e 's/^.*\.//'`

# use either $tmp_dir, the provided directory (-d) or the provided filename (-f)
if [ -n "$cmdline_filename" ]; then
  download_filename="$cmdline_filename"
elif [ -n "$cmdline_dl_dir" ]; then
  download_filename="$cmdline_dl_dir/$filename"
else
  download_filename="$tmp_dir/$filename"
fi

download_dir=`dirname $download_filename`
(umask 077 && mkdir -p $download_dir) || exit 1

# check if we have that file locally available and if so verify the checksum
cached_file_available="false"
verify_checksum="true"

if [ -n "$download_filename" ] && [ -f "$download_filename" ]; then
  echo "$download_filename exists"
  cached_file_available="true"
fi

if [ -n "$download_url_override" ]; then
  echo "Download URL override specified"
  if [ "$cached_file_available" = "true" ]; then
    echo "Verifying local file"
    if [ -z "$sha256" ]; then
      echo "Checksum not specified, ignoring existing file"
      cached_file_available="false" # download new file
      verify_checksum="false" # no checksum to compare after download
    elif do_checksum "$download_filename" "$sha256"; then
      echo "Checksum match, using existing file"
      cached_file_available="true" # don't need to download file
      verify_checksum="false" # don't need to checksum again
    else
      echo "Checksum mismatch, ignoring existing file"
      cached_file_available="false" # download new file
      verify_checksum="true" # checksum new downloaded file
    fi
  else
    echo "$download_filename not found"
    cached_file_available="false" # download new file
    if [ -z "$sha256" ]; then
      verify_checksum="false" # no checksum to compare after download
    else
      verify_checksum="true" # checksum new downloaded file
    fi
  fi
fi

if [ "$cached_file_available" != "true" ]; then
  do_download "$download_url" "$download_filename"
fi

if [ "$verify_checksum" = "true" ]; then
  if [ -z "$sha256" ]; then
    echo "Skipping checksum verification - no checksum provided"
  else
    do_checksum "$download_filename" "$sha256" || checksum_mismatch
  fi
fi

############
# end of fetch_package.sh
############
