#!/bin/sh

## EDIT These to match your system

LOG_DIR="logs" # directory where the log files are
LOG_FILE="latest.log" # the last "unzipped" one, the log file we monitor
OUT_FILE="mcap_list.txt" # where you want the list stored !! VOLATILE !!


## These are recommended values

LOGS="$LOG_DIR/$LOG_FILE" # the actual files
TEMP="/tmp/.mcap_$(head -c 20 /dev/random | base64)" # working directory


## DO not edit these
REGEX_MACOS="s/............Server.thread.INFO]: ([[:alnum:]_]{1,}) (joined|left) the game/\1 \2/"
REGEX_LINUX=""
declare -a ARR


## For a clean exit
function on_exit {
	unset ARR
	rm -rf $TEMP
	rm -f $OUT_FILE
}
trap on_exit EXIT


# add_player name
function add_player () {
	PLAYER="$1"
	for P in "${ARR[@]}" ; do
		if [ "$P" == "$PLAYER" ] ; then
			return
		fi
	done
	ARR[${#ARR[@]}]="$PLAYER"
}

# remove_player name
function remove_player () {
	PLAYER="$1"
	INDEX=0
	while [ "$INDEX" -lt "${#ARR[@]}" ] ; do
		# TODO: Something wonky might be going on in here
		if [ "${ARR[$INDEX]}" == "$PLAYER" ] ; then
			ARR[$INDEX]=""
			unset 'ARR[$INDEX]'
		else
			((INDEX++))
		fi
	done
}

# parse_logs
function parse_logs () {
	echo "Parsing logs... \c"
	while read LINE ; do
		PLAYER="$(echo "$LINE" | sed -E "$REGEX_MACOS")"
		if [ "$PLAYER" != "$LINE" ] ; then
			ACTION="$(echo "$PLAYER" | cut -d' ' -f2)"
			PLAYER="$(echo "$PLAYER" | cut -d' ' -f1)"
			if [ "$ACTION" == "joined" ] ; then
				add_player "$PLAYER"
			elif [ "$ACTION" == "left" ] ; then
				remove_player "$PLAYER"
			else
				echo "whoops"
			fi
		fi
	done < "$TEMP/$LOG_FILE"
	echo "Done!"
}

# update_file
function update_file () {
	echo "Updating file... \c"
	if [ "${#ARR[@]}" -eq "0" ] ; then
		echo "(no players currently online)" > "$OUT_FILE"
	else
		echo "\c" > "$OUT_FILE"
		for PLAYER in "${ARR[@]}" ; do
			echo "$PLAYER" >> "$OUT_FILE"
		done
	fi
	echo "Done!"
}


## Initialize
mkdir -p "$TEMP"
cp "$LOGS" "$TEMP"
update_file
echo "List of active players being saved to \"$OUT_FILE\""
echo "Remove this file or Ctrl-C to exit this script"


## Main loop
while [ -f "$OUT_FILE" ] ; do
	if [ -n "$(diff "$TEMP/$LOG_FILE" "$LOGS")" ] ; then
		echo "log files differ"
		cp "$LOGS" "$TEMP"
		parse_logs
		update_file 
		#echo "${ARR[*]}" #debug
	fi
done

## Cleanup is automatically handled by on_exit 
