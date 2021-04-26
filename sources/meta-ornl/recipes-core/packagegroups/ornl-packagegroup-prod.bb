DESCRIPTION = "ORNL Production Image packagegroup"
SUMMARY = "ORNL packagegroup - basic needs for production"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "\
	ornl-packagegroup-prod \
"

RDEPENDS_${PN} = " \
    packagegroup-core-full-cmdline \
    nodejs \
	flex \
    m4 \
	make \
    iperf3 \
	libtool \
	python3 \
	python3-lxml \
	python3-pip \
	python3-protobuf \
	python3-requests \
	python3-pexpect \
	python3-pyserial \
	python3-pytz \
	python3-urllib3 \
	python3-pynmea2 \
	python3-pymavlink \
	python3-future \
	python3-mavproxy \
    minicom \
	openssl \
	networkmanager \
    v4l-utils \
    dtc \
	gpsd \
	gps-utils \
	libgps \
    ntp \
	ntp-bin \
	packagegroup-cockpit \
"