#!/bin/bash

if [[ $1 == "clean" ]]; then

    echo "Removing all generated files"
    rm *.class
    if [[ -f "$(pwd)/solution.log" ]]; then
        rm solution.log
    fi

elif [[ -z $1 ]]; then

    echo "Building..."
    javac PegGame.java
else
    echo "Unkown commands: $@"
fi
