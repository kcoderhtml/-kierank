#!/bin/bash

# get parameters
while getopts ":t:l:" opt; do
  case $opt in
    t) TEXT="$OPTARG"
    ;;
    l) LIMIT="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

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
fonts=$(curl -s "$FONTS_ENDPOINT" | jq -r '.fonts[]' | tr '\n' ' ')
fonts=($fonts)

# Create an array to store results
results=()

# Iterate over each font and fetch the ASCII art
for font in "${fonts[@]}"; do
    echo "Fetching ASCII art: $API_ENDPOINT?text=$ENCODED_TEXT&font=$font"
    result=$(curl -s "$API_ENDPOINT?text=$ENCODED_TEXT&font=$font" | jq -s -R '.') 

    # replace \n with <br/>
    result=$(echo "$result" | sed 's/\\n/<\/br>/g')

    # put into format {"font":"","ascii_art":""}
    json=$(printf '{"font":"%s","ascii_art":%s}' "$font" "$result")
    
    # Add result to the array
    results+=("$json")
    
    # Limit the number of results
    if [ "$LIMIT" ] && [ "${#results[@]}" -ge "$LIMIT" ]; then
        break
    fi
done

# Convert the array to JSON
json_output=$(printf '{"results": [%s]}' "$(IFS=,; echo "${results[*]}")")

# Save the JSON to a file
output_file="ascii_results.json"
echo "$json_output" > "$output_file"

echo "Results saved to $output_file"
