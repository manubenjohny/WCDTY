%%
%%  	WC.M (PGP 10/23/96)
%%
%%	Analysis program for whole cell traces acquired on the INDEC system using Q.	
%%	The idea is to make the program as straightforward as possible so that additional
%%	sorts of analysis and signal processing can be added later. The program extensively
%%	uses the graphical user interface.  Instead of flags, there are handles and functions 
%%	of handles.

%% now done in batch startup
%clear;
%clf;
%close;


%%	Global Variables

%% now done in batch startup
% global datafilepath datafilename;

global HFmain;

%% 	Debugging Global Variables


%%	Default Variables 


%%	Default Variables (Data Selection)

%% now done in batch startup
%datafilepath = 'c:\My Documents\data\ephys\';
%datafilename = '0';

%%	Default Variables (Analysis)


%%	Default Variables (Other)
global userdatafolder
userdatafolder = 'C:\Users\manu\Documents\Data\';

%%	Initialization

format short e;				%change numeric display
wcinit;

% Variables for pasting into excel, see Htool.m
global ncount ncol bubba;
ncount = 1; bubba = 0;