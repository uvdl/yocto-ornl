SUMMARY = "Contains the SDK for Microsoft's .NET Core 6.0"

SRC_URI = "file://dotnet.sh"

SRC_URI_append_arm += " https://download.visualstudio.microsoft.com/download/pr/4cfcfa53-f421-4257-8cd2-d4078f9ffe90/008804a5475fa0d46b9e8f03cb78bfcd/dotnet-sdk-6.0.200-linux-arm.tar.gz;subdir=dotnet-${PV};name=armball"
SRC_URI[armball.sha256sum] = "fd0a4ea696862bc8252bc16c2766a547cbf68ef6b5964a06b57649a4f780c29f"

SRC_URI_append_aarch64 += " https://download.visualstudio.microsoft.com/download/pr/ad60a07c-d4f0-4225-9154-c3a2ec0f34cf/a588cd2b94db2214f6e5dcd02c4aa37a/dotnet-sdk-6.0.200-linux-arm64.tar.gz;subdir=dotnet-${PV};name=aarchball"
SRC_URI[aarchball.sha256sum] = "36d1f5d8ece0012eb567ad052e93750d4755735c12a7331a2abd23e10c1a7cc3"

# This is here because it doesn't seem like bitbake likes ${PV} used in require statements.
# require recipes-support/dotnet-core/dotnet-core-${DOTNET_RUNTIME_ARCH}.inc
require recipes-support/dotnet-core/dotnet-core_x.x.x.inc