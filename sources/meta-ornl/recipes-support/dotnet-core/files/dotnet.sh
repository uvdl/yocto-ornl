#!/bin/sh

if [ -d /usr/share/dotnet/ ]
    then
        export DOTNET_ROOT=/usr/share/dotnet
        export PATH=/usr/share/dotnet:$PATH
fi