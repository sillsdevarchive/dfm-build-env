@echo off
:: Title: pub.cmd
:: Title Description: VimodPub batch file with menus and tasklist processing
:: Author: Ian McQuay
:: Created: 2012-03
:: Last Modified: 2013-12-05
:: Source: projects.palaso.org
:: Optional command line parameter:
:: projectpath - absolute or relative path.

:main
:: Description: Starting point of pub.cmd
:: Class: command - internal - startup
:: Optional parameters:
:: projectpath or debugfunc - project path must contain a sub folder setup containing a project.menu or dubugfunc must be "debug"
:: functiontodebug
:: * - more debug parameters
:: Required functions:
:: funcdebugstart
:: funcdebugend
:: choosegroup
rem set the codepage to unicode to handle special characters in parameters
if "%PUBLIC%" == "C:\Users\Public" (
	  rem if "%PUBLIC%" == "C:\Users\Public" above is to prevent the following command running on Windows XP
	  if not defined skipsettings chcp 65001
	  )
call :setup
if defined echofromstart echo on
if defined masterdebug call :funcdebugstart main
set projectpath=%1
set debugfunc=%1
set functiontodebug=%2
set params=%3 %4 %5 %6 %7 %8 %9
echo.
if not defined skipsettings echo                        Vimod-Pub
if not defined skipsettings echo     Various inputs multiple outputs digital publishing
if not defined skipsettings echo       http://projects.palaso.org/projects/vimod-pub
echo    ----------------------------------------------------
if defined projectpath (
	rem this option when a valid menu is chosen
	if exist "%projectpath%\%projectsetupfolder%\project.menu" (
	  call :menu "%projectpath%\%projectsetupfolder%\project.menu" "Choose project action?"
	) else (
		rem debugging option
		echo on
		@echo debugging %functiontodebug%
		call :%functiontodebug% %params%
	)
)  else (
	rem default option with base menu
	rem call :choosegroup
	call :menu data\%projectsetupfolder%\project.menu "Choose Group?"
)
if defined masterdebug call :funcdebugend
goto :eof

rem Menuing and control functions ==============================================

:menu
:: Description: starts a menu
:: Class: command - menu
:: Required parameters:
:: newmenulist
:: title
:: forceprojectpath
:: Required functions:
:: funcdebugstart
:: variableslist
:: checkifvimodfolder
:: menuwriteoption

if defined masterdebug call :funcdebugstart menu
set newmenulist=%~1
set title=%~2
set errorlevel=
set forceprojectpath=%~3
set skiplines=%~4
set defaultprojectpath=%~dp1
set defaultjustprojectpath=%~p1
set prevprojectpath=%projectpath%
set prevmenu=%menulist%
set letters=%lettersmaster%
set tasklistnumb=
set count=0
set varvalue=
if defined echomenuparams echo menu params=%~0 "%~1" "%~2" "%~3" "%~4"
::call :ext %newmenulist%
rem detect if projectpath should be forced or not
if defined forceprojectpath (
	if defined echoforceprojectpath echo forceprojectpath=%forceprojectpath%
	set setuppath=%forceprojectpath%\%projectsetupfolder%
	set projectpath=%forceprojectpath%
	if exist "setup-pub\%newmenulist%" (
			set menulist=setup-pub\%newmenulist%
			set menutype=settings
	) else (
			set menulist=%commonmenufolder%\%newmenulist%
			set menutype=commonmenutype
	)
) else (

	if defined echoforceprojectpath echo forceprojectpath=%forceprojectpath%
	set projectpathbackslash=%defaultprojectpath:~0,-6%
	set projectpath=%defaultprojectpath:~0,-7%
	if defined userelativeprojectpath call :removeCommonAtStart projectpath "%projectpathbackslash%"
	set setuppath=%defaultprojectpath:~0,-1%
	echo off
	if exist "%newmenulist%" (
		set menulist=%newmenulist%
		set menutype=projectmenu
	) else (
		  set menutype=createdynamicmenu
		  set menulist=created
	)
)
if defined echomenulist echo menulist=%menulist%
if defined echomenutype echo menutype=%menutype%
if defined echoprojectpath echo %projectpath%
rem ==== start menu layout =====
set title=                     %~2
set menuoptions=
echo.
echo %title%
if defined echomenufile echo menu=%~1
if defined echomenufile echo menu=%~1
echo.
rem process the menu types to generate the menu items.
if "%menutype%" == "projectmenu" FOR /F "eol=# tokens=1,2 delims=;" %%i in (%menulist%) do set action=%%j&call :menuwriteoption "%%i" %%j
if "%menutype%" == "commonmenutype" FOR /F "eol=# tokens=1,2 delims=;" %%i in (%menulist%) do set action=%%j&call :menuwriteoption "%%i"
if "%menutype%" == "settings" call :writeuifeedback "%menulist%" %skiplines%
if "%menutype%" == "createdynamicmenu" for /F "eol=#" %%i in ('dir "%projectpath%" /b/ad') do (
	set action=menu "%projectpath%\%%i\%projectsetupfolder%\project.menu" "%%i project"
	call :checkifvimodfolder %%i
	if not defined skipwriting call :menuwriteoption %%i
)
if "%menulist%" neq "utilities.menu" (
	if defined echoutilities echo.
	if defined echoutilities echo        %utilityletter%. Utilities
)
echo.
if "%newmenulist%" == "data\%projectsetupfolder%\project.menu" (
	echo        %exitletter%. Exit batch menu
) else (
	if "%newmenulist%" == "%commonmenufolder%\utilities.menu" (
	  echo        %exitletter%. Return to Groups menu
	) else (
	  echo        %exitletter%. Return to calling menu
	)
)
echo.
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%
IF /I '%Choice%' == '%utilityletter%' call :menu utilities.menu "Utilities Menu" "%projectpath%"
IF /I '%Choice%'=='%exitletter%' (
	if "%menulist%" == "%commonmenufolder%\utilities.menu" (
	  set skipsettings=on
	  pub
	) else (
		echo ...exit menu &exit /b
	)
)

:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
FOR /D %%c IN (%menuoptions%) DO call :menueval %%c
if defined masterdebug call :funcdebugend
goto :menu

:menuwriteoption
:: Description: writes menu option to screen
:: Class: command - internal - menu
:: Required preset variable: 1
:: leters
:: action
:: Required parameters: 1
:: menuitem

set menuitem=%~1
set checkfunc=%~2
:: write the menu item
if /%checkfunc%/ == /commonmenu/ (
call :%action%
exit /b
)
if /%checkfunc%/ == /menublank/ (
echo                   ---

exit /b
)
set let=%letters:~0,1%
if "%let%" == "%stopmenubefore%" goto :eof
	  echo        %let%. %menuitem%
set letters=%letters:~1%
rem set the option letter
set option%let%=%action%
rem make the letter list
set menuoptions=%let% %menuoptions%
goto :eof

:commonmenu
:: Description: Will write menu lines from a menu file in the %commonmenufolder% folder
:: Class: command - menu
:: Used by: menu
:: Required parameters:
:: commonmenu
set commonmenu=%~1
FOR /F "eol=# tokens=1,2 delims=;" %%i in (%commonmenufolder%\%commonmenu%) do set action=%%j&call :menuwriteoption "%%i"
goto :eof


