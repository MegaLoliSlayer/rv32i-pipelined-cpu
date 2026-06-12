#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

AREA_DIR="${AREA_DIR:-reports/adders}"
TIMING_DIR="${TIMING_DIR:-reports/timing/adders}"
CSV_OUT="${CSV_OUT:-reports/adders/adder_comparison.csv}"

area_reports=("$AREA_DIR"/*.rpt)

if [ ${#area_reports[@]} -eq 0 ]; then
    echo "No synthesis area reports found in: $AREA_DIR"
    echo "Run: make synth"
    exit 1
fi

mkdir -p "$(dirname "$CSV_OUT")"

echo "adder,cells,area,delay_ns,slack_ns,fmax_mhz,startpoint,endpoint" > "$CSV_OUT"

echo "Adder area and timing comparison"
echo "================================"
echo

printf "%-20s %10s %12s %12s %12s %12s %-25s\n" \
    "Adder" "Cells" "Area" "Delay(ns)" "Slack(ns)" "Fmax(MHz)" "Critical path"

printf "%-20s %10s %12s %12s %12s %12s %-25s\n" \
    "-----" "-----" "----" "---------" "---------" "---------" "-------------"

for area_rpt in "${area_reports[@]}"; do
    name=$(basename "$area_rpt" .rpt)
    timing_rpt="$TIMING_DIR/${name}_timing.rpt"

    # Example Yosys stat line:
    # 104      195.776 cells
    cell_line=$(grep -E "^[[:space:]]*[0-9]+[[:space:]]+[0-9.]+[[:space:]]+cells" "$area_rpt" | tail -n 1 || true)

    cells=$(echo "$cell_line" | awk '{print $1}')
    area_from_cells=$(echo "$cell_line" | awk '{print $2}')

    # Example:
    # Chip area for module '\ripple_adder': 195.776000
    area=$(grep -i "Chip area" "$area_rpt" | tail -n 1 | awk -F ':' '{print $2}' | xargs || true)

    if [ -z "${cells:-}" ]; then
        cells="N/A"
    fi

    if [ -z "${area:-}" ]; then
        area="$area_from_cells"
    fi

    if [ -z "${area:-}" ]; then
        area="N/A"
    fi

    delay="N/A"
    slack="N/A"
    fmax_mhz="N/A"
    startpoint="N/A"
    endpoint="N/A"
    critical_path="N/A"

    if [ -f "$timing_rpt" ]; then
        # Use the first positive "data arrival time".
        # Do not use the later negative value from the slack section.
        delay=$(awk '
            tolower($0) ~ /data arrival time/ &&
            $1 ~ /^-?[0-9]+([.][0-9]+)?$/ &&
            ($1 + 0) > 0 {
                print $1
                exit
            }
        ' "$timing_rpt")

        # Example:
        # 8.8608   slack (MET)
        slack=$(awk '
            tolower($0) ~ /slack/ &&
            $1 ~ /^-?[0-9]+([.][0-9]+)?$/ {
                print $1
                exit
            }
        ' "$timing_rpt")

        startpoint=$(sed -n 's/^Startpoint:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$timing_rpt" | head -n 1)
        endpoint=$(sed -n 's/^Endpoint:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$timing_rpt" | head -n 1)

        if [ -z "${delay:-}" ]; then
            delay="N/A"
        fi

        if [ -z "${slack:-}" ]; then
            slack="N/A"
        fi

        if [ -z "${startpoint:-}" ]; then
            startpoint="N/A"
        fi

        if [ -z "${endpoint:-}" ]; then
            endpoint="N/A"
        fi

        if [ "$startpoint" != "N/A" ] && [ "$endpoint" != "N/A" ]; then
            critical_path="${startpoint}->${endpoint}"
        fi

        if [ "$delay" != "N/A" ]; then
            fmax_mhz=$(awk -v d="$delay" 'BEGIN {
                if (d + 0 > 0) {
                    printf "%.2f", 1000.0 / d
                } else {
                    printf "N/A"
                }
            }')
        fi
    fi

    printf "%-20s %10s %12s %12s %12s %12s %-25s\n" \
        "$name" "$cells" "$area" "$delay" "$slack" "$fmax_mhz" "$critical_path"

    echo "$name,$cells,$area,$delay,$slack,$fmax_mhz,$startpoint,$endpoint" >> "$CSV_OUT"
done

echo
echo "Best results"
echo "============"

best_delay_line=$(awk -F, 'NR > 1 && $4 != "N/A" {print $4 "," $1}' "$CSV_OUT" | sort -t, -k1,1n | head -n 1 || true)
best_area_line=$(awk -F, 'NR > 1 && $3 != "N/A" {print $3 "," $1}' "$CSV_OUT" | sort -t, -k1,1n | head -n 1 || true)

if [ -n "$best_delay_line" ]; then
    best_delay=$(echo "$best_delay_line" | cut -d, -f1)
    best_delay_name=$(echo "$best_delay_line" | cut -d, -f2)
    echo "Fastest adder:  $best_delay_name  delay=${best_delay} ns"
else
    echo "Fastest adder:  N/A"
fi

if [ -n "$best_area_line" ]; then
    best_area=$(echo "$best_area_line" | cut -d, -f1)
    best_area_name=$(echo "$best_area_line" | cut -d, -f2)
    echo "Smallest adder: $best_area_name  area=${best_area}"
else
    echo "Smallest adder: N/A"
fi

echo
echo "Cell-type breakdown"
echo "==================="

for area_rpt in "${area_reports[@]}"; do
    name=$(basename "$area_rpt" .rpt)
    echo
    echo "$name"

    # Example Yosys stat -liberty cell lines:
    # 12      15.960 NAND2_X1
    # 8       10.640 XOR2_X1
    awk '
        /^[[:space:]]*[0-9]+[[:space:]]+[0-9.]+[[:space:]]+[A-Za-z_][A-Za-z0-9_$]*$/ {
            count = $1
            area  = $2
            cell  = $3

            if (cell != "cells") {
                printf "  %-16s count=%-8s area=%s\n", cell, count, area
            }
        }
    ' "$area_rpt"
done

echo
echo "CSV written to: $CSV_OUT"
echo
echo "Notes:"
echo "  Delay(ns) comes from OpenSTA's first positive data arrival time."
echo "  Fmax(MHz) is estimated as 1000 / Delay(ns) for the adder alone."
echo "  This is not the final CPU Fmax because the full CPU also needs registers, setup time, clock uncertainty, and routing/parasitics."
