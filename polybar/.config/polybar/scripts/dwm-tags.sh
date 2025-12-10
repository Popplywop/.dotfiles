#!/bin/bash
# dwm tags display for polybar using dwm-msg (requires dwm-ipc patch)

get_tags() {
    # Get monitor info from dwm-msg
    info=$(dwm-msg get_monitors 2>/dev/null)

    if [ -z "$info" ]; then
        echo "dwm"
        return
    fi

    # Parse the current monitor's tag info
    # Get selected tags bitmask and occupied tags
    selected=$(echo "$info" | jq -r '.[0].tag_state.selected')
    occupied=$(echo "$info" | jq -r '.[0].tag_state.occupied')
    urgent=$(echo "$info" | jq -r '.[0].tag_state.urgent')

    output=""
    for i in {0..8}; do
        tag=$((1 << i))
        tagnum=$((i + 1))

        if (( selected & tag )); then
            # Active tag - highlighted
            output+="%{F#d65d0e}[$tagnum]%{F-} "
        elif (( urgent & tag )); then
            # Urgent tag
            output+="%{F#cc241d}$tagnum%{F-} "
        elif (( occupied & tag )); then
            # Has windows
            output+="%{F#ebdbb2}$tagnum%{F-} "
        fi
        # Empty tags are hidden
    done

    echo "$output"
}

# Initial output
get_tags

# Subscribe to tag changes and update
dwm-msg subscribe tag_change_event 2>/dev/null | while read -r line; do
    get_tags
done
