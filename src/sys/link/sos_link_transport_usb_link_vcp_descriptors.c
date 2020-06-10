/* Copyright 2011-2018 Tyler Gilbert;
 * This file is part of Stratify OS.
 *
 * Stratify OS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Stratify OS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Stratify OS.  If not, see <http://www.gnu.org/licenses/>. */

#include <errno.h>
#include <string.h>
#include <stdbool.h>
#include <sys/fcntl.h>
#include <unistd.h>
#include "config.h"
#include "sos/link.h"
#include "mcu/mcu.h"
#include "mcu/boot_debug.h"
#include "sos/dev/usb.h"
#include "device/usbfifo.h"
#include "usbd/control.h"
#include "usbd/cdc.h"
#include "mcu/core.h"
#include "mcu/debug.h"
#include "device/sys.h"

#include "sos/link/transport_usb_link_vcp.h"
#include "sos/link/transport_usb_vcp.h"


#define SOS_REQUIRED_CURRENT 500

#define INTERFACE_NUMBER 0
#define INTERFACE_STRING 4

#define VCP0_INTERFACE 1
#define VCP0_INTERFACE_STRING 5

typedef struct MCU_PACK {
	usbd_msft_compatible_id_header_feature_descriptor_t header;
	usbd_msft_compatible_id_interface_feature_descriptor_t interface_feature[3];
} compatible_id_feature_descriptor_t;

static const compatible_id_feature_descriptor_t msft_compatible_id_feature_descriptor =
{
	.header = {
		.length = sizeof(usbd_msft_compatible_id_feature_descriptor_t),
		.bcd = 0x0100,
		.compatible_id_index = 0x0004,
		.section_count[0] = 1,
	},
	.interface_feature[0] = {
		.interface_number = 0,
		.compatible_id = {'W', 'I', 'N', 'U', 'S', 'B', 0x00, 0x00}, //WINUSB\0\0
	},
	.interface_feature[1] = {
		.interface_number = 1,
	},
	.interface_feature[2] = {
		.interface_number = 2,
	}

};


SOS_LINK_TRANSPORT_USB_DEVICE_DESCRIPTOR(link_vcp,239,2,1,BCD_VERSION | 2)

SOS_LINK_TRANSPORT_USB_CONST(
		link_vcp,
		SOS_LINK_TRANSPORT_USB_PORT,
		0,
		0,
		usbd_cdc_event_handler,
		&sos_link_transport_usb_msft_string,
		&msft_compatible_id_feature_descriptor,
		sizeof(msft_compatible_id_feature_descriptor)
		)


const sos_link_transport_usb_link_vcp_configuration_descriptor_t
sos_link_transport_usb_link_vcp_configuration_descriptor MCU_WEAK = {

		.cfg = {
		.bLength = sizeof(usbd_configuration_descriptor_t),
		.bDescriptorType = USBD_DESCRIPTOR_TYPE_CONFIGURATION,
		.wTotalLength = sizeof(sos_link_transport_usb_link_vcp_configuration_descriptor_t)-1, //exclude the zero terminator
		.bNumInterfaces = 2,
		.bConfigurationValue = 0x01,
		.iConfiguration = 2,
		.bmAttributes = USBD_CONFIGURATION_ATTRIBUTES_BUS_POWERED,
		.bMaxPower = USBD_CONFIGURATION_MAX_POWER_MA( SOS_REQUIRED_CURRENT )
		},

		.link_interface = {
		SOS_LINK_TRANSPORT_USB_DECLARE_INTERFACE_CONFIGURATION_DESCRIPTOR(
			INTERFACE_STRING,
			INTERFACE_NUMBER,
			SOS_LINK_TRANSPORT_USB_BULK_ENDPOINT,
			SOS_LINK_TRANSPORT_USB_BULK_ENDPOINT_SIZE
			)
		},

		.vcp = {
		USBD_CDC_DECLARE_CONFIGURATION_DESCRIPTOR(
			VCP0_INTERFACE_STRING,
			VCP0_INTERFACE_STRING,
			VCP0_INTERFACE,
			VCP0_INTERFACE+1,
			SOS_LINK_TRANSPORT_USB_LINK_VCP_INTERRUPT_ENDPOINT,
			SOS_LINK_TRANSPORT_USB_LINK_VCP_INTERRUPT_ENDPOINT_SIZE,
			SOS_LINK_TRANSPORT_USB_LINK_VCP_BULK_ENDPOINT,
			SOS_LINK_TRANSPORT_USB_LINK_VCP_BULK_ENDPOINT_SIZE
			)
		},

		.terminator = 0
		};

const struct sos_link_transport_usb_link_vcp_string_descriptor_t sos_link_transport_usb_link_vcp_string_descriptor MCU_WEAK = {
	.bLength = 4,
	.bDescriptorType = USBD_DESCRIPTOR_TYPE_STRING,
	.wLANGID = 0x0409, //English
	.manufacturer = USBD_ASSIGN_STRING(SOS_LINK_TRANSPORT_USB_DESC_MANUFACTURER_SIZE, SOS_LINK_TRANSPORT_USB_DESC_MANUFACTURER_STRING),
	.product = USBD_ASSIGN_STRING(SOS_LINK_TRANSPORT_USB_DESC_PRODUCT_SIZE, SOS_LINK_TRANSPORT_USB_DESC_PRODUCT_STRING),
	.serial = USBD_ASSIGN_STRING(SOS_LINK_TRANSPORT_USB_DESC_SERIAL_SIZE, 0), //dynamically load SN based on silicon
	.link = USBD_ASSIGN_STRING(SOS_LINK_TRANSPORT_USB_DESCRIPTOR_SOS_LINK_SIZE, SOS_LINK_TRANSPORT_USB_DESCRIPTOR_SOS_LINK),
	.vcp = USBD_ASSIGN_STRING(SOS_LINK_TRANSPORT_LINK_USB_VCP_DESCRIPTOR_SIZE, SOS_LINK_TRANSPORT_LINK_USB_VCP_DESCRIPTOR)
};

