SUMMARY = "Contains the SDK for Microsoft's .NET Core 6.0"

DOTNET_RUNTIME_ARCH = "none"
DOTNET_RUNTIME_ARCH_arm = "arm"
DOTNET_RUNTIME_ARCH_x86_64 = "x64"
DOTNET_RUNTIME_ARCH_aarch64 = "arm64"

# This is here because it doesn't seem like bitbake likes ${PV} used in require statements.
require recipes-support/dotnet-core/dotnet-core_${DOTNET_RUNTIME_ARCH}.inc
require recipes-support/dotnet-core/dotnet-core_x.x.x.inc