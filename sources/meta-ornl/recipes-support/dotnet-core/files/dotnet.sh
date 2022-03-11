#!/bin/sh

if [ -d /usr/share/dotnet/ ]
    then
        export DOTNET_ROOT=/usr/share/dotnet
        export PATH=/usr/share/dotnet:$PATH
        export PATH=/home/root/.dotnet/tools:$PATH
        export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi