SRC_URI = "file://dotnet.sh"

SRC_URI_append_5.0.301 += " https://download.visualstudio.microsoft.com/download/pr/574ddb7e-5fbc-4b28-ae76-2bb9c0d3f163/04d9d954b7d40c8d46b7c9067f421e03/dotnet-sdk-5.0.301-linux-arm64.tar.gz;subdir=dotnet-${PV}"
SRC_URI_append_5.0.301[sha256sum] = "5fa7c6d13e7a0f0b2e0a9bae7086906f5ec4bd8b8ff8ae86ed9fc5506c369715"

SRC_URI_append_6.0.101 += " https://download.visualstudio.microsoft.com/download/pr/d43345e2-f0d7-4866-b56e-419071f30ebe/68debcece0276e9b25a65ec5798cf07b/dotnet-sdk-6.0.101-linux-arm64.tar.gz;subdir=dotnet-${PV}"
SRC_URI_append_6.0.101[sha256sum] = "04cd89279f412ae6b11170d1724c6ac42bb5d4fae8352020a1f28511086dd6d6af2106dd48ebe3b39d312a21ee8925115de51979687a9161819a3a29e270a954"