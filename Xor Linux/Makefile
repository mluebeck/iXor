#############################################################################
# Automatically generated from /usr/src/packages/BUILD/qt-2.2.3/./examples/scribble/Makefile.in
# Build options from 
#############################################################################

QT_CXXFLAGS_OPT = -DQT_NO_QWS_VGA_16 -DQT_NO_QWS_DEPTH_24 -DQT_BUILTIN_GIF_READER=1 -fno-exceptions 
QT_CFLAGS_OPT   = -fno-exceptions 
QT_THREAD_SUFFIX = -mt
QT_LIBS_OPT	=   -lSM -lICE -lpng -lz -ljpeg  
QT_MODULE_OBJ      = \
	    $(OBJECTS_tools) \
	    $(OBJECTS_kernel) \
	    $(OBJECTS_widgets) \
	    $(OBJECTS_dialogs) \
	    $(OBJECTS_iconview) \
	    $(OBJECTS_workspace) \
	    $(OBJECTS_network) \
	    $(OBJECTS_canvas) \
	    $(OBJECTS_table) \
	    $(OBJECTS_xml) 

# Compiling
INTERFACE_DECL_PATH 	= .
SYSCONF_CXX		= g++
SYSCONF_CC		= gcc
DASHCROSS		= 

# Compiling with support libraries
SYSCONF_CXXFLAGS_X11	= -I/usr/X11R6/include
SYSCONF_CXXFLAGS_QT	= -I$(QTDIR)/include
SYSCONF_CXXFLAGS_OPENGL	= -I/usr/X11R6/include

# Compiling YACC output
SYSCONF_CXXFLAGS_YACC     = -Wno-unused -Wno-parentheses

# Linking with support libraries
SYSCONF_RPATH_X11	= -Wl,-rpath,/usr/X11R6/lib
SYSCONF_RPATH_QT	= -Wl,-rpath,$(QTDIR)/lib
SYSCONF_RPATH_OPENGL	= -Wl,-rpath,/usr/X11R6/lib

# Linking with support libraries
# X11
SYSCONF_LFLAGS_X11	= -L/usr/X11R6/lib
SYSCONF_LIBS_X11	= -lXext -lX11 -lm
# Qt, Qt+OpenGL
SYSCONF_LFLAGS_QT	= -L$(QTDIR)/lib
SYSCONF_LIBS_QT		= -lqt$(QT_THREAD_SUFFIX)
SYSCONF_LIBS_QT_OPENGL	= 
# OpenGL
SYSCONF_LFLAGS_OPENGL	= -L/usr/X11R6/lib
SYSCONF_LIBS_OPENGL =
# Yacc
SYSCONF_LIBS_YACC	= 

# Linking applications
SYSCONF_LINK		= g++
SYSCONF_LFLAGS		= 
SYSCONF_LIBS		= 

# Link flags for shared objects
SYSCONF_LFLAGS_SHOBJ	= -shared

# Flags for threading
SYSCONF_CFLAGS_THREAD	= -D_REENTRANT
SYSCONF_CXXFLAGS_THREAD	= -D_REENTRANT
SYSCONF_LFLAGS_THREAD	= 
SYSCONF_LIBS_THREAD	=  -lpthread

# Meta-object compiler
SYSCONF_MOC		= $(QTDIR)/bin/moc

# UI compiler
SYSCONF_UIC		= $(QTDIR)/bin/uic

# Linking shared libraries
#   - Build the $(TARGET) library, eg. lib$(TARGET).so.2.2.2
#   - Place target in $(DESTDIR) - which has a trailing /
#   - Usually needs to incorporate $(VER_MAJ), $(VER_MIN) and $(VER_PATCH)
#
SYSCONF_LINK_SHLIB	= g++
SYSCONF_LINK_TARGET_SHARED	= lib$(TARGET).so.$(VER_MAJ).$(VER_MIN).$(VER_PATCH)
SYSCONF_LINK_LIB_SHARED	=  $(SYSCONF_LINK_SHLIB) -shared -Wl,-soname,lib$(TARGET).so.$(VER_MAJ) \
				     $(LFLAGS) -o $(SYSCONF_LINK_TARGET_SHARED) \
				     $(OBJECTS) $(OBJMOC) $(LIBS) && \
				 mv $(SYSCONF_LINK_TARGET_SHARED) $(DESTDIR); \
				 cd $(DESTDIR) && \
				 rm -f lib$(TARGET).so lib$(TARGET).so.$(VER_MAJ) lib$(TARGET).so.$(VER_MAJ).$(VER_MIN); \
				 ln -s $(SYSCONF_LINK_TARGET_SHARED) lib$(TARGET).so; \
				 ln -s $(SYSCONF_LINK_TARGET_SHARED) lib$(TARGET).so.$(VER_MAJ); \
				 ln -s $(SYSCONF_LINK_TARGET_SHARED) lib$(TARGET).so.$(VER_MAJ).$(VER_MIN)

