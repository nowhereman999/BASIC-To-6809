cd "$(dirname "$0")"
echo "Recompiling..."
cd ../c
make TEMP_ID=5 EXE='/private/tmp/IDE_STRING_LENGTH_VERIFY' "CXXFLAGS_EXTRA=" "CFLAGS_EXTRA=" "CXXLIBS_EXTRA=  " -j"3" OS=osx
read -p "Press ENTER to exit..."
