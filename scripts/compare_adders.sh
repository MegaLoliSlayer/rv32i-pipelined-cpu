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

extract_delay_in_section() {
    local rpt="$1"
    local begin_marker="$2"
    local end_marker="$3"

    awk -v begin="$begin_marker" -v end="$end_marker" '
        $0 ~ begin {inside=1; next}
        $0 ~ end {inside=0}
        inside &&
        tolower($0) ~ /data arrival time/ &&
        $1 ~ /^-?[0-9]+([.][0-9]+)?$/ &&
        ($1 + 0) > 0 {
            print $1
            exit
        }
    ' "$rpt"
}

extract_slack_in_section() {
    local rpt="$1"
    local begin_marker="$2"
    local end_marker="$3"

    awk -v begin="$begin_marker" -v end="$end_marker" '
        $0 ~ begin {inside=1; next}
        $0 ~ end {inside=0}
        inside &&
        tolower($0) ~ /slack/ &&
        $1 ~ /^-?[0-9]+([.][0-9]+)?$/ {
            print $1
            exit
        }
    ' "$rpt"
}

extract_startpoint_in_section() {
    local rpt="$1"
    local begin_marker="$2"
    local end_marker="$3"

    awk -v begin="$begin_marker" -v end="$end_marker" '
        $0 ~ begin {inside=1; next}
        $0 ~ end {inside=0}
        inside && /^Startpoint:/ {
            print $2
            exit
        }
    ' "$rpt"
}

extract_endpoint_in_section() {
    local rpt="$1"
    local begin_marker="$2"
    local end_marker="$3"

    awk -v begin="$begin_marker" -v end="$end_marker" '
        $0 ~ begin {inside=1; next}
        $0 ~ end {inside=0}
        inside && /^Endpoint:/ {
            print $2
            exit
        }
    ' "$rpt"
}

calc_fmax_mhz() {
    local delay="$1"

    if [ "$delay" = "N/A" ]; then
        echo "N/A"
        return
    fi

    awk -v d="$delay" 'BEGIN {
        if (d + 0 > 0) {
            printf "%.2f", 1000.0 / d
        } else {
            printf "N/A"
        }
    }'
}

echo "adder,cells,area,worst_delay_ns,best_delay_ns,slack_ns,fmax_mhz,worst_startpoint,worst_endpoint,best_startpoint,best_endpoint" > "$CSV_OUT"

echo "Adder area and timing comparison"
echo "================================"
echo

printf "%-22s %8s %12s %14s %13s %12s %12s %-25s %-25s\n" \
    "Adder" "Cells" "Area" "Worst(ns)" "Best(ns)" "Slack(ns)" "Fmax(MHz)" "Worst path" "Best path"

printf "%-22s %8s %12s %14s %13s %12s %12s %-25s %-25s\n" \
    "-----" "-----" "----" "---------" "--------" "---------" "---------" "----------" "---------"

