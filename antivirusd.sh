#!/bin/bash

dir="$1"
malicious_dir="$2"
interval_secs="$3"

mkdir -p "$malicious_dir" || exit 1

scan_dir()
{
    for file in "$dir"/* "$dir"/.[!.]* "$dir"/..?*
    do
        [ -f "$file" ] || continue

        filename="${file##*/}"
        malicious=false

        case "$filename" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                malicious=true
                ;;
        esac

        if [ "$malicious" = false ]; then
            if grep -Eiq 'virus|trojan|malware|worm|ransomware' -- "$file" 2>/dev/null; then
                malicious=true
            fi
        fi

        if [ "$malicious" = true ]; then
            if cp -- "$file" "$malicious_dir/" &&
               rm -- "$file"; then
                echo "$filename is malicious and it is DELETED"
            fi
        fi
    done
}

scan_dir
ls -l "$dir" > directory-info.last

while true
do
    sleep "$interval_secs"
    ls -l "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new; then
        scan_dir
        cp directory-info.new directory-info.last
    fi
done
