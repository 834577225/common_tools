#!/bin/bash

ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ ;

find -name "*.h" -or -name "*.hh" -or -name "*.hpp" -or -name "*.c" -or -name "*.cpp" > cscope.files ;
cscope -Rbkq ;

