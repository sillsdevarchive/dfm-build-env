:: DictionaryForMIDs Setting up a new dictionary
:: Batch file to build a new
:: this bat file was modified fromthe original so that many dictionaries could be built in different sub-directories.
:: modified by Ian McQuay 2011-09-26, 2012-08-29, 2012-08-31T10:48:16
:: added parameterized sub directory handling to make different dicts in separate directories ie by iso code
:: added better error handling.  Only stops on errors
:: added final report
:: added some copying files (copies: readme.txt, copying.txt and version.txt)
:: added a check to see if subdirectory entered as a parameter.
:: setup now only deletes existing files not whole directories. This was causing problems on evey second run.
:: setup now only tries to make the "dictionary" and "jar" subdirectiories if they don't exist.
:: expected parameters dfm iso [full|mid|small|wl]
:: adding ability to handle lift input
:setuptasks
echo off
set iso=%1
if [%iso%]==[] call :get_input iso "Type ISO code of the dictionary to create then press Enter"
::if "%~1" == "" (
::set size=full
::) else (
::set size=%~2
::)
call :checkdir log
call :var
call :setuplog
::call :isovar
call :ifnotdo "%projvarfile%" "call :makeisocmd"
call %projvarfile%
if "%langs%" == "" echo No %langs% variable definded, check your %iso%.cmd file for "set langs=2"& exit /b
call :menu1
goto :eof

:menu1
echo off
echo %time%
::set menuname=menu1
::cls
echo.
echo     DictionaryForMids multi Project and multi size builder tool
echo.
echo        Choose a task  for ISO - %iso% - %langname% Languages=%langs%
call :menuline a :xml2dfmsetup "Make minimal wordlist DFM source from xml file" size %wl%
call :menuline b :buildjar "Make minimal wordlist dictionary JAR" size %wl%
echo.

call :menuline c :xml2dfmsetup "Make small dict (no examples) DFM source from xml file" size %min%
call :menuline d :buildjar "Make small dictionary (no examples) JAR" size %min%
echo.
call :menuline e :xml2dfmsetup "Make medium sized (no index of vern example) DFM source from xml file" size %mid%
call :menuline f :buildjar "Make mid sized dictionary (no index of vern example) JAR" size %mid%
echo.

call :menuline g :xml2dfmsetup "Make full sized DFM source from xml file" size %full%
call :menuline h :buildjar "Make full dictionary JAR" size %full%
echo.
echo        Q. Exit batch menu and command window
echo        X. Exit batch menu
echo.
:: The menuoptions variable reflects what is in the letter choices above.
set menuoptions=a b c d e f g h
call :menuchoice
if '%choice%' == 'q' exit %errorlevel%
if '%choice%' == 'x' exit /b %errorlevel%
goto :menu1

:ifnotexisterror
set testfile=%~1
set message=%~2
echo.
echo %message%
echo %message%>>%logfile%
echo.
if "%~3" == "fatal" (
echo The script will end.
echo.
pause
exit /b
)
pause
goto :eof

:ifexistdel
set testfile=%~1
if exist "%testfile%" del /s /q "%testfile%"
goto :eof


:buildjar
set indexerror=0
:: run some checks of directories and files
call :ifnotexiterror "data\%iso%\%langs%\%size%\DictionaryForMIDs.properties" "DictionaryForMIDs.properties file is missing! Please put it into the subdirectory data\%iso%\%langs%\%size%." fatal
call :ifnotexiterror "data\%iso%\%langs%\%size%\Dictionary_input.txt" "Dictionary_input.txt file is missing! Please put it into the subdirectory data\%iso%\%langs%\%size%." fatal
call :checkdir "data\%iso%\%langs%\%size%\dictionary\"
call :checkdir "data\%iso%\%langs%\%size%\JAR\"
call :ifexistdel "data\%iso%\%langs%\%size%\dictionary\*.*"
call :ifexistdel "data\%iso%\%langs%\%size%\JAR\*.jar"
call :ifexistdel "data\%iso%\%langs%\%size%\JAR\*.jad"
call :ifnotcopy "data\%iso%\%langs%\%size%\dictionary\DictionaryForMIDs.properties" "data\%iso%\%langs%\%size%\DictionaryForMIDs.properties"

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
copy data\%iso%\copyright.txt  "data\%iso%\%langs%\%size%\JAR\"
call:catcherrors %errorlevel% copyerror "copying of files"

ren  data\%iso%\%langs%\%size%\JAR\*.jar  dfm-%iso%-%size%-%langs%lang.jar
ren  data\%iso%\%langs%\%size%\JAR\*.jad  dfm-%iso%-%size%-%langs%lang.jad

:: Zip file creation
set zipfile=%zipoutdir%\dfm-%iso%-%size%-%langs%lang.zip
if exist "%zipfile%" sel "%zipfile%"
set basepath=%cd%
cd "%cd%\data\%iso%\%langs%\%size%\JAR"
"%zip%" a -tzip "%zipfile%" "*"
::move dfm-%iso%-%size%-%langs%lang.zip \
call :ifnotdo "%zipfile%" "set ziperror=1"
cd "%basepath%"

