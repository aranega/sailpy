#!/usr/bin/env bash

CONFIG_INCLUDE=./rpm/config.make

# First transform the description

tempdescription="$(mktemp -t temp.XXXXX)"
sed 's/\s*$/\\n/g' ./rpm/description.txt | tr -d '\n' > "$tempdescription"

# yaml parser from https://gist.github.com/epiloque/8cf512c6d64641bde388
# slightly modified
parse_yaml() {
    local prefix="$2"
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s:=\"%s\"\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_:=/+=/g'
}

echo "# Generated file, modification will not be take into account" > "$CONFIG_INCLUDE"
echo "config_description:=$(cat "$tempdescription")" >> "$CONFIG_INCLUDE"
parse_yaml ./rpm/config.yml "config_" >> "$CONFIG_INCLUDE"
rm "$tempdescription"
echo "$CONFIG_INCLUDE"
