# Microsoft Developer Studio Generated NMAKE File, Based on graphics.dsp
!IF "$(CFG)" == ""
CFG=graphics - Win32 Debug
!MESSAGE Keine Konfiguration angegeben. graphics - Win32 Debug wird als Standard verwendet.
!ENDIF 

!IF "$(CFG)" != "graphics - Win32 Release" && "$(CFG)" != "graphics - Win32 Debug"
!MESSAGE UngÅltige Konfiguration "$(CFG)" angegeben.
!MESSAGE Sie kînnen beim AusfÅhren von NMAKE eine Konfiguration angeben
!MESSAGE durch Definieren des Makros CFG in der Befehlszeile. Zum Beispiel:
!MESSAGE 
!MESSAGE NMAKE /f "graphics.mak" CFG="graphics - Win32 Debug"
!MESSAGE 
!MESSAGE FÅr die Konfiguration stehen zur Auswahl:
!MESSAGE 
!MESSAGE "graphics - Win32 Release" (basierend auf  "Win32 (x86) Console Application")
!MESSAGE "graphics - Win32 Debug" (basierend auf  "Win32 (x86) Console Application")
!MESSAGE 
!ERROR Eine ungÅltige Konfiguration wurde angegeben.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "graphics - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\graphics.exe"


CLEAN :
	-@erase "$(INTDIR)\graphics.obj"
	-@erase "$(INTDIR)\playground.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\xorwindow.obj"
	-@erase "$(OUTDIR)\graphics.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\graphics.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\graphics.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\graphics.pdb" /machine:I386 /out:"$(OUTDIR)\graphics.exe" 
LINK32_OBJS= \
	"$(INTDIR)\graphics.obj" \
	"$(INTDIR)\playground.obj" \
	"$(INTDIR)\xorwindow.obj"

"$(OUTDIR)\graphics.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "graphics - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\xorwindow.exe"


CLEAN :
	-@erase "$(INTDIR)\graphics.obj"
	-@erase "$(INTDIR)\playground.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\xorwindow.obj"
	-@erase "$(OUTDIR)\xorwindow.exe"
	-@erase "$(OUTDIR)\xorwindow.ilk"
	-@erase "$(OUTDIR)\xorwindow.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MD /W3 /Gm /GX /ZI /Od /I "$(QTDIR)\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "QT_DLL" /D "UNICODE" /D "QT_THREAD_SUPPORT" /Fp"$(INTDIR)\graphics.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\graphics.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib imm32.lib winmm.lib wsock32.lib imm32.lib wsock32.lib winmm.lib $(QTDIR)\lib\qt-mt230nc.lib $(QTDIR)\lib\qtmain.lib /nologo /subsystem:windows /incremental:yes /pdb:"$(OUTDIR)\xorwindow.pdb" /debug /machine:I386 /nodefaultlib:"libc" /out:"$(OUTDIR)\xorwindow.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\graphics.obj" \
	"$(INTDIR)\playground.obj" \
	"$(INTDIR)\xorwindow.obj"

"$(OUTDIR)\xorwindow.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("graphics.dep")
!INCLUDE "graphics.dep"
!ELSE 
!MESSAGE Warning: cannot find "graphics.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "graphics - Win32 Release" || "$(CFG)" == "graphics - Win32 Debug"
SOURCE=.\graphics.cpp

"$(INTDIR)\graphics.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\playground.cpp

"$(INTDIR)\playground.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\xorwindow.cpp

"$(INTDIR)\xorwindow.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

