README.TXT file for MATLAB(R) Version 4.2b 
for Microsoft Windows
(C) Copyright 1994, The MathWorks, Inc.

The current printed documentation is up-to-date with the following 
exceptions:

-----------------------------------------------------------------
COMPILING ENGINE PROGRAMS:
-----------------------------------------------------------------
The commands to compile Engine programs on page 1-4 of the External
Interface Guide Supplement are incorrect.  The following are the
correct versions of these commands.  Note that in all three of the
cases below, you should first set up your PATH, INCLUDE, and/or
LIB environment variables as described in your compiler's manual.

1)      Microsoft Visual C/C++ v1.0:

	CL -ALw -FPi87 -I<matlab>\EXTERN\INCLUDE ENGTEST1.C
     <matlab>\EXTERN\LIB\LIBENGMS.LIB DDEML.LIB LLIBCEW.LIB LIBW.LIB
	
	Note that this may generate the warning message:
	LINK : warning L4021: no stack segment
	This message can be ignored.

2)      Borland C/C++ v4.0:

	BCC -WE -ml! -f287 -2 -Od -I<matlab>\EXTERN\INCLUDE
     ENGTEST1.C <matlab>\EXTERN\LIB\LIBENGBC.LIB

3)      Watcom C/C++ v9.5:

	Create a file called engine.lnk that contains the following
	lines:
	lib <matlab>\extern\lib\libengwc.lib
	lib win386.lib
	lib clib3s.lib
	lib math387s.lib

	Next, execute the command
	WCL386 /w3 /5s /7 /or /zw /l=win386 /I<matlab>\EXTERN\INCLUDE
     ENGTEST1.C @engine.lnk

	Finally, execute the command
	WBIND ENGTEST1 -n


-----------------------------------------------------------------
RUNNING THE ENGTEST PROGRAMS:
-----------------------------------------------------------------
The various engtest.c functions provided with MATLAB pass the variable 
"lpszCmdLine" to the engOpen call.  This means that the command
line arguments entered when the engine program is called will be
used to start MATLAB.  Therefore, to run the engtest programs, you
should choose "Run" from the Program Manager, select or type in the
engine program's name, and follow that with the full path name
to the MATLAB executable.  For example:

	c:\mat42\extern\src\engtest1.exe c:\mat42\bin\matlab
