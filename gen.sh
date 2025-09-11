#!/bin/bash

function gen {
    local section="content/blog/$1"
    local index="$section/_index.md"
    local page="$section/$2.md"

    if [ -e "$section" ]; then
        echo "$section exists"
    else
        mkdir -p $section
        echo "Created $section"
    fi

    if [ -e "$index" ]; then
        echo "$index exists"
    else
        section_content > "$section/_index.md"
        echo "Created $section/_index.md"
    fi

    if [ -e "$page" ]; then
        echo "$page exists"
    else
        page_content > "$page"
        echo "Created $page"
    fi
}

function section_content {
    echo "+++
sort_by = \"date\"
+++
"
}

function page_content {
    echo "+++
title = \"\"
date = $(date +"%Y-%m-%d")

[taxonomies]
series = []
tags = [\"all\"]
+++
"
}

gen $1 $2
