/*****************************************************************
GDRV_COMMON.H												(c) Coreco inc. 2004

Description:
	Linux compatible include.

Platform:
	- Linux (Kernel and User)

Note:

$Log: GDrv_Common.h $
Revision 1.6  2007/06/14 16:08:23  parhug
Added support for synchronous event notification via IOEVENT queues.
Revision 1.5  2006/01/10 13:33:35  PARHUG
Fix macros for GetDispatchID and GetDispatchSection.
Update macro DRV_CTL_CODE so it will work with 64-bit architectures.
Revision 1.4  2004/09/23 17:57:23  BOUERI
- Move define to GDrv_kernel.h
- Added security descriptor.
Revision 1.3  2004/09/14 14:50:53  BOUERI
- Define windows spinlock as Linux spinlock.
Revision 1.2  2004/09/02 16:06:47  parhug
Added GDrv_kernel include file.
Revision 1.1  2004/08/31 14:40:50  parhug
Initial revision

*****************************************************************/
#ifndef _GDRV_COMMON_H
#define _GDRV_COMMON_H

#include <corenv.h>

#ifdef __KERNEL__
#ifndef __CELL__
#include "cordef.h"	// Need type definitions.
#else
#include "GDrv_kernel.h"
#endif
#else
#include <sys/ioctl.h> // User level ONLY
#endif
#include <linux/ioctl.h>

#define SHARE_EVENT_WITH_KERNEL ((void *)-1)
#define SIGNAL_FOR_KERNEL_EVENT	36


//===================================================================
// Linux/POSIX ioctl to WIN32 DeviceIoControl mapping structure for 
// the Sapera API's standard (asynchronous) notification.

typedef struct COR_PACK _DEVIOCTL
{
	void    *inBuffer;
	ULONG   inputBufSize;
	void    *outBuffer;
	ULONG   outputBufSize;
	ULONG   *bytesTransferred;
} DEVIOCTL, *PDEVIOCTL;

// NOTE : IOCTL codes in Linux are 32-bits BUT an emerging standard is to encode
//			direction and transfer size information into the code value. 
//			It is not currently used but may be in the future.
//			In this standard, there are only 8 bits for commands with 8 bits for 
//			the "device type".  (i.e. 16 LSBs are (DEVICE_MAGIC_# | CMD#)). 
//			This is not enough for us.
//			The "device type" will be reduced to 4 bits, 
//			with 4 bits for section and 8 for command.
//			16 LSBs are now ( CORECO_DEVICE_MAGIC_# | SECTION# | CMD#)

#define CORDEVICE_IOC_MAGIC	0xC0

#define GetDispatchID( ioc)		(_IOC_NR((ioc)) & 0xFF)
#define GetDispatchSection( ioc)	(_IOC_TYPE((ioc)) & 0x0F)

#define DRV_CTL_CODE(section, code) _IOWR(((CORDEVICE_IOC_MAGIC & 0xF0) | (section)), (code), DEVIOCTL)
/* Use MSB of the IOC MAGIC to differentiate unused WOW64 IOCTL command definitions from std ones */ 
#define DRV_CTL_WOW64_BIT		_IO(0x80,0)		
#define DRV_CTL_SET_MODE_WOW64(code) ((code) & ~DRV_CTL_WOW64_BIT)
#define DRV_CTL_SET_MODE_NORMAL(code) ((code) | DRV_CTL_WOW64_BIT)

#define FILE_DEVICE_UNKNOWN	0
#define METHOD_BUFFERED 		0
#define FILE_ANY_ACCESS			0

//========================================================================================
// ioctl codes and I/O structures for the raw devices (outside of the Sapera API).
// These are for blocking on the various events that can be generated by the hardware.
// Not all board support all events but they all support events in general since that is
// how Sapera is notified of the arrival of images, triggers, I/O signals, and 
// signalling / timing errors.

typedef enum _EventSource
{
   AcqEvent = 0,
   XferEvent,
   IOEvent,
   AnyEvent
} EventSource;

// Set up the different event sources and the maximum number of each type of source.
#define COR_NUM_EVENT_SOURCES				((int)AnyEvent+1)
#define CORMAX_EVENTSOURCE_INSTANCES	8
#define MAX_IO_EVENTS_QUEUED	500


// Data structure written / read back for ioctl function to obtain IO_EVENT_INFO data.

typedef struct io_event_info
{
   unsigned char  eventSource;   // 4 sources
   unsigned char  sourceIndex;   // 8 indexes (maximum)
   unsigned short eventParam;    // essentially the buffer index
   unsigned int   eventId;       // Bit mask identifying event.
   unsigned int   numPending;    // Number of entries left in this FIFO.
   unsigned int   overflow;      // 0 means OK, 1 means overflow happened.
} IO_EVENT_INFO, *PIO_EVENT_INFO;


// Low level read() function blocks waiting on the AnyEvent fifo and returns
// this data structure (or multiple values of this data structure).

typedef struct io_event_val
{
   unsigned char  eventSource;     // 4 sources
   unsigned char  sourceIndex;     // 8 indexes (maximum)
   unsigned short eventParam;      // essentially the buffer index
   unsigned int   eventId;         // Bit mask identifying event.
} IO_EVENT_VAL, *PIO_EVENT_VAL;


// ioctl function codest o obtain IO_EVENT_INFO data

#define DALSA_DEVICE_RAW_IOC_MAGIC 0xDA

#define IOEVENT_FIFO_RESET _IOWR(DALSA_DEVICE_RAW_IOC_MAGIC, 0, IO_EVENT_INFO)
#define IOEVENT_FIFO_GET   _IOWR(DALSA_DEVICE_RAW_IOC_MAGIC, 1, IO_EVENT_INFO)


#endif