:menuvaluechooser
:: Description: Will write menu lines from a menu file in the commonmenu folder
:: Class: command - internal - menu
:: Used by: menu
:: Required parameters:
:: commonmenu
rem echo on
set list=%~1
set menuoptions=
set option=
set letters=%lettersmaster%
echo.
echo %title%
echo.
FOR /F %%i in (%commonmenupath%\%list%) do call :menuvaluechooseroptions %%i
echo.
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%

:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
	echo on
FOR /D %%c IN (%menuoptions%) DO call :menuvaluechooserevaluation %%c
echo off
echo outside loop
rem call :menuevaluation %%c
echo %valuechosen%
pause
if "%varvalue%" == "set" exit /b
goto :eof

:menuvaluechooseroptions
:: Description: Processes the choices
:: Class: command - internal - menu
set menuitem=%~1
set let=%letters:~0,1%
set value%let%=%~1
if "%let%" == "%stopmenubefore%" goto :eof
	  echo        %let%. %menuitem%
set letters=%letters:~1%
rem set the option letter
rem make the letter list
set menuoptions=%menuoptions% %let%
goto :eof

:menuvaluechooserevaluation
:: Class: command - internal - menu
rem echo on
if defined varvalue goto :eof
set let=%~1
IF /I '%Choice%'=='a' set valuechosen=%valuea%& set varvalue=set& exit /b
IF /I '%Choice%'=='b' set valuechosen=%valueb%& set varvalue=set& exit /b
IF /I '%Choice%'=='c' set valuechosen=%valuec%& set varvalue=set& exit /b
IF /I '%Choice%'=='d' set valuechosen=%valued%& set varvalue=set& exit /b
IF /I '%Choice%'=='e' set valuechosen=%valuee%& set varvalue=set& exit /b
IF /I '%Choice%'=='f' set valuechosen=%valuef%& set varvalue=set& exit /b
IF /I '%Choice%'=='g' set valuechosen=%valueg%& set varvalue=set& exit /b
IF /I '%Choice%'=='h' set valuechosen=%valueh%& set varvalue=set& exit /b
IF /I '%Choice%'=='i' set valuechosen=%valuei%& set varvalue=set& exit /b
IF /I '%Choice%'=='j' set valuechosen=%valuej%& set varvalue=set& exit /b
IF /I '%Choice%'=='k' set valuechosen=%valuek%& set varvalue=set& exit /b
IF /I '%Choice%'=='l' set valuechosen=%valuel%& set varvalue=set& exit /b
IF /I '%Choice%'=='m' set valuechosen=%valuem%& set varvalue=set& exit /b
goto :eof


:checkifvimodfolder
:: Description: set the variable skipwriting so that the calling function does not write a menu line.
:: Used by: menu
:: Optional preset variables:
:: echomenuskipping
:: Required parameters:
:: project

set project=%~1
set skipwriting=

if "%project%" == "%projectsetupfolder%" (
	if defined echomenuskipping echo skipping dir: %project%
	set skipwriting=on
)
if "%project%" == "xml" (
	if defined echomenuskipping echo skipping dir: %project%
	set skipwriting=on
)
if "%project%" == "logs" (
	if defined echomenuskipping echo skipping dir: %project%
	set skipwriting=on
)
goto :eof

:menueval
:: Description: resolves the users entered letter and starts the appropriate function
:: run through the choices to find a match then calls the selected option
:: Required preset variable: 1
:: choice
:: Required parameters: 1
:: let
if defined masterdebug call :funcdebugstart menueval
if defined varvalue exit /b
set let=%~1
set option=option%let%
:: /I makes the IF comparison case-insensitive
IF /I '%Choice%'=='%let%' call :%%%option%%%
if defined masterdebug call :funcdebugend
goto :eof

rem inc is inclueded so that an xslt transformation can also process this tasklist. Not all tasklists may need processing into params.
:inc
:tasklist
:: Discription: Processes a tasks file.
:: Required preset variables: 3
:: projectlog
:: setuppath
:: commontaskspath
:: Required parameters: 1
:: tasklistname
:: Func calls:
:: funcdebugstart
:: funcdebugend
:: nameext
:: * - tasks from tasks file
if defined breaktasklist1 echo on
if defined masterdebug call :funcdebugstart tasklist
set tasklistname=%~1
set /A tasklistnumb=%tasklistnumb%+1
if "%tasklistnumb%" == "1" set errorsuspendprocessing=
if defined breaktasklist1 pause
call :checkdir "%projectpath%\xml"
call :checkdir "%projectpath%\logs"
set projectlog="%projectpath%\logs\%date:~-4,4%-%date:~-7,2%-%date:~-10,2%-build.log"
set projectbat="%projectpath%\logs\%date:~-4,4%-%date:~-7,2%-%date:~-10,2%-build.bat"
:: checks if the list is in the commontaskspath, setuppath (default), if not then tries what is there.
if exist "%setuppath%\%tasklistname%" (
	set tasklist=%setuppath%\%tasklistname%
	if defined echotasklist echo [---- tasklist%tasklistnumb% project %tasklistname% ---- %time% ----
	if defined echotasklist echo.
) else (
	if exist "%commontaskspath%\%tasklistname%" (
		set tasklist=%commontaskspath%\%tasklistname%
		if defined echotasklist echo [---- tasklist%tasklistnumb% common  %tasklistname% ---- %time% ----
		if defined echotasklist echo.
	) else (
		echo tasklist "%tasklistname%" not found
		pause
		exit /b
	)
)
if exist "%setuppath%\project.variables" (
	  call :variableslist "%setuppath%\project.variables"
)
if defined breaktasklist2 pause
FOR /F "eol=# tokens=2 delims=;" %%i in (%tasklist%) do call :%%i  %errorsuspendprocessing%

if defined breaktasklist3 pause
if defined echotasklistend echo   -------------------  tasklist%tasklistnumb% ended.  %time%]
@if defined masterdebug call :funcdebugend
set /A tasklistnumb=%tasklistnumb%-1
goto :eof


:setup
:: Description: sets variables for the batch file
:: Required rerequisite variables
:: projectpath
:: htmlpath
:: localvar
:: Func calls: 1
:: checkdir
if defined masterdebug call :funcdebugstart pubvar
set basepath=%cd%

rem check if logs directory exist and creat if not there  DO NOT change to checkdir
if not exist "%cd%\logs" md "%cd%\logs"


rem set project log file name by date
set projectlog=logs\%date:~-4,4%-%date:~-7,2%-%date:~-10,2%-build.log

rem set the predefined variables
call :variableslist setup-pub\vimod.variables

rem selfvalue is set so the list of path installed tools will become: set ccw32=ccw32. They are used this way so that if an absolute path is needed it can be set in user_installed.tools
rem the following line is removed as path tools moved back into user_installed.tools
rem set selfvalue=on

rem remove this for now
rem if exist setup-pub\user_path_installed.tools call :variableslist setup-pub\user_path_installed.tools

rem test if essentials exist
call :variableslist setup-pub\essential_installed.tools fatal
rem added to aid new users in setting up
if not defined java call :testjava
if exist setup-pub\user_installed.tools call :variableslist setup-pub\user_installed.tools
if exist setup-pub\user_feedback.settings if not defined skipsettings call :variableslist setup-pub\user_feedback.settings
if exist setup-pub\functiondebug.settings if not defined skipsettings call :variableslist setup-pub\functiondebug.settings
set classpath=%classpath%;%extendclasspath%
call :checkdir %cd%\data\logs
if defined masterdebug call :funcdebugend
goto :eof


:checkdir
:: Description: checks if dir exists if not it is created
:: See also: ifnotexist
:: Required preset variabes: 1
:: projectlog
:: Optional preset variables:
:: echodirnotfound
:: Required parameters: 1
:: dir
:: Required functions:
:: funcdebugstart
:: funcdebugend
if defined masterdebug call :funcdebugstart checkdir
set dir=%~1
set report=Checking dir %dir%
if exist %dir% (
	  echo . . . Found! %dir% >>%projectlog%
) else (
	call :removecommonatstart dirout "%dir%"
	if defined echodirnotfound echo Creating . . . %dirout%
	echo . . . not found. %dir% >>%projectlog%
	echo mkdir %dir% >>%projectlog%
	mkdir "%dir%"
)
if defined masterdebug call :funcdebugend
goto :eof

:validatevar
:: validate variables passed in
set testvar=%~1
if not defined %testvar:"=% (
			echo No %~1 var found defined
			echo Please add this to the setup-pub\user_installed.tools
			echo The program will exit after this pause.
			pause
			exit /b
	  )
