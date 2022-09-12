#!/usr/bin/env bash

project_dir=$(git rev-parse --show-toplevel)

docker run \
       --mount type=bind,source="$project_dir/test",target=/mnt \
       --env ITEM_DATA_JSON=/mnt/item_data.json \
       --env OUTPUT_DIR=/mnt/tmp \
       --env ITEM_PDF_DIR=/mnt/pdf \
       rotate-pdf-addon \
       /mnt/input.json
