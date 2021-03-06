#!/bin/bash

declare -a SOURCES
declare -a DIRS
declare -a INCS

SOURCES=(src/*.cpp src/*/*.cpp build/generated/*.cpp build/generated/*.hpp build/cpeditor_autogen/ui/*.h build/third_party/QtFindReplaceDialog/dialogs/QtFindReplaceDialog_autogen/include/*.h)
DIRS=(Core Extensions Settings Telemetry Util Widgets)
INCS=()

for i in "${DIRS[@]}"; do
	INCS=("${INCS[@]}" -I src/"$i");
done

for i in zh_CN ru_RU; do
	lupdate -no-obsolete "${SOURCES[@]}" -ts translations/$i.ts -I src "${INCS[@]}"
done
