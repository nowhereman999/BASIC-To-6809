cd "$(dirname "$0")"
echo "Recompiling..."
cd ../c
make EXE='3DREND' "CXXFLAGS_EXTRA=" "CFLAGS_EXTRA=" "CXXLIBS_EXTRA=  " -j"3" OS=osx
read -p "Press ENTER to exit..."