for area_rpt in "${area_reports[@]}"; do
    name=$(basename "$area_rpt" .rpt)
    timing_rpt="$TIMING_DIR/${name}_timing.rpt"

    cell_line=$(grep -E "^[[:space:]]*[0-9]+[[:space:]]+[0-9.]+[[:space:]]+cells" "$area_rpt" | tail -n 1 || true)

    cells=$(echo "$cell_line" | awk '{print $1}')
    area_from_cells=$(echo "$cell_line" | awk '{print $2}')

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

    worst_delay="N/A"
    best_delay="N/A"
    slack="N/A"
    fmax_mhz="N/A"

    worst_startpoint="N/A"
    worst_endpoint="N/A"
    best_startpoint="N/A"
    best_endpoint="N/A"

    worst_path="N/A"
    best_path="N/A"

    if [ -f "$timing_rpt" ]; then
        worst_delay=$(extract_delay_in_section "$timing_rpt" "MAX_DELAY_REPORT_BEGIN" "MAX_DELAY_REPORT_END")
        best_delay=$(extract_delay_in_section "$timing_rpt" "MIN_DELAY_REPORT_BEGIN" "MIN_DELAY_REPORT_END")
        slack=$(extract_slack_in_section "$timing_rpt" "MAX_DELAY_REPORT_BEGIN" "MAX_DELAY_REPORT_END")

        worst_startpoint=$(extract_startpoint_in_section "$timing_rpt" "MAX_DELAY_REPORT_BEGIN" "MAX_DELAY_REPORT_END")
        worst_endpoint=$(extract_endpoint_in_section "$timing_rpt" "MAX_DELAY_REPORT_BEGIN" "MAX_DELAY_REPORT_END")

        best_startpoint=$(extract_startpoint_in_section "$timing_rpt" "MIN_DELAY_REPORT_BEGIN" "MIN_DELAY_REPORT_END")
        best_endpoint=$(extract_endpoint_in_section "$timing_rpt" "MIN_DELAY_REPORT_BEGIN" "MIN_DELAY_REPORT_END")

        if [ -z "${worst_delay:-}" ]; then worst_delay="N/A"; fi
        if [ -z "${best_delay:-}" ]; then best_delay="N/A"; fi
        if [ -z "${slack:-}" ]; then slack="N/A"; fi

        if [ -z "${worst_startpoint:-}" ]; then worst_startpoint="N/A"; fi
        if [ -z "${worst_endpoint:-}" ]; then worst_endpoint="N/A"; fi
        if [ -z "${best_startpoint:-}" ]; then best_startpoint="N/A"; fi
        if [ -z "${best_endpoint:-}" ]; then best_endpoint="N/A"; fi

        if [ "$worst_startpoint" != "N/A" ] && [ "$worst_endpoint" != "N/A" ]; then
            worst_path="${worst_startpoint}->${worst_endpoint}"
        fi

        if [ "$best_startpoint" != "N/A" ] && [ "$best_endpoint" != "N/A" ]; then
            best_path="${best_startpoint}->${best_endpoint}"
        fi

        fmax_mhz=$(calc_fmax_mhz "$worst_delay")
    fi

    printf "%-22s %8s %12s %14s %13s %12s %12s %-25s %-25s\n" \
        "$name" "$cells" "$area" "$worst_delay" "$best_delay" "$slack" "$fmax_mhz" "$worst_path" "$best_path"

    echo "$name,$cells,$area,$worst_delay,$best_delay,$slack,$fmax_mhz,$worst_startpoint,$worst_endpoint,$best_startpoint,$best_endpoint" >> "$CSV_OUT"
done

echo
echo "Best results"
echo "============"

best_worst_delay_line=$(awk -F, 'NR > 1 && $4 != "N/A" {print $4 "," $1}' "$CSV_OUT" | sort -t, -k1,1n | head -n 1 || true)
best_min_delay_line=$(awk -F, 'NR > 1 && $5 != "N/A" {print $5 "," $1}' "$CSV_OUT" | sort -t, -k1,1n | head -n 1 || true)
best_area_line=$(awk -F, 'NR > 1 && $3 != "N/A" {print $3 "," $1}' "$CSV_OUT" | sort -t, -k1,1n | head -n 1 || true)

if [ -n "$best_worst_delay_line" ]; then
    best_worst_delay=$(echo "$best_worst_delay_line" | cut -d, -f1)
    best_worst_delay_name=$(echo "$best_worst_delay_line" | cut -d, -f2)
    echo "Fastest worst-case adder:  $best_worst_delay_name  worst_delay=${best_worst_delay} ns"
else
    echo "Fastest worst-case adder:  N/A"
fi

if [ -n "$best_min_delay_line" ]; then
    best_min_delay=$(echo "$best_min_delay_line" | cut -d, -f1)
    best_min_delay_name=$(echo "$best_min_delay_line" | cut -d, -f2)
    echo "Shortest min-path adder:   $best_min_delay_name  best_delay=${best_min_delay} ns"
else
    echo "Shortest min-path adder:   N/A"
fi

if [ -n "$best_area_line" ]; then
    best_area=$(echo "$best_area_line" | cut -d, -f1)
    best_area_name=$(echo "$best_area_line" | cut -d, -f2)
    echo "Smallest adder:            $best_area_name  area=${best_area}"
else
    echo "Smallest adder:            N/A"
fi

echo
echo "Cell-type breakdown"
echo "==================="

for area_rpt in "${area_reports[@]}"; do
    name=$(basename "$area_rpt" .rpt)
    echo
    echo "$name"

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
echo "  Worst(ns) comes from OpenSTA max delay."
echo "  Best(ns) comes from OpenSTA min delay / shortest structural path."
echo "  Best(ns) is not input-vector-dependent best case."
echo "  Fmax(MHz) is estimated as 1000 / Worst(ns) for the adder alone."
echo "  This is not the final CPU Fmax because the full CPU also needs registers, setup time, clock uncertainty, and routing/parasitics."
