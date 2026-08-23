cd "$(dirname "$0")"
./"DISK_DUAL_STREAM_TEST" &
osascript -e 'tell application "Terminal" to close (every window whose name contains "DISK_DUAL_STREAM_TEST_start.command")' &
osascript -e 'if (count the windows of application "Terminal") is 0 then tell application "Terminal" to quit' &
exit
