#!/bin/bash

# Function to URL encode a string
url_encode() {
    local string="$1"
    echo -n "$string" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

API_ENDPOINT="https://asciified.thelicato.io/api/v2/ascii"
FONTS_ENDPOINT="https://asciified.thelicato.io/api/v2/fonts"
TEXT="Hello! Welcome to my site"

# URL encode the text
ENCODED_TEXT=$(url_encode "$TEXT")

# Get the list of available fonts
fonts=$(curl -s "$FONTS_ENDPOINT" | jq -r '.fonts[]')

# Iterate over each font and fetch the ASCII art
for font in $fonts; do
    echo "Fetching ASCII art: $API_ENDPOINT?text=$ENCODED_TEXT&font=$font"
    result=$(curl -s "$API_ENDPOINT?text=$ENCODED_TEXT&font=$font")
    ascii_art=$(echo "$result")
    
    echo -e "\nFont: $font\n$ascii_art\n"
done
