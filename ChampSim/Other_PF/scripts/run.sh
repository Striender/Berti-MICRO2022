#!/bin/bash

# ============================
# Step 1: Run ChampSim traces
# ============================

if [ $# -ne 3 ]; then
    echo "Usage: $0 <BINARY_NAME> <RESULTS_SUBDIR> <EXP_NO_SUBDIR>"
    exit 1
fi

BINARY=../bin/$1
RESULTS_DIR=../results/$2/$3
TRACE_DIR=../tracer/traces

# Instructions
WARMUP=50000000
SIM=50000000

# Check binary exists
if [ ! -x "$BINARY" ]; then
    echo "❌ Error: Binary $BINARY not found or not executable."
    exit 1
fi

# Check traces exist
if [ ! -d "$TRACE_DIR" ] || [ -z "$(ls $TRACE_DIR/*.champsimtrace.xz 2>/dev/null)" ]; then
    echo "❌ Error: No trace files found in $TRACE_DIR"
    exit 1
fi

# Make results directory if not exists
mkdir -p "$RESULTS_DIR"

# Run simulations
for TRACE in $TRACE_DIR/*.champsimtrace.xz
do
    TRACE_NAME=$(basename "$TRACE" .champsimtrace.xz)
    echo ">>> Running trace: $TRACE_NAME"
    "$BINARY" -warmup_instructions $WARMUP -simulation_instructions $SIM -traces "$TRACE" > "$RESULTS_DIR/$TRACE_NAME"
    echo ">>> Finished trace: $TRACE_NAME"
    echo "-----------------------------------"
done

echo "✅ All traces completed. Results are in $RESULTS_DIR"


# ============================
# Step 2: Extract IPC values
# ============================

# Path to IPC extraction script
EXTRACT_SCRIPT="./extract_IPC.sh"

if [ ! -f "$EXTRACT_SCRIPT" ]; then
    echo "❌ Error: IPC extraction script not found at $EXTRACT_SCRIPT"
    exit 1
fi

echo ""
echo "------------------------------------------------------------------------------------------------------"
echo ""


# Call extract_ipc.sh with arguments:
#   SUBDIR      -> $2 (results subdir passed earlier)
#   ExpNo       -> same as $1 (binary name, works as experiment ID)
#   IPC_SUBDIR  -> user input above
bash "$EXTRACT_SCRIPT" "$2" "$3" 
echo ""
echo "✅ Completed"
