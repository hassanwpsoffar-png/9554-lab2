#!/bin/bash

dir="$1"
malicious_dir="$2"
whitelist_file="whitelist.txt"

while true
do
    files=()

    for file in "$malicious_dir"/* "$malicious_dir"/.[!.]* "$malicious_dir"/..?*
    do
        [ -f "$file" ] || continue
        files+=("$file")
    done

    if [ "${#files[@]}" -eq 0 ]; then
        echo "No malicious files to review."
        break
    fi

    echo
    echo "Files currently in quarantine:"

    for i in "${!files[@]}"
    do
        echo "$((i + 1)). ${files[$i]##*/}"
    done

    echo "0. Exit"
    read -r -p "Choose a file number: " choice

    if [ "$choice" = "0" ]; then
        break
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] ||
       [ "$choice" -lt 1 ] ||
       [ "$choice" -gt "${#files[@]}" ]; then
        echo "Invalid selection. Please try again."
        continue
    fi

    file="${files[$((choice - 1))]}"
    filename="${file##*/}"

    echo
    echo "Selected file: $filename"
    echo "1. Restore this file"
    echo "2. Permanently delete this file"
    echo "3. Leave this file as-is and return to the list"

    read -r -p "Choose an option: " action

    case "$action" in
        1)
            if [ ! -e "$dir/$filename" ] && [ ! -L "$dir/$filename" ]; then
                # Calculate the hash of the file being restored
                file_hash=$(sha256sum -- "$file" | cut -d ' ' -f 1)

                if [ -z "$file_hash" ]; then
                    echo "Error: Could not calculate file hash."
                    continue
                fi

                # Add the hash if it is not already whitelisted
                if ! grep -Fxq "$file_hash" "$whitelist_file" 2>/dev/null; then
                    if ! echo "$file_hash" >> "$whitelist_file"; then
                        echo "Error: Could not update the whitelist."
                        continue
                    fi
                fi

                # Restore the file
                if mv -- "$file" "$dir/"; then
                    echo "Restored $filename to $dir."
                else
                    echo "Error: Could not restore $filename."
                fi
            else
                echo "Error: A file named $filename already exists in $dir."
            fi
            ;;

        2)
            read -r -p "Permanently delete $filename? (y/n): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                if rm -- "$file"; then
                    echo "$filename permanently deleted."
                else
                    echo "Error: Could not delete $filename."
                fi
            else
                echo "Deletion cancelled."
            fi
            ;;
        3)
            echo "File left unchanged."
            ;;
        *)
            echo "Invalid option. Returning to the list."
            ;;
    esac
done
