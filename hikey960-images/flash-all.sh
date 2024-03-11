#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "Provide the right /dev/ttyUSBX specific to recovery device"
    exit
fi

if [ ! -e "${1}" ]
  then
    echo "device: ${1} does not exist"
    exit
fi
DEVICE_PORT="${1}"
PTABLE=ptable-aosp-32g.img

INSTALLER_DIR="`dirname ${0}`"
FIRMWARE_DIR="${INSTALLER_DIR}"
ECHO_PREFIX="=== "

# for cases that don't run "lunch hikey960-userdebug"
if [ -z "${ANDROID_BUILD_TOP}" ]; then
    ANDROID_BUILD_TOP=${INSTALLER_DIR}/../../../../../
    ANDROID_PRODUCT_OUT="${ANDROID_BUILD_TOP}/out/target/product/hikey960"
fi

if [ ! -d "${ANDROID_PRODUCT_OUT}" ]; then
    echo ${ECHO_PREFIX}"error in locating out directory, check if it exist"
    exit
fi

echo ${ECHO_PREFIX}"android out dir:${ANDROID_PRODUCT_OUT}"

if [ -z "${DIST_DIR}" ]; then
    DIST_DIR="${ANDROID_BUILD_TOP}"/out/dist
fi

#get out directory path
while [ $# -ne 0 ]; do
    case "${1}" in
        --out) OUT_IMGDIR=${2};shift;;
        --use-compiled-binaries) FIRMWARE_DIR="${DIST_DIR}";shift;;
    esac
    shift
done

if [[ "${FIRMWARE_DIR}" == "${DIST_DIR}" && ! -e "${DIST_DIR}"/fip.bin && ! -e "${DIST_DIR}"/l-loader.bin ]]; then
    echo "No binaries found at ${DIST_DIR}. Please build the bootloader first"
    exit
fi

if [ -z "${OUT_IMGDIR}" ]; then
    if [ ! -z "${ANDROID_PRODUCT_OUT}" ]; then
        OUT_IMGDIR="${ANDROID_PRODUCT_OUT}"
    fi
fi

if [ ! -d "${OUT_IMGDIR}" ]; then
    echo "error in locating out directory, check if it exist"
    exit
fi

echo "android out imgdir:${OUT_IMGDIR}"

echo "flashing recovery images.. please wait ~10 seconds"
sudo "${INSTALLER_DIR}"/hikey_idt -c "${INSTALLER_DIR}"/config -p "${DEVICE_PORT}"
echo "sleep 10"
sleep 10

echo "skip setting a unique serial number for now"
# stuck on hikey960
# https://discuss.96boards.org/t/cannot-get-hikey-to-show-dev-ttyusb
# 'fastboot oem serialno' is for hikey620
# for hikey960 see https://source.android.com/setup/build/devices#960serial
#echo "set a unique serial number"
#serialno=`fastboot getvar serialno 2>&1 > /dev/null`
#if [ "${serialno:10:6}" == "(null)" ]; then
#    fastboot oem serialno
#else
#    if [ "${serialno:10:15}" == "0123456789abcde" ]; then
#        fastboot oem serialno
#    fi
#fi

echo "flashing all other images"
function check_partition_table_version () {
	echo "fastboot erase reserved"
	fastboot erase reserved
	if [ $? -eq 0 ]
	then
		IS_PTABLE_1MB_ALIGNED=true
	else
		IS_PTABLE_1MB_ALIGNED=false
	fi
}

function flashing_atf_uefi () {
	echo "flashing_atf_uefi ()"
	fastboot flash ptable "${INSTALLER_DIR}"/"${PTABLE}"
	fastboot flash xloader "${INSTALLER_DIR}"/hisi-sec_xloader.img
	#fastboot reboot-bootloader

	fastboot flash fastboot "${INSTALLER_DIR}"/l-loader.bin
	fastboot flash fip "${INSTALLER_DIR}"/fip.bin
	#fastboot flash nvme "${INSTALLER_DIR}"/hisi-nvme.img
	fastboot flash nvme "${INSTALLER_DIR}"/nvme_bs4096_js_raw.img
	#fastboot flash fw_lpm3   "${INSTALLER_DIR}"/hisi-lpm3.img
	#fastboot flash trustfirmware   "${INSTALLER_DIR}"/hisi-bl31.bin
	#fastboot reboot-bootloader

	#fastboot flash ptable "${INSTALLER_DIR}"/"${PTABLE}"
	#fastboot flash xloader "${INSTALLER_DIR}"/hisi-sec_xloader.img
	#fastboot flash fastboot "${INSTALLER_DIR}"/l-loader.bin
	#fastboot flash fip "${INSTALLER_DIR}"/fip.bin

	#fastboot flash boot "${OUT_IMGDIR}"/boot.img
	#fastboot flash system "${OUT_IMGDIR}"/system.img
	fastboot flash vendor "${OUT_IMGDIR}"/vendor.img
	# no cached.img on master
	#fastboot flash cache "${OUT_IMGDIR}"/cache.img
	#fastboot flash userdata "${OUT_IMGDIR}"/userdata.img
}

# NOT USED
function upgrading_ptable_1mb_aligned () {
	echo "upgrading_ptable_1mb_aligned ()"
	fastboot flash xloader "${INSTALLER_DIR}"/hisi-sec_xloader.img
	fastboot flash ptable "${INSTALLER_DIR}"/"${PTABLE}"
	fastboot flash fastboot "${INSTALLER_DIR}"/hisi-fastboot.img
	fastboot reboot-bootloader
}

echo ${ECHO_PREFIX}"Checking partition table version..."
check_partition_table_version

if [ "${IS_PTABLE_1MB_ALIGNED}" == "true" ]
then
	echo ${ECHO_PREFIX}"Partition table is 1MB aligned. Flashing ATF/UEFI..."
	flashing_atf_uefi
else
	echo ${ECHO_PREFIX}"Partition table is 512KB aligned."
	echo ${ECHO_PREFIX}"Upgrading to 1MB aligned version..."
	#upgrading_ptable_1mb_aligned
	echo ${ECHO_PREFIX}"Flasing ATF/UEFI..."
	flashing_atf_uefi
	echo ${ECHO_PREFIX}"Done"
fi

echo "fastboot reboot"
fastboot reboot
