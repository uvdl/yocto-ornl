SRC_URI = "file://dotnet.sh"

SRC_URI_append_5.0.301 += " https://download.visualstudio.microsoft.com/download/pr/97820d77-2dba-42f5-acb5-74c810112805/84c9a471b5f53d6aaa545fbeb449ad2a/dotnet-sdk-5.0.301-linux-arm.tar.gz;subdir=dotnet-${PV}"
SRC_URI_append_5.0.301[sha256sum] = "5b54b73a42c6ccadfc4f369a1b4c76a4806cef102adc1fe2d75747862cde6424"

SRC_URI_append_6.0.101 += " https://download.visualstudio.microsoft.com/download/pr/72888385-910d-4ef3-bae2-c08c28e42af0/59be90572fdcc10766f1baf5ac39529a/dotnet-sdk-6.0.101-linux-arm.tar.gz;subdir=dotnet-${PV}"
SRC_URI_append_6.0.101[sha256sum] = "f9e212dc4cccbe665d9aac23da6bdddce4957ae4e4d407cf3f1d6da7e79784ebd408c3a59b3ecc6ceaa930b37cf01a4a91c6b38517970d49227e96e50658cc46"