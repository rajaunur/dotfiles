#!/usr/bin/env bash
THEME="catppuccin-mocha"

I_BT=$'\U000F00AF';  I_BT_ON=$'\U000F00B1';  I_BT_OFF=$'\U000F00B2'
I_REFRESH=$'\U000F0450'

rofi_menu() {
    rofi -dmenu -i -p "$1" -format i -markup-rows -no-show-icons -theme "$THEME" \
        -theme-str 'window {width: 500px;} listview {lines: 7;}
                    element {padding: 12px 16px; spacing: 0px;}
                    element-icon {enabled: false;}
                    element-text {horizontal-align: 0.0;}'
}

esc() { local s=$1; s=${s//&/&amp;}; s=${s//</&lt;}; s=${s//>/&gt;}; printf '%s' "$s"; }

main() {
    local powered
    powered=$(bluetoothctl show | awk '/Powered:/{print $2}')

    if [[ $powered != yes ]]; then
        local c
        c=$(printf '%s\n' "$I_BT_OFF   Turn On Bluetooth" | rofi_menu "Bluetooth") || return
        rfkill unblock bluetooth; bluetoothctl power on >/dev/null; sleep 1; main
        return
    fi

    local -a rows=() actions=() macs=() names=()
    rows+=("$I_BT_OFF   Turn Off Bluetooth"); actions+=(off);  macs+=(""); names+=("")
    rows+=("$I_REFRESH   Scan device"); actions+=(scan); macs+=(""); names+=("")

    # urutan: terhubung (0), pernah dipasangkan (1), baru (2)
    while IFS=$'\t' read -r rank mac name; do
        local row
        case $rank in
            0) row="<span foreground='#a6e3a1'>$I_BT_ON</span>   $(esc "$name")  <span foreground='#6c7086'>connected</span>"; actions+=(disconnect) ;;
            1) row="$I_BT   $(esc "$name")"; actions+=(connect) ;;
            2) row="$I_BT   $(esc "$name")  <span foreground='#6c7086'>new</span>"; actions+=(pair) ;;
        esac
        rows+=("$row"); macs+=("$mac"); names+=("$name")
    done < <(
        bluetoothctl devices | while read -r _ mac name; do
            [[ -z $mac || ${name//-/:} == "$mac" ]] && continue   # sembunyikan perangkat tanpa nama
            info=$(bluetoothctl info "$mac")
            conn=$(awk '/Connected:/{print $2}' <<<"$info")
            paired=$(awk '/Paired:/{print $2}' <<<"$info")
            if   [[ $conn == yes ]];   then rank=0
            elif [[ $paired == yes ]]; then rank=1
            else rank=2; fi
            printf '%s\t%s\t%s\n' "$rank" "$mac" "$name"
        done | sort -s -t$'\t' -k1,1
    )

    local idx
    idx=$(printf '%s\n' "${rows[@]}" | rofi_menu "Bluetooth") || return
    local mac=${macs[$idx]} name=${names[$idx]}

    case ${actions[$idx]} in
        off)  bluetoothctl power off >/dev/null && notify-send "Bluetooth" "Turned Off" ;;
        scan) notify-send "Bluetooth" "Scanning..."
              bluetoothctl --timeout 6 scan on >/dev/null 2>&1; main ;;
        disconnect)
              bluetoothctl disconnect "$mac" >/dev/null && notify-send "Bluetooth" "Terputus dari $name" ;;
        connect)
              timeout 15 bluetoothctl connect "$mac" >/dev/null \
                  && notify-send "Bluetooth" "Terhubung ke $name" \
                  || notify-send -u critical "Bluetooth" "Gagal terhubung ke $name" ;;
        pair)
              notify-send "Bluetooth" "Pairing to $name..."
              { timeout 30 bluetoothctl pair "$mac" \
                  && bluetoothctl trust "$mac" \
                  && timeout 15 bluetoothctl connect "$mac"; } >/dev/null \
                  && notify-send "Bluetooth" "Connected to $name" \
                  || notify-send -u critical "Bluetooth" "Failed to connect $name" ;;
    esac
}

main
