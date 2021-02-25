DESCRIPTION = "ORNL Production Image packagegroup"
SUMMARY = "ORNL packagegroup - basic needs for production"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
	default-eth0 \
	dtc \
	gpsd \
	gps-utils \
	flex \
	m4 \
	make \
	imx-test \
	iperf3 \
	libgps \
	libtool \
	minicom \
	networkmanager \
	nodejs \
	ntp \
	ntp-bin \
	openssl \
	packagegroup-core-full-cmdline \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	python-compiler \
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
	v4l-utils \
"
