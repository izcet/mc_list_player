#!/bin/sh

LDIR="logs"
LFIL="latest.log"
LOGS="$LDIR/$LFIL"

TEMP="/tmp/.mcap_$(head -c 20 /dev/random | base64)"

OUT_FILE="mcap_list.txt"


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
	exit
}
# remove_player name
function remove_player () {
	exit
}







function parse_logs () {
	while read LINE ; do
		echo "LINE=\"$LINE\""
		PLAYER="$(echo "$LINE" | sed -E 's/............Server.thread.INFO]: ([[:alnum:]_]{1,}) (joined|left) the game/\1 \2/')"
		if [ "$PLAYER" != "$LINE" ] ; then
			echo "PLAYER=\"$PLAYER\"\n"
		fi
	done < "$TEMP/$LFIL"
}

parse_logs

exit

###########################################################################################################
while [ 1 ] ; do

	if [ -n "$(diff "$TEMP/$LFIL" "$LOGS")" ] ; then
		echo "log files differ"
		cp "$LOGS" "$TEMP"
		parse_logs
	fi


done
