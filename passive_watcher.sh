#!/bin/sh

LOG_DIR="logs"
LOG_FILE="latest.log"
LOGS="$LOG_DIR/$LOG_FILE"

TEMP="/tmp/.mcap_$(head -c 20 /dev/random | base64)"

OUT_FILE="mcap_list.txt"

REGEX_MACOS="s/............Server.thread.INFO]: ([[:alnum:]_]{1,}) (joined|left) the game/\1 \2/"
REGEX_LINUX=""


mkdir -p "$TEMP"
cp "$LOGS" "$TEMP"
declare -a ARR

function on_exit {
	unset ARR
	rm -rf $TEMP
	rm -f $FILE
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
	ARR[${ARR[@]}]="$PLAYER"
}

# remove_player name
function remove_player () {
	PLAYER="$1"
	INDEX=0
	while [ "$INDEX" -lt "${#ARR[@]}" ] ; do
		if [ "${ARR[$INDEX]}" == "$PLAYER" ] ; then
			unset ARR[$INDEX]
		else
			((INDEX++))
		fi
	done
}

function parse_logs () {
	echo -n "Parsing logs... "
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

function update_file () {
	echo -n "Updating file... "
	if [ "${#ARR[@]}" -eq "0" ] ; then
		echo "(no players currently online)" > "$OUT_FILE"
	else
		echo "" > "$OUT_FILE"
		for PLAYER in "${ARR[@]}" ; do
			echo "$PLAYER" >> "$OUT_FILE"
		done
	

	echo "Done!"
}

###################################################################################################
while [ 1 ] ; do
	if [ -n "$(diff "$TEMP/$LOG_FILE" "$LOGS")" ] ; then
		echo "log files differ"
		cp "$LOGS" "$TEMP"
		parse_logs
		update_file 
	fi


done
