@echo off
if "%2" == "" (
set rl=0
) else (
set rl=%2
)
::call :reportlevel %rl%

:main
call :pubvar
set iso=%1
if "%2" neq "" goto :%2
if "%iso%" neq "" goto :projects

:chooselang
call :menu initial.menu "Chooose a language?"
goto :eof


:projects
call pub-var.cmd %iso%
if not exist %cd%\%projectpath%\xml md %cd%\%projectpath%\xml
call %projectpath%\setup\%iso%-var.cmd
call :menu %projectpath%\setup\menu-%iso%.txt "Chooose a project task for %iso% - %langname%"
goto :eof

:commonmenu
rem Used to jump to start from another batch file with a speific menu
if "%iso%" == "" (
set /p iso=Enter the iso code you want to work on:
)
if "%iso%" neq "" call var\%iso%.cmd
if "%iso%" neq "" call pub-var %iso%
call :menu tasks\menu-common.txt "Common tasks for %langname% Projects"
goto :eof

:startmenu
set count=0
set iso=%~2
set menutitle=%~1
set menufile=%~3
set menuname=%~n3
set projectpath=%~4
if "%pcode%" == "" set pcode=%menuname%
if not exist "%menufile%" set menufile=%setuppath%\%menufile%
::if exist "data\%iso%\setup\%menu%" set projectpath=data\%iso%
::if not exist "data\%iso%\setup\%menu%" set projectpath=%~4
::set setuppath=%projectpath%\setup
::if exist %setuppath%\menu-%iso%.cmd call %setuppath%\menu-%iso%.cmd
echo off
call :menu %menufile% "%menutitle% Project"
goto :eof

