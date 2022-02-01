SUMMARY = "Contains the SDK for Microsoft's .NET Core 5.0"

SRC_URI = "file://dotnet.sh"

SRC_URI_append_arm += " https://download.visualstudio.microsoft.com/download/pr/97820d77-2dba-42f5-acb5-74c810112805/84c9a471b5f53d6aaa545fbeb449ad2a/dotnet-sdk-5.0.301-linux-arm.tar.gz;subdir=dotnet-${PV};name=armball"
SRC_URI[armball.sha256sum] = "5b54b73a42c6ccadfc4f369a1b4c76a4806cef102adc1fe2d75747862cde6424"

SRC_URI_append_aarch64 += " https://download.visualstudio.microsoft.com/download/pr/574ddb7e-5fbc-4b28-ae76-2bb9c0d3f163/04d9d954b7d40c8d46b7c9067f421e03/dotnet-sdk-5.0.301-linux-arm64.tar.gz;subdir=dotnet-${PV};name=aarchball"
SRC_URI[aarchball.sha256sum] = "5fa7c6d13e7a0f0b2e0a9bae7086906f5ec4bd8b8ff8ae86ed9fc5506c369715"

# This is here because it doesn't seem like bitbake likes ${PV} used in require statements.
# require recipes-support/dotnet-core/dotnet-core-${DOTNET_RUNTIME_ARCH}.inc
require recipes-support/dotnet-core/dotnet-core_x.x.x.inc

