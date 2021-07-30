SUMMARY = "Read, Write and Edit Meta Information!"
HOMEPAGE = "https://github.com/exiftool/exiftool"

LICENSE = "GPLv1"
LIC_FILES_CHKSUM = "file://perl-Image-ExifTool.spec;md5=1581c15ea683b31f7c587a4882c044b8"

SRCBRANCH ?= "master"
SRCREV = "b0d89144691bc0b8fdde1bad33518126277489f9"
SRC_URI = "git://github.com/exiftool/exiftool.git"
SRC_URI[md5sum] = "8c8a42d71a2cf2d5c151ce74da98ab8f"
SRC_URI[sha256sum] = "f959f3436fb4e42f7561ad56771454670f95110b0bcd099c1bc72eefb4de23e1"

S = "${WORKDIR}/git"

inherit cpan