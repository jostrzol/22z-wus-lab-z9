#!/usr/bin/sh

if [ "$#" -ne 1 ]; then
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
    filename="$1"
    RGNAME=$(cat "$filename")
    az group delete -y --no-wait --name "$RGNAME" && \
    rm "$filename"
fi
