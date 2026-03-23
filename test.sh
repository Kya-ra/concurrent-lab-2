#!/bin/bash

INPUT_CSV="input.csv"
OUTPUT_CSV="results_median.csv"
JOBS=6

echo "p1,p2,p3,p4,p5,median_conv_time_1_us,median_conv_time_2_us" > "$OUTPUT_CSV"

run_case() {
    p1=$1; p2=$2; p3=$3; p4=$4; p5=$5

    times1=()
    times2=()

    for run in {1..5}
    do
        output=$(./a.out "$p1" "$p2" "$p3" "$p4" "$p5")

        extracted=($(echo "$output" | grep "Student pthreads conv time" | awk '{print $5}'))

        t1=${extracted[0]}
        t2=${extracted[1]}

        if [[ "$t1" =~ ^[0-9]+$ && "$t2" =~ ^[0-9]+$ ]]; then
            times1+=("$t1")
            times2+=("$t2")
        fi
    done

    # Median function
    median() {
        printf "%s\n" "$@" | sort -n | awk 'NR==3'
    }

    m1=$(median "${times1[@]}")
    m2=$(median "${times2[@]}")

    echo "$p1,$p2,$p3,$p4,$p5,$m1,$m2"
}

export -f run_case

# Skip header, run in parallel
tail -n +2 "$INPUT_CSV" | \
parallel -j $JOBS --colsep ',' run_case {1} {2} {3} {4} {5} >> "$OUTPUT_CSV"
