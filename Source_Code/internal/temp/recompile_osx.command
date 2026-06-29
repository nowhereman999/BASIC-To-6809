cd "$(dirname "$0")"
echo "Recompiling..."
cd ../c
make EXE='TEST42' "CXXFLAGS_EXTRA=" "CFLAGS_EXTRA=" "CXXLIBS_EXTRA=  " -j"3" OS=osx
read -p "Press ENTER to exit..."
