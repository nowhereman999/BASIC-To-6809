cd "$(dirname "$0")"
Pause()
{
OLDCONFIG=`stty -g`
stty -icanon -echo min 1 time 0
dd count=1 2>/dev/null
stty $OLDCONFIG
}
echo "C++ Debugging: STRING using GDB"
echo "Debugger commands:"
echo "After the debugger launches type 'run' to start your program"
echo "After your program crashes type 'list' to find where the problem is and fix/report it"
echo "(the GDB debugger has many other useful commands, this advice is for beginners)"
gdb "STRING"
Pause
