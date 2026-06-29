cd "$(dirname "$0")"
echo "Recompiling..."
cd ../c
make DEP_CONSOLE=y TEMP_ID=6 EXE='/Users/glenhewlett/My Drive (nowhereman999@gmail.com)/Programming/CoCo_Related/_BASTo6809_Compiler_V5.2/BasTo6809.1.Tokenizer' "CXXFLAGS_EXTRA=" "CFLAGS_EXTRA=" "CXXLIBS_EXTRA=  " -j"3" OS=osx
read -p "Press ENTER to exit..."
