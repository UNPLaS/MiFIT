#!/bin/bash
WHERE=$(dirname "$0")
if [ $# -lt 2 ]; then
	echo Usage: $(basename "$0") '<filename.elf> <num of injections>' >&2
	exit 1
fi

elf="$1"
shift
inj=$1
echo "numb of inst:"
inst=$( bash ../../../total_inst.sh $elf)
echo $inst
echo $inst > num_inst.txt
echo "start"
bash ../../../MSPFIT.sh $elf $inst $inj 15 15 2
