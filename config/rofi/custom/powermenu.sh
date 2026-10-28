#!/usr/bin/env bash

icons=($'\U000F033E' $'\U000F0343' $'\U000F04B2' $'\U000F0709' $'\U000F0425')
labels=("Lock" "Logout" "Suspend" "Reboot" "Shutdown")

entries=""
for i in "${!icons[@]}"; do
    entry="<span size=\"large\">${icons[$i]}</span>   ${labels[$i]}"
    [ -n "$entries" ] && entries+="|"
    entries+="$entry"
done

choice=$(printf "%s" "$entries" | rofi -dmenu -i -p "Power" \
    -sep '|' -markup-rows -format i -no-show-icons \
    -theme catppuccin-mocha \
    -theme-str '
        window { width: 400px; }
        mainbox { children: [ inputbar, listview ]; }
        listview { columns: 1; lines: 5; spacing: 4px; }
        element { padding: 14px 20px; spacing: 0px; }
        element-icon { enabled: false; }
        element-text { horizontal-align: 0.0; vertical-align: 0.5; }
    ')

case "$choice" in
    0) loginctl lock-session ;;
    1) awesome-client 'awesome.quit()' ;;
    2) systemctl suspend ;;
    3) systemctl reboot ;;
    4) systemctl poweroff ;;
esac