:menu
set letters=abcdefghijklmnopqrstuvwxyz
::echo off
set menulist=%~1
set title=     %~2
set menuoptions=
echo[
echo %title%
echo[
rem FOR /F "eol=# tokens=1,2,3 delims=;" %%i in (%menulist%) do @echo        %%i. %%j &set option%%i=%%k &call :menuoptions %%i
FOR /F "eol=# tokens=1,2 delims=;" %%i in (%menulist%) do set action=%%j&call :menuwriteoption "%%i"
echo[
echo        X. Exit batch menu
echo[
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%
IF /I '%Choice%'=='x' set iso=&exit /b
:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
FOR /D %%c IN (%menuoptions%) DO call :menueval %%c
goto menu

:menuwriteoption
set let=%letters:~0,1%
set letters=%letters:~1%
@echo        %let%. %~1
set option%let%=%action%
call :menuoptions %let%
goto :eof

:menuoptions
set menuoptions=%menuoptions% %~1
goto :eof

:menueval

:: run through the choices to find a match then calls the selected option
set let=%~1
set option=option%let%
:: /I makes the IF comparison case-insensitive
IF /I '%Choice%'=='%let%' call :%%%option%%%
goto :eof

:setup
set iso=
if "%~1" == "" (
SET proj=
SET /P Choice=Enter iso code:
) else (
set proj=%1
)

set basepath=%cd%

echo =============================================
echo Setup %proj% variables
if exist var\%proj%.cmd (
call var\%proj%.cmd
) else (
call :novarfile
)
mkdir log
set logtemp=log
::call build-func setuplog
call :dictvar
call :checks
set logtemp=
echo --------------------------------------------
goto:eof

:catcherrors
set %~2=%~1
if  %errorlevel% neq 0 echo Big Problem with %~3, the errorlevel set to %errorlevel%
if  %errorlevel% neq 0 pause
goto:eof

:pubvar
:: some localization may be needed for these variables.
:: Folder variables
set basepath=%cd%
set cctpath=scripts\cct
set xsltpath=xslt
set localhostpath=%htmlpath%
set fsprojectpath=%projectpath:\=/%
set dictpath=D:\All-SIL-PLB\WebMaster\Publishing\Dict-svn
set xmlsource=%iso%-a.xml
set proptail=setup\properties-tail.txt
set propmid=setup\properties-middle.txt
:: Tools
:: all important tools are on the path with the exception of Saxon9
:: if not on path set up like the following
::set binmay=C:\[your\path]\binmay.exe
set java=java
set saxon9=C:\Program Files (x86)\Kernow\lib\saxon9.jar
set xml=xml
set binmay=binmay
set ccw32=ccw32
set csplit=csplit
set sed=sed
set sort=sort
set uniq=uniq
set prince="C:\Program Files (x86)\Prince\engine\bin\Prince.exe"
set wkhtmltopdf="C:\Program Files (x86)\wkhtmltopdf\wkhtmltopdf.exe"
set pandoc="C:\Program Files (x86)\Pandoc\bin\pandoc.exe"
set fopjar="C:\Program Files (x86)\fop\build\fop.jar"
set fop="C:\Program Files (x86)\fop\fop.bat"
::other
set cctparam=-u -b -q -n
set varfile=setup\default-setup-%type%.TXT
set space=0
goto:eof

:checks
:: create directories if not exist
echo[
echo Running checks for neccessary files and directoriesS
echo   basepath = %basepath%
echo   projectpath = %projectpath%
::call :checkdir %projectpath%\log
call :checkdir %projectpath%\checks
call :checkdir %projectpath%\checks\fields\
call :checkdir %projectpath%\xml
call :checkdir %projectpath%\setup

:: make localhost path
::call :checkdir %localhostpath%

:: make localhost subpaths
::call :checkdir %localhostpath%\index
::call :checkdir %localhostpath%\lexicon
::call :checkdir %localhostpath%\common

:: make sure there are setup files available
::call :ifnotcopy "%basepath%\%projectpath%\setup\dictionary.txt" "%basepath%\setup\default-plb\*.*" "%basepath%\%projectpath%\setup"
::call :ifnotcopy  "%basepath%\%cctpath%\%iso%.cct" "%cctpath%\iso.cct"

:: copy localhost files   \index.html
::call :ifnotcopy "%localhostpath%\index.html" "shells\ver2\index.html"
::call :ifnotcopy "%localhostpath%\common\find.html" "shells\ver2\common\*.*" "%localhostpath%\common"
::call :ifnotcopy "%projectpath%\%iso%.xslt" "%xsltpath%\iso.xslt"

:: Generate langs.js file
::set outfile=%localhostpath%\common\langs.js
::if not exist "%outfile%" (
::call build-func buildlangjs
::echo build-func buildlangjs
::echo build-func buildlangjs>>%logfile%
::) else (
::echo . . . Found! langs.js
::)

set gt=^>
set lt=^<
goto:eof

:novarfile
call:samplevarfile
call:clearlangvar
SET /P iso=Enter iso code:
SET /P type=Enter markup type (usually plb):
SET /P projectpath=Enter project relative path (usually data\%iso%):
SET /P source=Enter source file name without path:
SET /P langname=Enter vernacular language name:
SET /P natlang=Enter National language name if used/needed:
SET /P reglang=Enter Regional language name if used/needed:
SET /P reg2lang=Enter second Regional language name if used/needed:
SET /P reg3lang=Enter third Regional language name if used/needed:
SET /P labelname=Enter name to use to tag entries ie Sinama for Sama Sibutu:
SET /P separator=Enter separator for multiple entry fields:
SET /P intropage=Enter filename of intro page (usually works-iso.html):
SET /P title=Enter filename of intro page (usually works-iso.html):
SET /P htmlpath=Enter HTML output path d;\path:D:\All-SIL-PLB\WebMaster\plb-www\works\%iso%
echo Custom collation settings. use defaults
SET /P set collationname=Leave blank for default collation:
SET /P set translateaccents=Leave blank for default (yes)
SET /P set customfind=Find like ng to change to eng for sorting
SET /P set customreplace=Replace string for sorting
set write=
set /P write=Do you want to write this information to a file for reuse? y or n:
if "%write%"=="y" call:writevarfile
call:eof

:writevarfile
set outfile=var\%iso%.cmd
echo :%iso%>%outfile%
echo set iso=%iso%>>%outfile%
echo set type=%type%>>%outfile%
echo set projectpath=%projectpath%>>%outfile%
echo set source=%source%>>%outfile%
echo set langname=%langname%>>%outfile%
echo set natlang=%natlang%>>%outfile%
echo set reglang=%reglang%>>%outfile%
echo set reg2lang=%reg2lang%>>%outfile%
echo set reg3lang=%reg3lang%>>%outfile%
echo set labelname=%labelname%>>%outfile%
echo set splitseparator=%splitseparator%>>%outfile%
echo set intropage=%intropage%>>%outfile%
echo set title=%title%>>%outfile%
echo set htmlpath=%htmlpath%>>%outfile%
echo :: collation settings for costom collation>>%outfile%
echo set collationname=%collationname%>>%outfile%
echo set translateaccents=%translateaccents%>>%outfile%
echo set customfind=%customfind%>>%outfile%
echo set customreplace=%customreplace%>>%outfile%
goto:eof

:clearlangvar
SET iso=
SET type=
SET projectpath=
SET source=
SET langname=
SET natlang=
SET reglang=
SET reg2lang=
SET reg3lang=
SET labelname=
SET splitseparator=
SET intropage=
goto:eof

:samplevarfile
echo  var\%proj%.cmd does not exist.
echo Create this file in the following form
echo :iso
echo set iso=iso
echo set type=plb
echo set projectpath=data\iso
echo set source=iso-di.txt
echo set langname=Tagbanwa
echo set natlang=
echo set reglang=
echo set labelname=Tagbanwa
echo set splitseparator=;
echo set intropage=works-iso.html
echo set title=Ibatan - English Dictionary
echo set htmlpath=D:\All-SIL-PLB\WebMaster\plb-www\online\%iso%\dict6
echo :: collation settings for costom collation
echo set collationname=
echo set translateaccents=
echo set customfind=
echo set customreplace=
goto:eof


echo[
goto:eof

:setupfile
set report=Setup file %~1 copied if needed
%report2%echo copy "%basepath%\setup\default-%type%\%~1" "%basepath%\%projectpath%\setup"
copy "%basepath%\setup\default-%type%\%~1" "%basepath%\%projectpath%\setup"
goto:eof

:checkdir
set report=Checking dir %~1
if exist "%~1"  (
		  %report1%echo . . . Found! %~1
	) else (
		  %report1%echo . . . not found. %~1
		  mkdir "%~1"
		  %report1%echo mkdir "%~1"
)
goto:eof


:debugsettings
:: Adjust report back levels
:: Lev1-5 allows adjusting globally what is echoed back while processing
:: Set to :: to turn off reporting levels if all is going well.
:: Leave lev1 blank unless on debug level 0
set lev1=
:: Leave lev2 blank for good general reporting for debuglevel 1
set lev2=
:: Change to blank if you want more detailed progress reporting.
set lev3=
set lev4=::
set lev5=::
goto:eof

:getiso
SET proj=
SET /P Choice=Enter iso code:
goto:eof



:ifnotcopy
if not exist "%~1" (
	if "%~3" == "" (
		copy %~2 %~1
		%report1%echo copy %~2 %~1
		%report1%echo copy %~2 %~1>>%logfile%
	) else (
		copy %~2 %~3
		%report1%echo copy %~2 %~3
		%report1%echo copy %~2 %~3>>%logfile%
	)
) else (
	  %report1%echo . . . Found! %~1
)
goto :eof

:tasklist
::call build-func log "===== Starting %~2 from %~nx1 "
:: checks if the list is in the default directory, if it is it used that file, if not then it uses the given list
set list=%~1

if exist "%setuppath%\%list%" (
set tasks=%setuppath%\%list%
) else   (
set tasks=%list%
)
set pcode=%~2
set source=%projectpath%\%~3
set count=0
if not exist %tasks% (

echo tasks=%tasks%
echo Error tasklist not found &pause
)
FOR /F "eol=# tokens=1,2,3,4,5,6,7,8,9,10 delims= " %%i in (%tasks%) do call :%%i %%j %%k %%l %%m %%n %%o %%p %%q
goto:eof

:process
call :tasklist %tasks% "Project specific tasks"
goto :eof

:validate
%xml% val -e "%outfile%"
goto :eof

:xslt
call :inccount
set script=%xsltpath%\%~1.xslt
set param=
set paramapp=%~2
if "%paramapp%" neq "" set param=%paramapp:'="%
call :infile "%~3"
call :outfile "%~4" "%basepath%\%projectpath%\xml\%pcode%-%writecount%-%~1.xml"

call :before
%java%  -jar "%saxon9%"   -o "%outfile%" "%infile%" "%script%" %param%
if not exist %outfile% echo %java%  -jar "%saxon9%"   -o "%outfile%" "%infile%" "%script%" %param%
call :after "XSLT transformation"
goto :eof

:settasktype
set settasktype=%~1
goto :eof


:setoutfile
set outfile=%~1
goto:eof

:before
::call :prereport
if exist "%outfile%" call :nameext "%outfile%"
if exist "%outfile%.pre.txt" (
del "%outfile%.pre.txt"
rem echo        deleted "%nameext%.pre.txt"
)
if exist "%outfile%" (
ren "%outfile%" "%nameext%.pre.txt"
rem echo        renamed "%nameext%" to --} "%nameext%.pre.txt"

)
goto :eof

:after
if not exist "%outfile%" (
	set errorlevel=1
	echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	echo %~1 failed to create %nameext%.
	if exist "%outfile%.pre.txt" (
		%report3%echo ren "%outfile%.pre.txt" "%nameext%"
		ren "%outfile%.pre.txt" "%nameext%"
		%report3%echo Previously existing %nameext% restored.
		%report3%echo The following processes will work on the previous version.
		echo .
	)
) else (
echo[
echo %writecount% Created:   %nameext%
echo[
if exist "%outfile%.pre.txt" del "%outfile%.pre.txt"
)
goto :eof

:nameext
set nameext="%~nx1"
::echo %nameext%
goto:eof

:file2uri
set uri%~2=
set pathfile=%~1
set numb=%~2
set uri%numb%=file:///%pathfile:\=/%
set return=file:///%pathfile:\=/%
%report1%echo       uri%numb%=%return:~0,25% . . . %return:~-30%
::echo       uri%numb%=%return%>>%logfile%
goto:eof

:inccount
set /A count=%count%+1
set writecount=%count%
if %count% lss 10 set writecount=%space%%count%
goto :eof

:setvar
set %~1=%~2
goto :eof

:reportlevel
if %~1 lss 1 set reoprt1=::
if %~1 lss 2 set reoprt2=::
if %~1 lss 3 set reoprt3=::
if %~1 lss 4 set reoprt4=::
if %~1 lss 5 set reoprt5=::
goto :eof

:manyparam
if "%firstmany%" == "" (
set param=%param% %~1
) else (
set firstmany=
set param=%~1
)
goto :eof

:manyparamcmd
set param=%param:'="%
echo "%~1" %param%
"%~1"  %param%
goto :eof



:infile
if "%~1" == "" (
set infile=%outfile%
) else (
set infile=%~1
)
goto :eof

:outfile
if "%~1" == "" (
set outfile=%~2
) else (
set outfile=%~1
)
goto :eof

:options
if "%~1" == "" (
set options=%~2
) else (
set options=%~1
)
goto :eof

:script
if "%~1" == "" (
set script=
) else (
set script=%~1
)
goto :eof

:xml2input
:: created 2012-08-29 by Ian McQuay
set report=Created Dictionary_input.txt for %size%.
set infile=data\%iso%\%xmlsource%
set outfile=data\%iso%\%langs%\%size%\Dictionary_input.txt
set script=xslt\%type%2dfm-%size%.xslt
set param=langs=%langs% size=%size%
call :xslt
goto :eof

:xml2dfmsetup
@echo off
:: ensure dir exists and input file is ready
call :checkdir "data\%iso%"
call :checkdir "data\%iso%\%langs%"
call :checkdir "data\%iso%\%langs%\%size%"
@echo off
call :ifnotcopy "data\%iso%\%xmlsource%" "%dictpath%\%iso%\xml\%xmlsource%"
call :ifnotdo "data\%iso%\%langs%\%size%\DictionaryForMIDs.properties" :makeproperties
@echo off
goto :eof

:makeproperties
@echo off
echo properties file not found.
set propfile=data\%iso%\%langs%\%size%\DictionaryForMIDs.properties
echo infoText: %title%. %copyright%. version^: %version% %date:~-4,4%-%date:~-7,2%-%date:~-10,2% %dicturi%>%propfile%
echo dictionaryAbbreviation^: %iso%-%size%>>%propfile%
echo numberOfAvailableLanguages^: %langs% >>%propfile%
echo.>>%propfile%
echo language1DisplayText: %langname%>>%propfile%
echo language2DisplayText: English>>%propfile%
if "%langs%" GEQ "3" echo language3DisplayText^: %langname3% Index>>%propfile%
if "%langs%" GEQ "4" echo language4DisplayText^: %langname4% Index>>%propfile%
if "%langs%" GEQ "5" echo language5DisplayText^: %langname5% Index>>%propfile%
echo.>>%propfile%
echo language1FilePostfix^: %iso%>>%propfile%
echo language2FilePostfix^: eng>>%propfile%
if "%langs%" GEQ "3" echo language3FilePostfix^: %iso3%>>%propfile%
if "%langs%" GEQ "4" echo language4FilePostfix^: %iso4%>>%propfile%
if "%langs%" GEQ "5" echo language5FilePostfix^: %iso5%>>%propfile%
echo.>>%propfile%
FOR /L %%n IN (1,1,%langs%) DO echo language%%nIsSearchable: true>>%propfile%
echo.>>%propfile%
FOR /L %%n IN (1,1,%langs%) DO echo language%%nGenerateIndex: true>>%propfile%
echo.>>%propfile%
FOR /L %%n IN (1,1,%langs%) DO echo  language%%nHasSeparateDictionaryFile: false>>%propfile%
echo.>>%propfile%

FOR /F "delims=/" %%s IN (%propmid%) DO echo %%s>>%propfile%
echo.>>%propfile%

FOR /L %%n IN (1,1,%langs%) DO echo  language%%nDictionaryUpdateClassName: de.kugihan.dictionaryformids.dictgen.dictionaryupdate.DictionaryUpdate>>%propfile%
echo.>>%propfile%

FOR /L %%n IN (1,1,%langs%) DO echo  language%%nNormationClassName: de.kugihan.dictionaryformids.translation.normation.NormationEng>>%propfile%
echo.>>%propfile%

if "%size%" neq "wl" FOR /F "delims=/" %%s IN (%proptail%) DO echo %%s>>%propfile%
echo Properties file created here: data\%iso%\%langs%\%size%\DictionaryForMIDs.properties
echo Edit it if you wish.
echo.
@echo off
goto :eof

:ifnotdo
if not exist %~1 (
	  echo Missing %~1
	  echo call %~2
	  call %~2
) else (
	  echo . . . Found! %~1
)
goto :eof

:buildjar
echo errorlevel=%errorlevel%
:: run some checks of directories and files
if not exist "data\%iso%\%langs%\%size%\DictionaryForMIDs.properties" set message=DictionaryForMIDs.properties file is missing! Please put it into the subdirectory data\%iso%\%langs%\%size%. &goto:exitmessage
if not exist "data\%iso%\%langs%\%size%\Dictionary_input.txt" set message=Dictionary_input.txt file is missing! Please put it into the subdirectory data\%iso%\%langs%\%size%.  &goto:exitmessage

call :checkdir  "data\%iso%\%langs%\%size%\dictionary"
call :checkdir  "data\%iso%\%langs%\%size%\JAR"
if exist "data\%iso%\%langs%\%size%\dictionary\*.*" del /s /q "data\%iso%\%langs%\%size%\dictionary\*.*"
if exist "data\%iso%\%langs%\%size%\JAR\*.jar" del /s /q "data\%iso%\%langs%\%size%\JAR\*.jar"
if exist "data\%iso%\%langs%\%size%\JAR\*.jad" del /s /q "data\%iso%\%langs%\%size%\JAR\*.jad"

:: =============================================================================
:: Make dict files from source files
echo Commandline: java -jar "Tools\DictionaryGeneration.jar" "data\%iso%\%langs%\%size%\Dictionary_input.txt" "data\%iso%\%langs%\%size%\dictionary" "data/%iso%/%langs%/%size%"
java -jar "Tools\DictionaryGeneration.jar" "data\%iso%\%langs%\%size%\Dictionary_input.txt" "data\%iso%\%langs%\%size%\dictionary" "data/%iso%/%langs%/%size%"
echo errorlevel=%errorlevel%


echo.
echo If your screen finished with "Complete", then the indexes were created OK.
echo If you see anything else, then read the error message to fix the problem.
echo.
call :catcherrors %errorlevel% indexerror DictionaryGeneration
:: catch erros does not work as the errorlevel is not set yet by DictionaryGeneration.jar
:: the folloiwing two lines try and catch the error.
if not exist "data\%iso%\%langs%\%size%\dictionary\DictionaryForMIDs.properties" call:catcherrors 1 indexerror "DictionaryGeneration files. A key file is missing.""
if not exist "data\%iso%\%langs%\%size%\dictionary\directory1.csv" call:catcherrors 1 indexerror "DictionaryGeneration files. A key file is missing.""
::pause

:: =============================================================================
:: make Jar from created dictionaary files
echo Commandline: java -jar "Tools\JarCreator.jar" "data\%iso%\%langs%\%size%\dictionary" "Tools" "data\%iso%\%langs%\%size%\JAR"
java -jar "Tools\JarCreator.jar" "data\%iso%\%langs%\%size%\dictionary" "Tools" "data\%iso%\%langs%\%size%\JAR"

call:catcherrors %errorlevel% jarerror "JarCreation"

echo.
echo.
if  %errorlevel% == 0 echo ZZZ: dictionaryAbbreviation  ^<-- appears above. That is a correct finish.
if  %errorlevel% == 0 echo.
if  %errorlevel% == 0 echo JarCreation succeeded!!
if  %errorlevel% neq 0 echo Your screen did not finished with "ZZZ: DictionaryAbbreviation" above.
if  %errorlevel% neq 0 echo.
if  %errorlevel% neq 0 echo Read the error message to fix the problem (if you understand Java).
echo.
::pause
:: added by Ian to move the Jar files to a unique place
if not exist "data\%iso%\%langs%\%size%\JAR\" call:catcherrors %errorlevel% no JAR directory
copy *.txt  "data\%iso%\%langs%\%size%\JAR\"
copy data\%iso%\*.txt  "data\%iso%\%langs%\%size%\JAR\"
call:catcherrors %errorlevel% copyerror "copying of files"

ren  data\%iso%\%langs%\%size%\JAR\*.jar  dfm-%iso%-%size%-%langs%lang.jar
ren  data\%iso%\%langs%\%size%\JAR\*.jad  dfm-%iso%-%size%-%langs%lang.jad
"%zip%" a -tzip "dfm-%iso%-%size%-%langs%lang.zip" "data\%iso%\%langs%\%size%\JAR\*"
move dfm-%iso%-%size%-%langs%lang.zip zip\

echo.
echo      ===== Build Report =====
echo DictionaryGeneration error set to: %indexerror%
echo JarCreator error set to          : %jarerror%
echo File Copy error set to           : %copyerror%
::echo Copy 2 error set to     : %copy2error%
::echo Move error set to       : %moveerror%
echo.

goto :eof

:setuplog
echo Setup log
set actno=1
set tenhour=%time:~0,1%
if "%tenhour%" == " " (
set myhour=0%time:~1,1%
) else (
set myhour=%time:~0,2%
)
if "%logtemp%" == "log" (
set logfile=%basepath%\%logtemp%\log-%date:~-4,4%-%date:~-7,2%-%date:~-10,2%T%myhour%%time:~3,2%%time:~6,2%.txt
) else (
set logfile=%basepath%\%projectpath%\log\log-%date:~-4,4%-%date:~-7,2%-%date:~-10,2%T%myhour%%time:~3,2%%time:~6,2%.txt
)
echo Starting %time% %date% ======================================>>%logfile%
goto:eof

:done