#!/bin/bash

INSTALLER_DIR="."
OUT_IMGDIR="."

PTABLE=ptable-aosp-32g.img
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
	fastboot flash vendor "${OUT_IMGDIR}"/vendor.img
}


flashing_atf_uefi 
