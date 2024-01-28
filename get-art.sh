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
# fonts=$(curl -s "$FONTS_ENDPOINT" | jq -r '.fonts[]')
fonts=("1Row" "3-D" "3D Diagonal" "3D-ASCII")

# Create an array to store results
results=()

# Iterate over each font and fetch the ASCII art
for font in "${fonts[@]}"; do
    echo "Fetching ASCII art: $API_ENDPOINT?text=$ENCODED_TEXT&font=$font"
    result=$(curl -s "$API_ENDPOINT?text=$ENCODED_TEXT&font=$font" | sed ':a;N;$!ba;s/\n/\\n/g')
    
    # Add result to the array
    results+=("{\"font\": \"$font\", \"ascii_art\": \"$result\"}")
done

# Convert the array to JSON
json_output=$(printf '{"results": [%s]}' "$(IFS=,; echo "${results[*]}")")

# Save the JSON to a file
output_file="ascii_results.json"
echo "$json_output" > "$output_file"

echo "Results saved to $output_file"
