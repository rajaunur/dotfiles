#!/usr/bin/env bash
THEME="catppuccin-mocha"

I_WIFI=$'\U000F05A9';  I_OFF=$'\U000F05AA'
I_LOCK=$'\U000F033E';  I_REFRESH=$'\U000F0450'; I_CHECK=$'\U000F012C'

rofi_menu() {   # $1 = prompt, baris menu dari stdin, output = index terpilih
    rofi -dmenu -i -p "$1" -format i -markup-rows -no-show-icons -theme "$THEME" \
        -theme-str 'window {width: 500px;} listview {lines: 7;}
                    element {padding: 12px 16px; spacing: 0px;}
                    element-icon {enabled: false;}
                    element-text {horizontal-align: 0.0;}'
}

esc() { local s=$1; s=${s//&/&amp;}; s=${s//</&lt;}; s=${s//>/&gt;}; printf '%s' "$s"; }

connect() {
    local ssid=$1 sec=$2 active=$3

    if [[ $ssid == "$active" ]]; then
        nmcli con down id "$ssid" && notify-send "Wi-Fi" "Disconnected from $ssid"
        return
    fi

    if nmcli -t -f NAME con show | grep -Fxq "$ssid"; then
        nmcli con up id "$ssid"                         # profil sudah tersimpan
    elif [[ -z $sec ]]; then
        nmcli dev wifi connect "$ssid"                  # jaringan terbuka
    else
        local pass
        pass=$(rofi -dmenu -password -p "Password" -theme "$THEME" \
            -theme-str 'window {width: 420px;} mainbox {children: [inputbar];}') || return
        nmcli dev wifi connect "$ssid" password "$pass"
    fi && notify-send "Wi-Fi" "Connected to $ssid" \
       || notify-send -u critical "Wi-Fi" "Failed to connect $ssid"
}

main() {
    if [[ $(nmcli radio wifi) != enabled ]]; then
        local c
        c=$(printf '%s\n' "$I_OFF   Wi-Fi is Off, Turn On" | rofi_menu "Wi-Fi") || return
        nmcli radio wifi on; sleep 2; main
        return
    fi

    local active
    active=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{sub(/^yes:/,""); print; exit}')
    active=${active//\\:/:}

    local -a rows=() actions=() ssids=() secs=()
    declare -A seen

    rows+=("$I_OFF   Turn Off Wi-Fi");  actions+=(off);    ssids+=(""); secs+=("")
    rows+=("$I_REFRESH   Scan Network"); actions+=(rescan); ssids+=(""); secs+=("")

    while IFS=: read -r sig sec ssid; do
        ssid=${ssid//\\:/:}
        [[ -z $ssid || -n ${seen[$ssid]:-} ]] && continue
        seen[$ssid]=1

        local mark="$I_WIFI" lock=""
        [[ $ssid == "$active" ]] && mark="<span foreground='#a6e3a1'>$I_CHECK</span>"
        [[ -n $sec ]] && lock="  <span foreground='#6c7086'>$I_LOCK</span>"

        rows+=("$mark   $(esc "$ssid")$lock  <span foreground='#6c7086'>${sig}%</span>")
        actions+=(net); ssids+=("$ssid"); secs+=("$sec")
    done < <(nmcli -t -f SIGNAL,SECURITY,SSID dev wifi list --rescan no | sort -t: -k1,1 -nr)

    local idx
    idx=$(printf '%s\n' "${rows[@]}" | rofi_menu "Wi-Fi") || return

    case ${actions[$idx]} in
        off)    nmcli radio wifi off && notify-send "Wi-Fi" "Turned Off" ;;
        rescan) nmcli dev wifi rescan 2>/dev/null; sleep 2; main ;;
        net)    connect "${ssids[$idx]}" "${secs[$idx]}" "$active" ;;
    esac
}

main
