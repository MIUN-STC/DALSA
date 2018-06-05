
INC_PATH = -I. -I../../include

ARCH_OPTIONS= -D__arm__ -D_REENTRANT

GigeDeviceStatus: gigedevicestatus.c GigeDeviceStatus.glade
	gcc $(INC_PATH) -g -o GigeDeviceStatus $(ARCH_OPTIONS) gigedevicestatus.c -export-dynamic `pkg-config --cflags --libs libglade-2.0` -L/usr/local/lib -lGevApi -lCorW32

default: GigeDeviceStatus

clean:
	rm -f GigeDeviceStatus

install: GigeDeviceStatus
	cp ./GigeDeviceStatus /usr/local/bin

uninstall: clean 
	rm -f /usr/local/bin/GigeDeviceStatus

