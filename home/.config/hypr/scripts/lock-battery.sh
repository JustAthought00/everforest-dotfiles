#!/bin/sh
for battery in /sys/class/power_supply/*; do
    [ -r "$battery/type" ] || continue
    [ "$(cat "$battery/type")" = Battery ] || continue
    [ -r "$battery/capacity" ] || continue
    capacity=$(cat "$battery/capacity")
    status=$(cat "$battery/status")
    case "$status" in
        Charging) printf 'Battery %s%% · Charging\n' "$capacity" ;;
        Full) printf 'Battery %s%% · Fully charged\n' "$capacity" ;;
        *) printf 'Battery %s%%\n' "$capacity" ;;
    esac
    exit 0
done
