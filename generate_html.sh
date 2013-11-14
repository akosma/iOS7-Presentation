#!/bin/sh

# Exports all the .m files into .html files with the same names. The application
# then loads the contents of the HTML files into the application, to show the
# source code for any demo.

# This script requires Pygments to be installed in the local system:
# sudo easy_install Pygments

DIR=html
PYG=/usr/local/bin/pygmentize
OPTS="-f html -O full"

if [ -d "${DIR}" ];
    then rm -r ${DIR};
fi;
mkdir ${DIR}

# Find all the *.m and *.h files, in all subfolders, and format them as HTML.
find Presentation/Classes/Controllers/Screens \( -name \*.m -or -name \*.h \) -exec ${PYG} ${OPTS} -o {}.html {} \;

# Move all the HTML files into a folder, which is automatically included inside
# of the bundle when Xcode builds the project.
find . -name \*.html -exec mv {} ${DIR} \; 2> /dev/null
