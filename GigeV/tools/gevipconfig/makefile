CC= gcc
IROOT=/usr/dalsa/GigeV

INC_PATH = -I. -I$(IROOT)/include  

CXX_COMPILE_OPTIONS = -c $(DEBUGFLAGS) -DPOSIX_HOSTPC -D_REENTRANT -fno-for-scope \
			-Wall -Wno-parentheses -Wno-missing-braces \
			-Wno-unknown-pragmas -Wno-cast-qual -Wno-unused-function -Wno-unused-label

C_COMPILE_OPTIONS= $(DEBUGFLAGS) -fhosted -Wall -Wno-parentheses -Wno-missing-braces \
		   	-Wno-unknown-pragmas -Wno-cast-qual -Wno-unused-function -Wno-unused-label

ARCH_OPTIONS= -D__arm__ -D_REENTRANT -mthumb-interwork -msoft-float
ARCH_LINK_OPTIONS=-msoft-float


LCLLIBS=  -L/usr/lib/arm-linux-gnueabi -lpthread -L/usr/local/lib -lGevApi -lCorW32

VPATH= . 

%.o : %.cpp
	$(CC) -I. $(INC_PATH) $(CXX_COMPILE_OPTIONS) $(ARCH_OPTIONS) -c $< -o $@

%.o : %.c
	$(CC) -I. $(INC_PATH) $(C_COMPILE_OPTIONS)  $(ARCH_OPTIONS) -c $< -o $@

OBJS= gevipconfig.o 

gevipconfig : $(OBJS)
	$(CC) -g $(ARCH_LINK_OPTIONS) -o gevipconfig $(OBJS) $(LCLLIBS)

clean:
	rm *.o gevipconfig
	
install: gevipconfig
	cp ./gevipconfig /usr/local/bin

uninstall: clean 
	rm -f /usr/local/bin/gevipconfig


