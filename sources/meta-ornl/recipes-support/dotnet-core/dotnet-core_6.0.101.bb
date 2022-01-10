SUMMARY = "Contains the SDK for Microsoft's .NET Core 6.0"

SRC_URI = "file://dotnet.sh"

SRC_URI_append_arm += " https://download.visualstudio.microsoft.com/download/pr/72888385-910d-4ef3-bae2-c08c28e42af0/59be90572fdcc10766f1baf5ac39529a/dotnet-sdk-6.0.101-linux-arm.tar.gz;subdir=dotnet-${PV};name=armball"
SRC_URI[armball.sha256sum] = "6c2f89636b03cb67b8120d913edcebd22d0c62723db62d7cf37f52b3f6f3f629"

SRC_URI_append_aarch64 += " https://download.visualstudio.microsoft.com/download/pr/d43345e2-f0d7-4866-b56e-419071f30ebe/68debcece0276e9b25a65ec5798cf07b/dotnet-sdk-6.0.101-linux-arm64.tar.gz;subdir=dotnet-${PV};name=aarchball"
SRC_URI[aarchball.sha256sum] = "04cd89279f412ae6b11170d1724c6ac42bb5d4fae8352020a1f28511086dd6d6af2106dd48ebe3b39d312a21ee8925115de51979687a9161819a3a29e270a954"

# This is here because it doesn't seem like bitbake likes ${PV} used in require statements.
# require recipes-support/dotnet-core/dotnet-core-${DOTNET_RUNTIME_ARCH}.inc
require recipes-support/dotnet-core/dotnet-core_x.x.x.inc