:: start error level reporting
echo.
echo      ===== Build Report =====
echo DictionaryGeneration error set to: %indexerror%
echo JarCreator error set to          : %jarerror%
echo File Copy error set to           : %copyerror%
echo Zip File error set to            : %ziperror%
::echo Copy 2 error set to     : %copy2error%
::echo Move error set to       : %moveerror%
echo.

goto :eof
::exit

:catcherrors
set %~2=%~1
if  %errorlevel% neq 0 echo Big Problem with %~3, the errorlevel set to %errorlevel%
if  %errorlevel% neq 0 pause
goto:eof

:get_input
::echo on
set varname=%~1
set question=%~2
SET input=%~3
if "%input%" == "" SET /P input=%question%:
set %varname%=%input%
:: the following two option allow numbers to be written to file with no following space.
>>%writefile% echo set %~1=%input%
:: (echo set %~1=%input%) >>%writefile%
::echo off
goto:eof

:menuchoice
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%

ECHO.
:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
FOR /D %%c IN (%menuoptions%) DO call :menueval %%c
::goto :%menuname%
goto:eof

:menu
::echo off
set menulist=%~1
set title=     %~2
set menuoptions=
echo.
echo %title%
echo.
FOR /F "eol=# tokens=1,2,3 delims=;" %%i in (%menulist%) do @echo        %%i. %%j &set option%%i=%%k &call :menuoptions %%i
echo.
echo        X. Exit batch menu
echo.
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter:
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%
IF /I '%Choice%'=='x' exit /b
:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
FOR /D %%c IN (%menuoptions%) DO call :menueval %%c
goto menu


:menueval
:: run through the choices to find a match then calls the selected option
set let=%~1
set option=option%let%
:: /I makes the IF comparison case-insensitive
IF /I '%Choice%'=='%let%' call %%%option%%%
goto :eof



:xml2dfmsetup
:: ensure dir exists and input file is ready
echo off
call %let%-options.cmd
echo off
call :checkdir "data\%iso%"
call :checkdir "data\%iso%\%langs%"
call :checkdir "data\%iso%\%langs%\%size%"
call :checkdir "%zipoutdir%"
::echo on
call :ifnotdo "data\%iso%\%langs%\%size%\DictionaryForMIDs.properties" :makeproperties
call :type_%type%
:: if %type%==lift set xmlsource=%iso%.lift
:: if %type% == lift call :ifnotcopy data\%iso%\%xmlsource% %dictpath%\%iso%\xml\%xmlsource%
:: if %type% == plb call :ifnotcopy data\%iso%\%xmlsource% %dictpath%\%iso%\xml\%xmlsource%
:: call :xml2input
goto :eof

:type_plb
set xmlsource=%iso%-a.xml
call :ifnotcopy data\%iso%\%xmlsource% %dictpath%\%iso%\xml\%xmlsource%
call :xml2input
goto :eof

:type_mdf
set xmlsource=%iso%.xml
call :xml2input
goto :eof

:type_lift
set xmlsource=%iso%.lift
call :ifnotcopy data\%iso%\%xmlsource% %dictpath%\%iso%\xml\%xmlsource%
call :xml2input
goto :eof

:type_pathway
set xmlsource=main.xhtml
call :xml2input
goto :eof

:type_pathwaytxt
copy /Y data\%iso%\main.txt data\%iso%\%langs%\mid\Dictionary_input.txt
copy /Y data\%iso%\DictionaryForMIDs.properties data\%iso%\%langs%\mid\DictionaryForMIDs.properties
goto :eof

:makeisocmd
call :checkdir "data\%iso%"
echo no iso.cmd file found at
echo Answer the questions to create %varfile%
set writefile=data\%iso%\%iso%.cmd
echo :: Generated by Question and Answer for %iso%> %writefile%
set langname=
set type=
set title=
if exist "..\dict-svn\var\%iso%.cmd" call "..\dict-svn\var\%iso%.cmd"

set writefile=%varfile%
call :get_input compiler "Enter the dictionary's Compiler"
call :get_input title "Enter the dictionary title" "%title%"
call :get_input type "Enter the dictionary type mdf,lift, pathway or plb" %type%
call :get_input langname "Enter Language name" "%langname%"
call :get_input version "Enter the dictionary version number" "" number
call :get_input langs "How many langguages are there?" "" number
call :get_input stage "Enter online if already published or prog if a work in progress"
echo set dicturi=%webbaseuri%/%stage%/%iso%/dict>>%varfile%
if "%langs%" GEQ "3" call :get_input langname3 "Enter third language often Tagalog/Filipino" "%natlang%"
if "%langs%" GEQ "3" call :get_input iso3 "Enter third language iso"
if "%langs%" GEQ "4" call :get_input langname4 "Enter forth language often Ilocano/Cebuano" "%reglang%"
if "%langs%" GEQ "4" call :get_input iso4 "Enter forth language often Ilocano/Cebuano"
if "%langs%" GEQ "5" call :get_input langname5 "Enter fifth language"  "%reg2lang%"
if "%langs%" GEQ "5" call :get_input iso5 "Enter fifth language iso"
goto :eof