goto :eof

rem built in commandline functions =============================================
:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'"
:: Limitations: When command line needs single quote.
:: Required parameters:
:: curcommand
:: extraparam - up to 7 more
:: Required functions:
:: funcdebugstart
:: funcdebugend
:: inccount
:: echolog
if defined masterdebug call :funcdebugstart usercommand
call :inccount
set curcommand=%~1
set commandpath=
set commandpath=%~2
set startdir=%cd%
set curcommand=%curcommand:'="%
echo %curcommand%>>%projectlog%
if defined echousercommand echo %curcommand%
if defined commandpath cd "%commandpath%"
%curcommand%
if defined commandpath cd "%startdir%"
if defined masterdebug call :funcdebugend
goto :eof

:spaceremove
set string=%~1
set spaceremoved=%string: =%
goto :eof



rem External tools functions ===================================================



:cct
:: Description: Privides interface to CCW32.
:: Required preset variables:
:: ccw32
:: Optional preset variables:
:: Required parameters:
:: script - can be one script.cct or serial comma separated "script1.cct,script2.cct,etc"
:: Optional parameters: 2
:: infile
:: outfile
:: Required functions:
:: infile
:: outfile
:: inccount
:: before
:: after
if defined masterdebug call :funcdebugstart cct
set script=%~1
call :infile "%~2"
set scriptout=%script:.cct,=_%
call :inccount
call :outfile "%~3" "%projectpath%\xml\%pcode%-%count%-%scriptout%.xml"
set basepath=%cd%
rem if not defined ccw32 set ccw32=ccw32
set curcommand=%ccw32% %cctparam% -t "%script%" -o "%outfile%" "%infile%"
call :before
cd %cctpath%
%curcommand%
cd %basepath%
call :after "Consistent Changes"
::
if defined masterdebug call :funcdebugend
goto :eof


:xslt
:: Description: Provides interface to xslt2 by saxon9.jar
:: Required preset variables: 1
:: java
:: saxon9
:: Required parameters: 1
:: scriptname
:: Optional parameters: 3
:: allparam
:: infile
:: outfile
:: Func calls:
:: inccount
:: infile
:: outfile
:: quoteinquote
:: before
:: after
if defined errorsuspendprocessing goto :eof
if defined masterdebug call :funcdebugstart xslt
call :inccount
set script=%xsltpath%\%~1.xslt
set param=
set allparam=
set allparam=%~2
if defined allparam set param=%allparam:'="%
call :infile "%~3"
call :outfile "%~4" "%projectpath%\xml\%pcode%-%count%-%~1.xml"
set trace=
if defined echojavatrace set trace=-t
if not defined resolvexhtml (
	  set curcommand="%java%" -jar "%cd%\%saxon9%" -o:"%outfile%" "%infile%" "%script%" %param%

) else (
	  set curcommand="%java%" %loadcat%=%cat% net.sf.saxon.Transform %trace% %usecatalog1% %usecatalog2% -o:"%outfile%" "%infile%" "%script%" %param%
)
call :before
%curcommand%
call :after "XSLT transformation"
if defined masterdebug call :funcdebugend
goto :eof

rem replaces getvar
:projectvar
:: Description: get the variables
call :tasklist project.tasks
goto :eof

:projectxslt
:: Description: make project.xslt from project.tasks
:: Required preset variables: 1
:: projectpath
:: Required functions:
:: getdatetime
:: xslt
call :getfiledatetime tasksdate "%projectpath%\setup\project.tasks"
call :getfiledatetime xsltdate "%cd%\scripts\xslt\project.xslt"
rem firstly check if this is the last project run
if "%lastprojectpath%" == "%projectpath%" (
  rem then check if the project.tasks is newer than the project.xslt
  set /A tasksdate-=%xsltdate%
  if %tasksdate% GTR %xsltdate% (
	rem if the project.tasks is newer then remake the project.xslt
	echo  project.tasks newer: remaking project.xslt %tasksdate% ^> %xsltdate%
	echo.
	call :xslt vimod-projecttasks2variable "projectpath='%projectpath%'" blank.xml "%cd%\scripts\xslt\project.xslt"
	set lastprojectpath=%projectpath%
	goto :eof
  ) else (
	call :inccount
	rem nothing has changed so don't remake project.xslt
	echo 1 project.xslt is newer. %xsltdate% ^> %tasksdate% project.tasks
	rem echo     Project.tasks  ^< %xsltdate% project.xslt.
	echo.
  )
) else (
  rem the project is not the same as the last one or Vimod has just been started. So remake project.xslt
  if defined lastprojectpath echo Project changed from "%lastprojectpath:~37%" to "%projectpath:~37%"
  if not defined lastprojectpath echo New session for project: %projectpath:~37%
  echo.
  echo Remaking project.xslt
  echo.
  call :xslt vimod-projecttasks2variable "projectpath='%projectpath%'" blank.xml "%cd%\scripts\xslt\project.xslt"
)
set lastprojectpath=%projectpath%
goto :eof

:copy
:: Description: Provides copying with exit on failure
:: Required preset variables:
:: ccw32
:: Optional preset variables:
:: Required parameters:
:: script - can be one script.cct or serial comma separated "script1.cct,script2.cct,etc"
:: Optional parameters: 2
:: infile
:: outfile
:: Required functions:
:: infile
:: outfile
:: inccount
:: before
:: after
if defined masterdebug call :funcdebugstart copy
call :infile "%~1"
call :inccount
call :outfile "%~2"
set curcommand=copy /y "%infile%" "%outfile%"
call :before
%curcommand%
call :after Copy Changes"
::
if defined masterdebug call :funcdebugend
goto :eof

