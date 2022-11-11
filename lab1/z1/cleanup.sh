#!/usr/bin/sh

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
    echo 'Removing all resource groups from rgnames directory.'
    echo 'Enter y to confirm.'
    read -r accept
    if [ "$accept" = "y" ]; then
        for filename in rgnames/*.rgname; do
            RGNAME=$(cat "$filename")
            az group delete -y --no-wait --name "$RGNAME" && \
            rm "$filename"
        done
    else
        echo 'ABORT'
    fi
else
    RGNAME=$(cat "$1")
    az group delete -y --no-wait --name "$RGNAME" && \
    rm "$filename"
fi
