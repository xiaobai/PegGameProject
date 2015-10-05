#!/bin/bash

if [[ $1 == "clean" ]]; then

    echo "Removing all generated files"
    rm PegGame
    rm PegGame.hi
    rm PegGame.o

elif [[ -z $1 ]]; then

    echo "Building..."
    ghc PegGame.hs
else
    echo "Unkown commands: $@"
fi