:md5compare
:: no current use
:: Description: Compares the MD5 of the current project.tasks with the previous one, if different then the project.xslt is remade
:: Purpose: to see if the project.xslt needs remaking
:: Required preset variables: 1
:: cd
:: projectpath
:: Required parameters: 0
:: Required functions:
:: md5create
:: getline
set md5check=diff
if exist "%cd%\logs\project-tasks-cur-md5.txt" del "%cd%\logs\project-tasks-cur-md5.txt"
call :md5create "%projectpath%\setup\project.tasks" "%cd%\logs\project-tasks-cur-md5.txt"
if exist  "%cd%\logs\project-tasks-last-md5.txt" (
  call :getline 4 "%cd%\logs\project-tasks-last-md5.txt"
  set lastmd5=%getline%
  call :getline 4 "%cd%\logs\project-tasks-cur-md5.txt"
  rem clear getline var
  set getline=
  if "%lastmd5%" == "%getline%" (
	set md5check=same
  )
)
del "%cd%\logs\project-tasks-last-md5.txt"
ren "%cd%\logs\project-tasks-cur-md5.txt" "project-tasks-last-md5.txt"
goto :eof

:md5create
:: no current use
:: Description: Make a md5 check file
call fciv "%~1" >"%~2"
goto :eof

:xquery
:: Description: Provides interface to xquery by saxon9.jar
:: Required preset variables: 1
:: java
:: saxon9
:: Required parameters: 1
:: scriptname
:: Optional parameters: 3
:: allparam
:: infile
:: outfile
:: Func calls: 6
:: inccount
:: infile
:: outfile
:: quoteinquote
:: before
:: after
:: created: 2013-08-20
if defined masterdebug call :funcdebugstart xquery
set scriptname=%~1
set allparam=%~2
call :infile "%~3"
call :outfile "%~4" "%projectpath%\xml\%pcode%-%writecount%-%scriptname%.xml"
call :inccount
set script=scripts\xquery\%scriptname%.xql
call :quoteinquote param "%allparam%"
set curcommand="%java%" net.sf.saxon.Query -o:"%outfile%" -s:"%infile%" "%script%" %param%
call :before
%curcommand%
call :after "XQuery transformation"
if defined masterdebug call :funcdebugend
goto :eof

:testjava
:: Description: Test if java is installed. Attempt to use local java.exe otherwise it will exit with a warning.

set javainstalled=
where java /q
if "%errorlevel%" ==  "0" set javainstalled=yes
rem if defined JAVA_HOME set javainstalled=yes
if not defined javainstalled (
	  if exist %altjre% (
			set java=%altjre%
	  ) else (
			echo No java found installed nor was java.exe found inVimod-Pub tools\java folder.
			echo Please install Java on your machine.
			echo Get it here: http://www.java.com/en/download/
			echo The program will exit after this pause.
			pause
			exit /b
	  )
) else (
	  set java=java
)
goto :eof




:manyparam
:: Description: Allows spreading of long commands accross many line in a tasks file. Needed for wkhtmltopdf.
:: Class: command - exend
:: Required preset variables: 1
:: first - set for all after the first of manyparam
:: Optional preset variables:
:: first - Not required for first of a series
:: Required parameters: 1
:: newparam
if defined masterdebug call :funcdebugstart manyparam
set newparam=%~1
set param=%param% %newparam%
if defined masterdebug call :funcdebugend
goto :eof

:manyparamcmd
:: Description: places the command before all the serial parameters Needed for wkhtmltopdf.
:: Class: command - exend
:: Required preset variables: 1
:: param
:: Optional preset variables:
:: Required parameters: 1
:: command                                                       0
if defined masterdebug call :funcdebugstart manyparamcmd
set command=%~1
rem this can't work here: call :quoteinquote param %param%
if defined param set param=%param:'="%
call :echolog "%command%" %param%
"%command%"  %param%
rem clear the first variable
set param=
if defined masterdebug call :funcdebugend
goto :eof



rem Tools sub functions ========================================================

:before
:: Description: Checks if outfile exists, renames it if it does. Logs actions.
:: Class: command - internal
:: Required preset variables:
:: projectlog
:: projectbat
:: Optional preset variables:
:: outfile
:: curcommand
:: writebat
:: Func calls: 1
:: echolog
:: nameext

if defined masterdebug call :funcdebugstart before
if defined echocommandtodo echo Command to be attempted:
if defined echocommandtodo echo %curcommand%
echo "Command to be attempted:" >>%projectlog%
echo "%curcommand%" >>%projectlog%
if defined writebat echo %curcommand%>>%projectbat%
echo. >>%projectlog%
if exist "%outfile%" call :nameext "%outfile%"
if exist "%outfile%.pre.txt" del "%outfile%.pre.txt"
if exist "%outfile%" ren "%outfile%" "%nameext%.pre.txt"
if defined masterdebug call :funcdebugend
goto :eof

:after
:: Description: Checks if outfile is created. Reports failures logs actions. Restors previous output file on failure.
:: Class: command - internal
:: Required preset variables: 3
:: outfile
:: projectlog
:: writecount
:: Optional parameters:
:: report3
:: message
:: Func calls:
:: nameext
if defined masterdebug call :funcdebugstart after
set message=%~1
call :nameext "%outfile%"
if not exist "%outfile%" (
	set errorlevel=1
	echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  >>%projectlog%
	echo %message% failed to create %nameext%.                           >>%projectlog%
	echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  >>%projectlog%
	echo. >>%projectlog%
	if exist "%outfile%.pre.txt" (
			call :echolog ren "%outfile%.pre.txt" "%nameext%"
			ren "%outfile%.pre.txt" "%nameext%"
			call :echolog Previously existing %nameext% restored.
			call :echolog The following processes will work on the previous version.
			call :echolog ???????????????????????????????????????????????????????????????
			echo .
	)
	echo.
	color E0
	echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	echo %message% failed to create %nameext%.
	if not defined nopauseerror (
		echo.
		echo Read error above and resolve issue then try again.
		echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		echo.
		pause
		echo.
		set errorsuspendprocessing=true
	)
	if defined nopauseerror echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	color 07
) else (
	if defined echoafterspacepre echo.
	call :echolog %writecount% Created:   %nameext%

	if defined echoafterspacepost echo.
	echo ---------------------------------------------------------------- >>%projectlog%
	::echo. >>%projectlog%
	if exist "%outfile%.pre.txt" del "%outfile%.pre.txt"
)
if defined masterdebug call :funcdebugend
goto :eof

:nameext
:: Description: returns name and extension from a full drive:\path\filename
:: Class: command - parameter manipulation
:: Required parameters: 1
:: drive:\path\name.ext or path\name.ext or name.ext
:: created variable:
:: nameext
set nameext=%~nx1
goto :eof

:ext
:: Description: returns file extension from a full drive:\path\filename
:: Class: command - parameter manipulation
:: Required parameters: 1
:: drive:\path\name.ext or path\name.ext or name.ext
:: created variable:
:: nameext
set ext=%~x1
goto :eof

:name
:: Description: Gets the name of a file (no extension) from a full drive:\path\filename
:: Class: command - parameter manipulation
:: Required parameters: 1
:: drive:\path\name.ext or path\name.ext or name.ext
:: created variable:
:: name
set name=%~n1
goto :eof

:drivepath
:: Description: returns the drive and path from a full drive:\path\filename
:: Class: command - parameter manipulation
:: Required parameters:
:: Group type: parameter manipulation
:: drive:\path\name.ext or path\name.ext
set drivepath=%~dp1
if defined echodrivepath echo %drivepath%
goto :eof

