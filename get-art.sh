#!/bin/bash

# set up variables
API_ENDPOINT="https://asciified.thelicato.io/api/v2/ascii"
FONTS_ENDPOINT="https://asciified.thelicato.io/api/v2/fonts"
TEXT="Hello this is Lorem Ipsum"
LIMIT=0
UNLIMITED=true
FONTS=("Fraktur" "Fuzzy" "Georgi16" "Georgia11" "Ghost" "Gothic" "Graceful" "Graffiti" "Henry 3D" "Hex" "ICL-1900" "Impossible" "Isometric1" "Isometric2" "Isometric3" "Isometric4" "JS Bracket Letters" "JS Stick Letters" "Keyboard" "Larry 3D 2" "Lean" "Letters" "Marquee")

# get parameters
while getopts ":t:l:f" opt; do
  case $opt in
    t) TEXT="$OPTARG"
    ;;
    l) LIMIT="$OPTARG"; UNLIMITED=false
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

# URL encode the text
ENCODED_TEXT=$(url_encode "$TEXT")

# Get the list of available fonts
if [ ${#FONTS[@]} -gt 0 ]; then
    fonts=("${FONTS[@]}")
else
    fonts=$(curl -s "$FONTS_ENDPOINT" | jq -r '.fonts[]' | tr '\n' ' ')
    fonts=($fonts)
fi

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
    if [ "$LIMIT" ] && [ "${#results[@]}" -ge "$LIMIT" ] && [ "$UNLIMITED" != true ]; then
        break
    fi
done

# Convert the array to JSON
json_output=$(printf '{"results": [%s]}' "$(IFS=,; echo "${results[*]}")")

# Save the JSON to a file
output_file="ascii_results.json"
echo "$json_output" > "$output_file"

echo "Results saved to $output_file"