:makeproperties
echo off
echo properties file not found. Checking if iso.cmd file exists
if not exist "%projvarfile%" call :makeisocmd
call "%projvarfile%"
set propfile=data\%iso%\%langs%\%size%\DictionaryForMIDs.properties
echo infoText: %title%. %publisher%. version^: %version% %date:~-4,4%-%date:~-7,2%-%date:~-10,2% %dicturi%>%propfile%
echo dictionaryAbbreviation^: %iso%-%size%>>%propfile%
echo numberOfAvailableLanguages^: %langs% >>%propfile%
echo.>>%propfile%
echo language1DisplayText: %langname%>>%propfile%
echo language2DisplayText: English Index>>%propfile%
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
echo off

:: start Copyright file
if not exist %copyrightfile% (
echo Title: %title%>%copyrightfile%
echo Compiler: %compiler%>>%copyrightfile%
echo Publisher: %publisher%>>%copyrightfile%
echo Publication Date: %date:~10%>>%copyrightfile%
echo Online version: %webbaseuri%/%stage%/%iso%/dict>>%copyrightfile%
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

:xslt
echo Commandline: %java%  -jar "%saxon9%"   -o "%outfile%" "%infile%" "%script%" %param%
%java%  -jar "%saxon9%"   -o "%outfile%" "%infile%" "%script%" %param%
if %errorlevel% neq 0 (
echo[
echo XXXXXXXXXXXXXXXXXXXXXX  Error, failed to create file XXXXXXXXXXXXXXXXXXXXXX
echo[
) else (
echo[
echo OK %report%
echo[
)
goto :eof

:result
set result=%~1
::echo set result=%~1
goto :eof

:isovar
set varfile=%cd%\data\%iso%\%iso%.cmd
echo varfile=%cd%\data\%iso%\%iso%.cmd
goto :eof

:checkdir
set report=Checking dir %~1
if exist "%~1"  (
		  echo . . . Found! %~1
	) else (
		  echo . . . not found. %~1
		  mkdir "%~1"
		  echo mkdir "%~1"
)
goto:eof

:ifnotcopy
if not exist %~1 (
	if "%~3" == "" (
		copy %~2 %~1
echo copy %~2 %~1
echo copy %~2 %~1>>%logfile%
	) else (
		copy %~2 %~3
echo copy %~2 %~3
echo copy %~2 %~3>>%logfile%
	)
) else (
	  echo . . . Found! %~1
)
goto :eof

:ifnotdo
if not exist %~1 (
	  echo Missing %~1
	  echo call %~2
	  call %~2
) else (
	  echo . . . Found! %~nx1
)
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

:var
:: relative path variables
set copyrightfile=data\%iso%\copyright.txt
set varfile=data\%iso%\%iso%.cmd
set xmlsource=%iso%-a.xml
set basepath=%cd%
:: the next two items were moved to local_var.cmd file
::set dictpath=..\Dict-svn\data
::set dictverpath=..\Dict-svn\var
set proptail=setup\properties-tail.txt
set propmid=setup\properties-middle.txt
set projvarfile=data\%iso%\%iso%.cmd

:: variables
set ziperror=0
set wl=wl
set min=min
set mid=mid
set full=full
set type=plb
:: set default number of languages for dictionary
set langs=2

:: Absolute paths and variables that may need to be customized
set zipoutdir=%cd%\data\%iso%\zip
set zip=C:\Program Files\7-Zip\7z.exe
set java=java
set saxon9=C:\Program Files (x86)\Kernow\lib\saxon9.jar
set webbaseuri=http://www.sil.org/asia/philippines
set publisher=SIL Philippines

:: Customise varables for your system by this file if it exists
:: or for one offs put in iso.cmd
if exist "local_var.cmd" call "local_var.cmd"
::if exist %dictvarpath%\%iso%.cmd call %dictvarpath%\%iso%.cmd
goto :eof

:menuline
:: echo on
set l=%~1
set action=%~2
set textchoice=%~3
set paramname1=%~4
set param1=%~5
set paramname2=%~6
set param2=%~7
set paramname3=%~7
set param3=%~8
set option%l%=%action%

if "%paramname1%" neq "" set out=%~1-options.cmd
if "%paramname1%" neq "" echo set %~4=%~5>%out%
if "%paramname2%" neq "" echo set %~6=%~7>>%out%
if "%paramname3%" neq "" echo set %~8=%~9>>%out%

:: echo off
if "%textchoice%" neq "hide" echo        %l%. %textchoice%
goto :eof

:myexit
exit /b %errorlevel%
:done

:exitmessage
echo.
echo %message%
echo.
echo The script will end.
echo.
pause

:end