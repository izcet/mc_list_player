# Minecraft Active Player Monitor

These scripts provide a pseudo-realtime list of active players on a Minecraft Server.
<br>
_Warning: Probably buggy, I tested on static log files and a server that had ~4 active players._
<br>

### Passive Watcher
This script does all of the main work.
It scrapes the log output of the minecraft server to gain information about players joining or leaving.
I opted to scrape the log files because it allows monitoring of a system, but doesn't interfere with it running.
- It stores the active player list in a file in the current directory, by default named `mcap_list.txt`.
- It requires at least 1 new line of log output to display correctly, until then it will say (no active players).
- You can run it with `sh passive_watcher.sh` and it will provide basic output.
- To fire-and-forget and have it run in the background, use `sh passive_watcher.sh &> /dev/null &` or use `screen`
<br>

### Active Watcher
An example script to provide realtime output.
This just uses the `watch` command and reads the file created by the Passive Watcher.
You could also just reference the output file from your own backend/frontend/relay service.
