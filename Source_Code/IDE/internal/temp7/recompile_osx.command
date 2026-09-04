cd "$(dirname "$0")"
echo "Recompiling..."
cd ../c
make TEMP_ID=7 EXE='/private/tmp/FUJINET1_IDE_after_fix' "CXXFLAGS_EXTRA=" "CFLAGS_EXTRA=" "CXXLIBS_EXTRA=  " -j"3" OS=osx
read -p "Press ENTER to exit..."
