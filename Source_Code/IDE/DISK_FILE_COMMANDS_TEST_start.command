cd "$(dirname "$0")"
./"DISK_FILE_COMMANDS_TEST" &
osascript -e 'tell application "Terminal" to close (every window whose name contains "DISK_FILE_COMMANDS_TEST_start.command")' &
osascript -e 'if (count the windows of application "Terminal") is 0 then tell application "Terminal" to quit' &
exit