:file2uri
:: Description: transforms dos path to uri path. i.e. c:\path\file.ext to file:///c:/path/file.ext  not needed for XSLT
:: Class: command - parameter manipulation
:: Required parameters:  1
:: pathfile
:: Optional parameters:
:: number
:: created variables: 1
:: uri%number%
if defined masterdebug call :funcdebugstart file2uri
call :setvar pathfile "%~1"
set numb=%~2
set uri%numb%=file:///%pathfile:\=/%
set return=file:///%pathfile:\=/%
if defined echofile2uri call :echolog       uri%numb%=%return:~0,25% . . . %return:~-30%
if defined masterdebug call :funcdebugend
goto :eof

:inccount
:: Description: iIncrements the count variable
:: Class: command - internal - parameter manipulation
:: Required preset variables:
:: space
:: count - on second and subsequent use
:: Optional preset variables: 1
:: count - on first use
set /A count=%count%+1
set writecount=%count%
if %count% lss 10 set writecount=%space%%count%
goto :eof


:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Class: command
:: Required preset variables: 1
:: outfile
:: Required parameters: 1
:: newfilename
:: Func calls: 3
:: inccount
:: drivepath
:: nameext
if defined errorsuspendprocessing goto :eof
if defined masterdebug call :funcdebugstart outputfile
call :inccount
set infile=%outfile%
set filename=%~1
call :drivepath "%filename%"
call :nameext "%filename%"
set outfile=%drivepath%%nameext%
set curcommand=copy /Y "%infile%" "%outfile%"
call :before
%curcommand% >> %projectlog%
call :after "Copied "%infile%" to "%outfile%"
if defined masterdebug call :funcdebugend
goto :eof

:pause
:: Description: Pauses work until user interaction
:: Class: command - user interaction
pause
goto :eof

:debugpause
:: Description: Sets the debug pause to on
:: Class: command - debug
if defined debugpause echo debugging pause
pause
goto :eof

:debugpauseon
:: Description: Sets the debug pause to on
:: Class: command - debug
set debugpause=on
goto :eof

