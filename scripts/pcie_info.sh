#!/bin/bash

# Print header
echo "PCIe Slot Information"
echo "===================="
echo ""

# Get PCIe information using system_profiler
system_profiler SPPCIDataType | grep -A 5 "Slot" | while read -r line; do
    if [[ $line == *"Slot"* ]]; then
        echo "$line"
    elif [[ $line == *"Link Speed"* ]] || [[ $line == *"Link Width"* ]]; then
        echo "  $line"
    fi
done

# Get additional PCIe information
echo ""
echo "Detailed PCIe Information:"
echo "-------------------------"
system_profiler SPPCIDataType | grep -A 2 "PCIe" | grep -v "^--$" 