# Linking static libraries
#   - Build the $(TARGET) library, eg. lib$(TARGET).a
#   - Place target in $(DESTDIR) - which has a trailing /
#
SYSCONF_AR		= ar cqs
SYSCONF_LINK_TARGET_STATIC = lib$(TARGET).a
SYSCONF_LINK_LIB_STATIC	= rm -f $(DESTDIR)$(SYSCONF_LINK_TARGET_STATIC) ; \
				 $(SYSCONF_AR) $(DESTDIR)$(SYSCONF_LINK_TARGET_STATIC) $(OBJECTS) $(OBJMOC) 
# Compiling application source
SYSCONF_CXXFLAGS	= -pipe -O2
SYSCONF_CFLAGS		= -pipe -O2
SYSCONF_LINK_LIB	= $(SYSCONF_LINK_LIB_STATIC)
SYSCONF_LINK_TARGET	= $(SYSCONF_LINK_TARGET_STATIC)
# Compiling library source
SYSCONF_CXXFLAGS_LIB	=
SYSCONF_CFLAGS_LIB	=
# Compiling shared-object source
SYSCONF_CXXFLAGS_SHOBJ	= -fPIC
SYSCONF_CFLAGS_SHOBJ	= -fPIC
# Linking Qt
SYSCONF_LIBS_QTLIB	= $(SYSCONF_CXXFLAGS_X11) $(QT_LIBS_MT) $(QT_LIBS_OPT)
# Linking Qt applications
SYSCONF_LIBS_QTAPP	= $(SYSCONF_LFLAGS_X11) $(SYSCONF_CXXFLAGS_X11) $(QT_LIBS_MT) $(QT_LIBS_OPT) $(SYSCONF_LIBS_X11)
#############################################################################

####### Compiler, tools and options

CXX	=	$(SYSCONF_CXX) $(QT_CXX_MT)
CXXFLAGS=	$(SYSCONF_CXXFLAGS_QT) $(SYSCONF_CXXFLAGS)
CC	=	$(SYSCONF_CC) $(QT_C_MT)
CFLAGS	=	$(SYSCONF_CFLAGS)
INCPATH =	
LFLAGS	=	$(SYSCONF_LFLAGS_QT) $(SYSCONF_RPATH_QT) $(SYSCONF_LFLAGS) $(QT_LFLAGS_MT)
LIBS	=	$(SUBLIBS) $(SYSCONF_LIBS_QT) $(SYSCONF_LIBS) $(SYSCONF_LIBS_QTAPP)
MOC	=	$(SYSCONF_MOC)
UIC	=	$(SYSCONF_UIC)

####### Target

DESTDIR = ./
VER_MAJ = 1
VER_MIN = 0
VER_PATCH = 0
TARGET	= xorwindow
TARGET1 = lib$(TARGET).so.$(VER_MAJ)

####### Files

HEADERS =	playground.h xorwindow.h graphics.h sound.h
SOURCES =	main.cpp \
		xorwindow.cpp playground.cpp graphics.cpp sound.cpp
OBJECTS =	main.o \
		xorwindow.o \
                playground.o \
                graphics.o \
                sound.o

INTERFACES =    
UICDECLS =      
UICIMPLS =      
SRCMOC	=	moc_xorwindow.cpp
OBJMOC	=	moc_xorwindow.o


####### Implicit rules

.SUFFIXES: .cpp .cxx .cc .C .c

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

.cxx.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

.cc.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

.C.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

.c.o:
	$(CC) -c $(CFLAGS) $(INCPATH) -o $@ $<

####### Build rules


all: $(DESTDIR)$(TARGET)

$(DESTDIR)$(TARGET): $(UICDECLS) $(OBJECTS) $(OBJMOC) $(SUBLIBS)
	$(SYSCONF_LINK) $(LFLAGS) -o $(DESTDIR)$(TARGET) $(OBJECTS) $(OBJMOC) $(LIBS)

moc: $(SRCMOC)

tmake:
	tmake xorwindow.pro

clean:
	-rm -f $(OBJECTS) $(OBJMOC) $(SRCMOC) $(UICIMPLS) $(UICDECLS)
	-rm -f *~ core
	-rm -f allmoc.cpp

####### Extension Modules

listpromodules:
	@echo 

listallmodules:
	@echo 

listaddonpromodules:
	@echo 

listaddonentmodules:
	@echo 


REQUIRES=full-config

####### Sub-libraries


###### Combined headers



####### Compile

main.o:	main.cpp \
	xorwindow.h

graphics.o:	graphics.cpp \
		graphics.h

playground.o: 	playground.cpp \
		playground.h \
		graphics.h \
		sound.h

xorwindow.o: 		xorwindow.cpp \
	    		xorwindow.h \

moc_xorwindow.o: 	moc_xorwindow.cpp \
			xorwindow.h \

moc_xorwindow.cpp: 	xorwindow.h xorwindow.cpp

	$(MOC) xorwindow.h -o moc_xorwindow.cpp 