:plugin
:: Description: used to access external plugins
:: Class: command - external - extend
:: Optional preset variables:
:: outputdefault
:: Required parameters:
:: action
:: Optional parameters:
:: pluginsubtask
:: params
:: infile
:: outfile
:: Required functions:
:: infile
:: outfile
call :inccount
set plugin=%~1
set pluginsubtask=%~2
set params=%~3
rem if (%params%) neq (%params:'=%) set params=%params:'="%
if defined params set params=%params:'="%
call :infile "%~4"
call :outfile "%~5" "%outputdefault%"
set curcommand=call plugins\%plugin%
call :before
%curcommand%
call :after "%plugin% plugin complete"
goto :eof

:dirlist
:: Description: Creates a directory list in a file
:: Class: Command - external
:: Required functions:
:: dirpath
:: dirlist - a file path and name
echo on
set dirpath=%~1
set dirlist=%~2
dir /b "%dirpath%" > "%dirlist%"
echo off
goto :eof


:infile
:: Description: If infile is specifically set then uses that else uses previous outfile.
:: Class: command - internal - pipeline - parameter
:: Required parameters: 1
:: testinfile
set testinfile=%~1
if "%testinfile%" == "" (
set infile=%outfile%
) else (
set infile=%testinfile%
)
goto :eof

:outfile
:: Description: If out file is specifically set then uses that else uses supplied name.
:: Class: command - internal - pipeline- parameter
:: Required parameters: 2
:: testoutfile
:: defaultoutfile
set testoutfile=%~1
set defaultoutfile=%~2
if "%testoutfile%" == "" (
set outfile=%defaultoutfile%
) else (
set outfile=%testoutfile%
)
goto :eof

:setdefaultoptions
:: Description: Sets default options if not specifically set
:: class: command - parameter - fallback
:: Required parameters:
:: testoption
:: defaultoption
set testoption=%~1
set defaultoption=%~2
if "%testoption%" == "" (
  set options=%defaultoption%
) else (
set options=%testoption%
)
goto :eof


:setvarlist
:: depreciated: use var
:resolve
:: depreciated: use var
:setvar
:var
:: Description: sets the variable
:: class: command - parameter
:: Required parameters: 2
:: varname
:: value
:: Added handling so that a third param called echo will echo the variable back.
set varname=%~1
set value=%~2
set %varname%=%value%
if "%~3" == "echo" echo %varname%=%value%
if "%~3" == "required" (
  if "%value%" == "" echo Missing %varname% parameter & set fatalerror=on
)
goto :eof

:quoteinquote
:: Description: Resolves single quotes withing double quotes. Surrounding double quotes dissapea, singles be come doubles.
:: Class: command - internal - parameter manipulation
:: Required parameters:
:: varname
:: paramstring
set varname=%~1
set paramstring=%~2
if defined paramstring set %varname%=%paramstring:'="%
goto :eof

:startfile
:: depreciated use  inputfile
:inputfile
:: Description: Sets the starting file of a serial tasklist, by assigning it to the var outfile
:: Class: command - variable
:: Optional preset variables: 2
:: writebat
:: projectbat
:: Required parameters: 1
:: outfile
:: Added handling so that a preset var %writebat%, will cause the item to be written to a batch file
set outfile=%~1
if "%writebat%" == "yes" echo set outfile=%~1 >>%projectbat%
goto :eof


:setdatetime
:: Description: generate a XML style date and time similar to gedattime
:: Class: command - internal - date - time
:: Required parameters:
::echo Setup log
set actno=1
set tenhour=%time:~0,1%
if "%tenhour%" == " " (
set myhour=0%time:~1,1%
) else (
set myhour=%time:~0,2%
)
set datetime=%date:~-4,4%-%date:~-7,2%-%date:~-10,2%T%myhour%%time:~3,2%%time:~6,2%
goto :eof

rem Loops ======================================================================

:serialtasks
:looptasks
:: Description: loop through tasks acording to %list%
:: Class: command
:: Required prerequisite variables: 3
:: comment
:: list
:: Required parameters: 1
:: tasklistfile
if defined masterdebug call :funcdebugstart looptasks
	set tasklistfile=%~1
	if "%~2" == "" (
		if "%list%" neq "" (
		set list=%list%
	) else (
		echo No list set. Loop failure.
		pause
		exit /b
	)
) else (
	set list=%~2
)
if "%~3" == "" (
	if "%comment%" neq "" (
		set comment=%comment%
	) else (
		echo No comment set. Loop failure.
		pause
		exit /b
	)
) else (
	  set comment=%~3
)
echo "%comment%"
FOR /F %%s IN (%list%) DO call :tasklist "%tasklistfile%" %%s
set list=
set comment=
echo =====^> end looptasks
if defined masterdebug call :funcdebugend
goto:eof

:loop
:: Description: a general loop, review parametes before using, other dedcated loops may be easier to use.
:: Calss: command - loop
:: Required preset variables:
:: looptype - Can be any of these: string, listinfile or command
:: comment
:: string or file or command
:: function
:: Optional preset variables:
:: foroptions - eg "eol=; tokens=2,3* delims=, slip=10"
:: Required functions:
:: tasklist
if defined masterdebug call :funcdebugstart loop
if defined echoloopcomment echo "%comment%"
if "%looptype%" == "" echo looptype not defined, skipping this task& exit /b
rem the command type may be used to process files from a command like: dir /b *.txt
if "%looptype%" == "command" set command=%command:'="%
if "%looptype%" == "command" (
	  FOR /F %%s IN ('%command%') DO call :%function% "%%s"
)
rem the listinfile type may be used to process the lines of a file.
if "%looptype%" == "listinfilespaced" (
	  FOR /F "%foroptions%" %%s IN (%file%) DO call :%function% "%%s" %%t %%u
)
rem the listinfile type may be used to process the lines of a file.
if "%looptype%" == "listinfile" (
	  FOR /F "eol=# delims=" %%s IN (%file%) DO call :%function% "%%s"
)
rem the string type is used to process a space sepparated string.
if "%looptype%" == "string" (
	  FOR /F "%foroptions%" %%s IN (%string%) DO call :%function% "%%s"
)
rem clear function and tasklist variables in case of later use.
set function=
set tasks=
if defined masterdebug call :funcdebugend
goto:eof

:loopcommand
:: Description: loops through a list created from a command like dir and passes that as a param to a tasklist.
:: Class: command - loop
:: Required parameters:
:: comment
:: list
:: action
:: Parameter note: Either preset or command parameters can be used
if defined masterdebug call :funcdebugstart loopcommand
if "%~1" neq "" set action=%~1
if "%~2" neq "" set list=%~2
if "%~3" neq "" set comment=%~3
echo "%comment%"
::echo on
FOR /F %%s IN ('%list%') DO call :%action% "%%s"
set action=
set list=
set comment=
if defined masterdebug call :funcdebugend
goto:eof

:loopfileset
:: Description: Loops through a list of files supplied by a file.
:: Class: command - loop
:: Required parameters:
:: action
:: fileset
:: comment
:: Parameter note: Either preset or command parameters can be used
if defined masterdebug call :funcdebugstart loopfileset
if "%~1" neq "" set action=%~1
if "%~2" neq "" set fileset=%~2
if "%~3" neq "" set comment=%~3
echo %comment%
::echo on
FOR /F %%s IN (%fileset%) DO call :%action% %%s
set action=
set fileset=
set comment=
if defined masterdebug call :funcdebugend
goto:eof

:loopstring
:: Description: Loops through a list supplied in a string.
:: Class: command - loop
:: Required parameters:
:: comment
:: string
:: action
:: Parameter note: Either preset or command parameters can be used
if defined masterdebug call :funcdebugstart loopstring
if "%~1" neq "" set action=%~1
if "%~2" neq "" set string=%~2
if "%~3" neq "" set comment=%~3
echo %comment%
::echo on
FOR %%s IN (%string%) DO call :%action% %%s
rem clear variables
set action=
set string=
set comment=
if defined masterdebug call :funcdebugend
goto:eof

:runloop
:: Description: run loop with parameters
:: Class: command - loop - depreciated
set looptype=%~1
set action=%~2
set string=%~3
set fileset=%~3
set list=%~3
set comment=%~4
set string=%string:'="%
call :%looptype%
goto :eof


:spinoffproject
:: Description: spinofff a project from whole build system
:: Class: command - condition
:: Required parameters: 0
:: Created: 2013-08-10
:: depreciated doing with tasks file
set copytext=%projectpath%\logs\copyresources*.txt
set copybat=%projectpath%\logs\copyresources.cmd
if exist "%copytext%" del "%copytext%"
if exist "%copybat%" del "%copybat%"
echo :: vimod-spinoff-project generated file>>"%copybat%"
if "%~1" == "" (
set outpath=C:\vimod-spinoff-project
) else (
set outpath=%~1
)
if "%~2" neq "" set projectpath=%~2

dir /a-d/b "%projectpath%\*.*">"%projectpath%\logs\files.txt"
call :xslt vimod-spinoff-project "projectpath='%projectpath%' outpath='%outpath%' projfilelist='%projectpath%\logs\files.txt'" scripts/xslt/blank.xml "%projectpath%\logs\spin-off-project-report.txt"
FOR /L %%n IN (0,1,100) DO call :joinfile %%n
if exist "%copybat%" call "%copybat%"
::call :command xcopy "'%projectpath%\*.*' '%outpath%"
goto :eof



:ifexist
:: Description: Tests if file exists and takes prescribed if it does
:: Class: command - condition
:: Required parameters: 2-3
:: testfile
:: action - xcopy, copy, del, call, command, func or fatal
:: Optional parameters:
:: outfileif - required (copy, xcopy)
:: Func - required (func)
:: switches
if defined masterdebug call :funcdebugstart ifexist
set testfile=%~1
set action=%~2
set outfileif=%~3
set switches=%~4
set func=%~4

if exist "%testfile%" (
  rem say what will happen
  if "%action%" == "xcopy" echo %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "copy" echo %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "move" echo %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "del" echo %action% "%testfile%"
  if "%action%" == "call" echo %action% "%testfile%"
  if "%action%" == "func" echo call :%func% "%testfile%"
  rem now do what was said
  if "%action%" == "xcopy"  %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "copy" %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "move" %action% %switches% "%testfile%" "%outfileif%"
  if "%action%" == "del" %action% "%testfile%"
  if "%action%" == "call" %action% "%testfile%"
  if "%action%" == "func" call :%func% "%testfile%"
  if "%action%" == "tasklist" call :%action% "%testfile%"
) else (
  echo %testfile% was not found to %action%
)
if defined masterdebug call :funcdebugend
goto :eof

:ifnotexist
:: Description: If a file or folder do not exist, then performs an action.
:: Required parameters: 3
:: testfile
:: action - xcopy, copy, del, call, command, func or fatal
:: infileif or func or command or message
:: Optional parameters: 1
:: switches
:: Usage copy: ;ifnotexist testfile copy infileif [switches]
:: Usage xcopy: ;ifnotexist testfile copy infileif [switches]
:: Usage del: ;ifnotexist testfile del infileif [switches]
:: Usage call: ;ifnotexist testfile call infileif
if defined masterdebug call :funcdebugstart ifnotexist
set testfile=%~1
set action=%~2
set infileif=%~3
set func=%~3
set command=%~3
set message=%~3
set switches=%~4
if not exist  "%testfile%" (
if "%action%" == "xcopy" %action% %switches% "%infileif%" "%testfile%"& call :echolog "File not found! %message%"
if "%action%" == "copy" %action% %switches% "%infileif%" "%testfile%"& call :echolog "File not found! %message%"
if "%action%" == "del" %action% "%infileif%" & call :echolog "File not found! %message%"
if "%action%" == "call" %action% "%infileif%"& call :echolog "File not found! %message%"
if "%action%" == "command" %command%& call :echolog "File not found! %message%"
if "%action%" == "func" call :%func% "%testfile%"& call :echolog "File not found! %message%"
if "%action%" == "fatal" (
call :echolog "File not found! %message%"
echo The script will end.
echo.
pause
exit /b
)
if "%action%" == "report" call :echolog "File not found! %message%"
)
if defined masterdebug call :funcdebugend
goto :eof

:echolog
:: Description: echoes a message to log file and to screen
:: Class: command - internal
:: Required preset variables: 1
:: projectlog
:: Required parameters: 1
:: message
if defined masterdebug call :funcdebugstart echolog
set message=%~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
if defined echoecholog echo %message%
echo %message% >>%projectlog%
set message=
if defined masterdebug call :funcdebugend
goto :eof

:userinputvar
:: Description: provides method to interactively input a variable
:: Class: command - interactive
:: Required parameters: 2
:: varname
:: question
if defined masterdebug call :funcdebugstart userinputvar
set varname=%~1
set question=%~2
set /P %varname%=%question%:
if defined masterdebug call :funcdebugend
goto :eof



:copyresources
:: Description: Copies resources from resource folder to traget folder
:: Class: command - project setup
:: Required parameters:
:: resourcename
:: resourcetarget
:: 2013-08-15
set resourcename=%~1
set resourcetarget=%~2
if not defined resourcename echo resourcename not defined
if not defined resourcetarget echo resourcetarget not defined
xcopy /e/y "%resourcename%" "%resourcetarget%"
goto :eof

:requiredparam
:: Description: Ensure parameter is present
:: Required parameters:
::
got :eof


:variableslist
:: Description: Handles variables list supplied in a file.
:: Class: command - loop
:: Optional preset variables:
:: selvalue - used to set a value equals itself ie set ccw32=ccw32 from just ccw32. Used for path tools
:: echovariableslist
:: echoeachvariablelistitem
:: Required parameters:
:: list - a filename with name=value on each line of the file
:: checktype - for use with ifnotexist
:: Required functions:
:: drivepath
:: nameext
:: ifnotexist
if defined echovariableslist echo ==== Processing variable list %~1 ====
set list=%~1
set checktype=%~2
rem make sure testvalue is not set
set testvalue=
FOR /F "eol=# delims== tokens=1,2" %%s IN (%list%) DO (
	set name=
	set val=
	rem selfvalue is set to let a value equal itself like in user_path_installed.tools
	if not defined selfvalue (
	set %%s=%%t
	) else (
	set %%s=%%s
	)
	if defined echoeachvariablelistitem echo %%s=%%t
	if defined checktype (
		call :drivepath %%t
		rem the following tests if the value is a path
		if "%drivepath%" neq "%cd%" (
			rem seems redundant call :nameext %%t
			call :ifnotexist "%%t" %checktype% "%nameext% tool not found in %drivepath%."
			)
		)
	)
if defined selfvalue set selfvalue=
goto :eof


:appendtofile
:: Description: Func to append text to a file
:: Class: command
:: Optional predefined variables:
:: newfile
:: Required parameters:
:: file
:: text
:: quotes
set file=%~1
if not defined file echo file=%file%&goto :eof
set text=%~2
set quotes=%~3
if not defined newfile set newfile=%~4
if defined quotes set text=%text:'="%
if defined newfile (
  echo %text%>%file%
) else (
  echo %text%>>%file%
)
set newfile=
goto :eof

rem UI and Debugging functions ========================================================

:writeuifeedback
:: Description: Produce a menu from a list to allow the user to change default list settings
:: Class: command - internal - menu
:: Usage: call :writeuifeedback list [skiplines]
:: Required parameters:
:: list
:: Optional parameters:
:: skiplines
:: Required functions:
:: menuwriteoption
rem echo on
set list=%~1
set skiplines=%~2
if not defined skiplines set skiplines=1
FOR /F "eol=# tokens=1 skip=%skiplines% delims==" %%i in (%list%) do (
	if defined %%i (
		  set action=var %%i
		  call :menuwriteoption "ON  - Turn off %%i?"
	) else (
		  set action=var %%i on
		  call :menuwriteoption "    - Turn on  %%i?"
	)
)
rem echo off
goto :eof

:funcdebugstart
:: Description: Debug function run at the start of a function
:: Class: command - internal - debug
:: Required preset variables:
:: stacksource
:: stack - created upon first usage
:: Required parameters:
:: newfunc
@echo off
@if defined debugfuncdebugstart @echo on
if defined echodebugmarker @echo +++++++++++++++++++++++++++++++++++++++++ starting func %~1 ++++
set newfunc=%~1
::@echo stacksource=%stacksource%
set /A stacknumb=%stacknumb%+1
if defined debugstack @echo stacknumb=%stacknumb%
set sn%stacknumb%=%newfunc%
@echo off
set test=debug%newfunc%
if defined %test% echo on
@goto :eof

:funcdebugend
:: Description: Debug function run at the end of a function. Resets the calling functions debugging echo state
:: Class: command - internal - debug
:: Required preset variables:
:: stacksource
:: stack
@echo off
if defined echodebugmarker @echo --------------------------------------------- %newfunc% func ended. ----
if defined funcdebugend echo on
set /A stacknumb=%stacknumb%-1
set returnhandle=sn%stacknumb%
call :setvar return %%%returnhandle%%%
set returnfunc=debug%return%
set newfunc=%returnfunc%
if defined echofuncname echo %return%
@echo off
if defined %returnfunc% @echo on
@goto :eof

:removeCommonAtStart
:: Description: loops through two strings and sets new variable representing unique data
:: Class: command - internal
:: Required parameters:
:: name - name of the variable to be returned
:: test - string to have common data removed from start
:: Optional parameters:
:: remove - string if not defined then use %cd% as string.
:: Required functions:
:: removelet
set name=%~1
set test=%~2
set remove=%~3
if not defined remove set remove=%cd%
set endmatch=
FOR /L %%l IN (0,1,100) DO if not defined notequal (
	  call :removelet
	  ) else (
	  exit /b
	  )
goto :eof

:removelet
:: Description: called by removeCommonAtStart to remove one letter from the start of two string variables
:: Class: command - internal
:: Required preset variables:
:: test
:: remove
:: name
set test=%test:~1%
set %name%=%test:~1%
set remove=%remove:~1%
if "%test:~0,1%" neq "%remove:~0,1%" set notequal=on&exit /b
goto :eof

:getline
:: Description: Get a specific line from a file
:: Class: command - internal
:: Required parameters:
:: linetoget
:: file
if defined echogetline echo on
set /A count=%~1-1
if "%count%" == "0" (
	for /f %%i in (%~2) do (
		set getline=%%i
		goto :eof
	)
) else (
	for /f "skip=%count% " %%i in (%~2) do (
		set getline=%%i
		goto :eof
	)
)
@echo off
goto :eof

:menucounted
:: Class: command - internal
set list=%commonmenufolder%\%~1
set menuoptions=
set varvalue=
set valuechosen=
set letters=%lettersmaster%
set menucount=0
echo.
echo %title%
echo.
FOR /F %%i in (%list%) do call :menucountedwriteitem %%i
rem FOR /L %%i in (2,1,35) do call :menucountedwriteline %%i
echo.
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%

:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice

set letters=%lettersmaster%
FOR /L %%i in (1,1,34) DO call :menucountedevaluate %%i

rem call :menuevaluation %%c
if defined echomenucountedvaluechosen echo %valuechosen%
rem echo off
if "%varvalue%" == "set" exit /b
goto :eof

:menucountedwriteitem
:: Class: command - internal
if defined echomenucountedwriteitem echo on
set item=%~1
set let=%letters:~0,1%
set /A menucount=%menucount%+1
echo        %let%. %item%
set letters=%letters:~1%
@echo off
goto :eof

:menucountedwriteline
:: Class: command - internal
if defined endoflist goto :eof
set menucount=%~1
set let=%letters:~0,1%
rem set value%let%=%~1
call :getline %menucount% "%list%"
if "%getline%" == "" set endoflist=eol
if "%getline%" neq "" echo        %let%. %getline%&set getline=
set letters=%letters:~1%
goto :eof


:menucountedevaluate
:: Class: command - internal
if defined varvalue goto :eof
set evalcount=%~1
set let=%letters:~0,1%
IF /I '%Choice%'=='%let%' call :getline %evalcount% "%list%"
IF /I '%Choice%'=='%let%' set varvalue=set
IF /I '%Choice%'=='%let%' set valuechosen=%getline%&set option& exit /b
set letters=%letters:~1%
goto :eof

:ifdefined
:: Description: conditional based on defined variable
:: Class: command - condition
:: Required parameters:
:: test
:: func
:: funcparams - up to 7 aditional
:: Required functions:
:: tasklist
set test=%~1
set func=%~2
rem set func=%func:'="%
set funcparams=%~3
if defined funcparams set funcparams=%funcparams:'="%
if defined %test% call :%func% %funcparams%
goto :eof

:ifnotdefined
:: Description: non-conditional based on defined variable
:: Class: command - condition
:: Required parameters:
:: test
:: func
:: Optional parametes:
:: funcparams
set test=%~1
set func=%~2
set func=%func:'="%
set funcparams=%~3
if defined funcparams set funcparams=%funcparams:'="%
if not defined %test% call :%func% %funcparams%
goto :eof

:ifequal
:: Description: to do something on the basis of two items being equal
:: Required Parameters:
:: equal1
:: equal2
:: func
:: params
set equal1=%~1
set equal2=%~2
set func=%~3
set funcparams=%~4
set funcparams=%funcparams:'="%
if "%equal1%" == "%equal2%" call :%func% %funcparams%
goto :eof

:ifnotequal
:: Description: to do something on the basis of two items being equal
:: Required Parameters:
:: equal1
:: equal2
:: func
:: funcparams
set equal1=%~1
set equal2=%~2
set func=%~3
set funcparams=%~4
if defined funcparams set funcparams=%funcparams:'="%
if "%equal1%" neq "%equal2%" call :%func% %funcparams%
goto :eof



rem shift
rem shift
rem set extraparam=
rem if ""%~1""=="""" goto :ifNotDefinedDoneStart
rem set extraparam='%~1'
rem shift
rem :ifNotDefinedArgs
rem if ""%1""=="""" goto :ifNotDefinedDoneStart
rem set extraparam=%extraparam% '%1'
rem shift
rem goto :ifNotdefinedArgs
rem :ifNotDefinedDoneStart
rem set extraparam=%extraparam:'="%

:externalfunctions
:: Description: non-conditional based on defined variable
:: Class: command - extend - external
:: Required parameters:
:: extcmd
:: function
:: params
:: Required functions:
:: inccount
:: infile
:: outfile
:: before
:: after
call :inccount
set extcmd=%~1
set function=%~2
set params=%~3
call :infile "%~4"
call :outfile "%~5" "%outputdefault%"
set curcommand=call %extcmd% %function% "%params%" "%infile%" "%outfile%"
call :before
%curcommand%
call :after "externalfunctions %function% complete"
goto :eof

:loopdir
:: Description: Loops through all files in a directory
:: Class: command - loop
:: Required functions:
:: action - can be any Vimod-Pub command like i.e. tasklist dothis.tasks
:: extension
:: comment
set action=%~1
set basedir=%~2
echo %~3
FOR /F %%s IN ('dir /b /a:d %basedir%') DO call :%action% "%%s"
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Class:  command - loop
:: Required functions:
:: action - can be any Vimod-Pub command like i.e. tasklist dothis.tasks
:: filespec
:: Optional parameters:
:: comment
set action=%~1
set filespec=%~2
if "%~3" neq "" echo %~3
FOR /F " delims=" %%s IN ('dir /b /a:-d %filespec%') DO call :%action% "%%s"
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Class: command - dos - to file
:: Required parameters:
:: command
:: outfile
:: Required functions:
:: inccount
:: before
:: after
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
if defined echocommandstdout echo on
call :inccount
set command=%~1
set curcommand=%command:'="%
set outfile=%~2
set commandpath=
set commandpath=%~3
set startdir=%cd%
rem set curcommand="%command%"  "%outfile%"
call :before
if defined commandpath cd "%startdir%"
%curcommand% > "%outfile%"
if defined commandpath cd "%startdir%"
call :after "command with stdout %curcommand% complete"
if defined masterdebug call :funcdebugend
goto :eof

:donothing
:menublank
:xvarset
:xinclude
:xarray
:: Description: This is an XSLT instruction to process a paired set as param, dos var not allowed in set.
:: Note: not used by this batch command. The xvarset is a text file that is line separated and = separated. Only a pair can occur on any line.
goto :eof



:getfiledatetime
:: Description: Returns a variable with a files modification date and time in yyyyMMddhhmm  similar to setdatetime
:: Classs: command - internal - date -time
:: Required parameters:
:: varname
:: filedate - (supply the file name and path)
rem echo on
set varname=%~1
set filedate=%~t2
if not exist "%~2" set %varname%=0 &goto :eof
set prehour=%filedate:~11,2%
if "%filedate:~17,2%" == "PM" (
  if "%prehour:~0,1%" == "0"  (
	rem adding 05 + 12 caused error but 5+12 okay
	set dhour=%prehour:~1,1%
	set /A fhour=%prehour:~1,1%+12
  ) else (
	if %prehour% == 12 (
	  rem if noon don't add 12
	  set fhour=12
	) else (
	  set /A fhour=%prehour% + 12
	)
  )
) else (
  set fhour=%prehour%
)
set %varname%=%filedate:~8,2%%filedate:~3,2%%filedate:~0,2%%fhour%%filedate:~14,2%
@echo off
goto :eof

:getdatetime
:: Description: Returns a variable with a files modification date and time in yyyyMMddhhmm  similar to setdatetime
:: Classs: command - internal - date -time
:: Required parameters:
:: varname
:: filedate (supply the file name and path)
set varname=%~1
set %varname%=%date:~-4,4%-%date:~-7,2%-%date:~-10,2%T%time%
goto :eof

:html2xml
:: Description: Convert HTML to xml for post processing as xml. it removes the doctype header.
:: Required parameters:
:: infile
:: Optional Parameters:
:: outfile
call :infile "%~1"
call :outfile "%~2"
set curcommand=call xml fo -H -D "%infile%"
rem set curcommand=call "%tidy5%" -o "%outfile%" "%infile%"
call :before
%curcommand% > "%outfile%"
call :after
goto :eof


:lookup
:: Description: Lookup a value in a file before the = and get value after the =
:: Required parameters:
:: findval
:: datafile
SET findval=%~1
set datafile=%~2
set lookupreturn=
FOR /F "tokens=1,2 delims==" %%i IN (%datafile%) DO @IF %%i EQU %findval% SET lookupreturn=%%j
@echo %lookupreturn%

goto :eof
