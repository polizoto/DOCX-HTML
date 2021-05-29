#!/bin/bash
# Joseph Polizzotto
# UC Berkeley
# 510-642-0329
# Version 1.7.9
# Instructions: 1) From a directory containing DOCX file(s) to convert, open a Terminal window and enter the path to the script. 2) Enter any desired options (see Help menu -h) 3) Press ENTER.
# This script is designed to run on a Windows 10 (PC) device
 
###### PC SCRIPT #######

function usage (){
    printf "\nUsage: $(baseName "$0") [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -c, Check for warnings and errors in the terminal. Parameters: off (default is on)\n"	
	printf " -d, Diagnostics. Check that all dependencies are met [Parameters: None]\n"	
	printf " -e, Edit warnings and errors in the terminal (using Vim).\n"
    printf " -f, Add Footnotes. [Parameters: None]\n"
    printf " -h, Print help\n"
	printf " -i, Inspect alternative text of math equations (requires use with -m mathspeak or -m SVG options). [Parameters: None]\n"
	printf " -j, Just HTML body (no CSS or <head>). [Parameters: None]\n"
    printf " -l, Designate secondary languages (up to 9). Use -l flag before every secondary language. [Parameters: 2-letter ISO value]\n"
    printf " -m, Math output options. Parameters: mathml, webtex, svg, mathspeak (default is mathjax)\n"
    printf " -n, Add line numbers (poetry). [Parameters: None]\n"
	printf " -p, PDF output. Saves (reformatted) DOCX to HTML directory. [Parameters: None]\n"
	printf " -r, Remove markup (e.g., MS Word hyperlinks). [Parameters: None]\n"
    printf " -s, Specify a stylesheet.[Parameters: Name of stylesheet (default: standard.css)]\n"
	printf " -w, Check if Word is running (using tasklist) and move all DOCX files to converted DOCX-HTML folder after conversion.[Parameters: None]\n"
	printf " -u, Upload HTML file to Canvas LMS (requires class number and user's API key).[Parameters: None]\n"
    printf " -v, Print script version\n"

return 0
}

function version (){
    printf "\nVersion 1.7.9\n"

return 0
}

while getopts :s:l:im:fc:ejdnprhwuv flag

do
    case "${flag}" in
		: ) echo -e "\nOption -"$OPTARG" requires an argument." >&2
            exit 1;;
        s) stylesheet=${OPTARG};
        if [ ! -f /c/stylesheets/"$stylesheet".css ]; then
        echo -e "\n\033[1;31mCould not locate \033[1;35m"$stylesheet".css. \033[0m\033[1;31mPlace the stylesheet in \033[0m\033[1;44m~/stylesheets/\033[0m\033[1;31m and run the script again. If the name of the stylesheet has spaces, place double quotes around the name. Exiting...\033[0m">&2
        exit 2
        fi
		;;
		d) diagnostics="${flag}";;
        e) edit="${flag}";
        if ! command -v vim &> /dev/null ; then
        echo -e "\n\033[1;31mVim (the program used for editing files in a terminal) is not available in your path. PLease download Vim (https://www.vim.org/download.php) and make sure it is available in your path. Exiting...\033[0m">&2
        exit 2
        fi
        ;;
		l) language+=("$OPTARG");;
        f) footnote="${flag}";;
		j) just="${flag}";;
		c)
		check=${OPTARG}
        if [[ ! "$check" == on && ! "$check" == off ]]; then 
        echo -e "\n\033[1;31mInvalid parameter entered for -c option (You must enter either on or off; Default is on). Exiting...\033[0m"
        exit 2
        fi
        ;;
		i) inspect="${flag}";;
        n) linenumbers="${flag}";;
        m)
        math=${OPTARG}
        if [[ ! "$math" == mathml && ! "$math" == webtex && ! "$math" == svg && ! "$math" == mathspeak ]]; then 
        echo -e "\n\033[1;31mInvalid parameter entered for -m option (You must enter either webtex, mathml, svg, or mathspeak). Exiting...\033[0m"
        exit 2
        fi
        ;;
        n) linenumbers="${flag}";;
        --) shift
            break;;
		p) pdf="${flag}";;	
		r) remove="${flag}";;
		w) word="${flag}";
		if [ ! -f /c/scripts/tasklist.exe ]; then
        echo -e "\n\033[1;31mCould not locate \033[1;35mtasklist.exe. \033[0m\033[1;31mPlace tasklist.exe in \033[0m\033[1;44m~/scripts/\033[0m\033[1;31m and run the script again. Exiting...\033[0m">&2
        exit 2
        fi
		;;
		u) upload="${flag}";;
        v) version; exit 2;;
        h) usage; exit 2;;
        \?) echo -e "Invalid option\n";usage; exit 2;;
    esac

  done

    shift $[ $OPTIND - 1 ]
 
count=1
for param in "$@"
  
  do
  
  echo
  
  if  [ $count -ge 1 ]; then
  
  echo -e "\033[1;31mInvalid value:\033[0m $@\033[1;31m. Use a single word after the option. E.g., if you are using the -l option for multiple languages, enter -l before each secondary language (-l it -l fr). Exiting...\033[0m"
  
  exit 2
  
  count=$[ $count + 1]  
  
  fi
  
  done
		
# Sort multiple parameters for secondary languages

shift $((OPTIND -1))

count=1
for val in "${language[@]}"; do
     if [[ ! $val == [a-z][a-z] ]]; then
            echo -e "\n\033[1;31mInvalid ISO value entered with -l option:\033[0m "$val" \033[1;31m(Value must be only two letters.). Exiting...\033[0m"
            exit 2
            else
            eval language$count=$val
            shift
            fi
            count=$[ $count +1 ]
done

if [ -n "$diagnostics" ]; then

USER=$(whoami)

if  command -v git >/dev/null  2>&1; then 

if ! (echo a version 2.31.1; git --version) | sort -Vk3 | tail -1 | grep -q git
then

basic_dependencies=missing

fi

else

basic_dependencies=missing

fi 

if [ -x "$(command -v pandoc)" ]; then

if ! pandoc -v | (echo a.exe 2.13; pandoc --version | head -1) | sort -Vk2 | tail -1 | grep -q pandoc
then

basic_dependencies=missing

fi

else

basic_dependencies=missing

fi

if [ ! -f  "C:\stylesheets\standard.css" ]; then

basic_dependencies=missing

fi

# Check if Nu HTML Checker is installed.

if [ ! -f  /c/vnu-runtime-image/bin/vnu.bat ]; then

basic_dependencies=missing

fi

# Check if Tasklist


if [ ! -f /c/scripts/tasklist.exe ]; then 

basic_dependencies=missing

fi

if [[ "$basic_dependencies" == "" ]]; then

printf "%-15s \e[1;32m%s\e[m\n" "Basic Setup" "OK"

fi

if [[ "$basic_dependencies" == "missing" ]]; then

printf "%-15s \e[1;31m%s\e[m\n" "Basic Setup" ""

if  command -v git >/dev/null  2>&1; then 

if (echo a version 2.31.1; git --version) | sort -Vk3 | tail -1 | grep -q git
then
    printf "%-15s \e[1;32m%s\e[m\n" "Git" "OK"
else
    printf "%-15s \e[1;33m%s\e[m\n" "Git" "Newer version available." 
	printf "%-15s \e[1;33m%s\e[m\n" "" "Run 'git update-git-for-windows'"
fi

else

printf "%-15s \e[1;31m%s\e[m\n" "Git" "Not Found"

fi 

if [ -x "$(command -v pandoc)" ]; then


if pandoc -v | (echo a.exe 2.13; pandoc --version | head -1) | sort -Vk2 | tail -1 | grep -q pandoc
then
    printf "%-15s \e[1;32m%s\e[m\n" "Pandoc" "OK"
else
    printf "%-15s \e[1;33m%s\e[m\n" "Pandoc" "Newer version available." 
	printf "%-15s \e[1;33m%s\e[m\n" "" "Get the latest: https://pandoc.org/installing.html"
fi

else

printf "%-15s \e[1;31m%s\e[m\n" "Pandoc" "Not Found"

fi

if [ -f  "C:\stylesheets\standard.css" ]; then

printf "%-15s \e[1;32m%s\e[m\n" "Stylesheet" "OK"

else

printf "%-15s  \e[1;31m%s\e[m\n" "Stylesheet" "Not Found"


fi


if [ -f  /c/vnu-runtime-image/bin/vnu.bat ]; then

printf "%-15s \e[1;32m%s\e[m\n" "NuHTML" "OK"

else

printf "%-15s  \e[1;31m%s\e[m\n" "NuHTML" "Not Found"

fi

if [ -f /c/scripts/tasklist.exe ]; then 

printf "%-15s \e[1;32m%s\e[m\n" "Tasklist" "OK"

else

printf "%-15s  \e[1;31m%s\e[m\n" "Tasklist" "Not Found"

fi

fi

if  ! command -v node >/dev/null  2>&1; then 

math_dependencies=missing

fi

if  ! command -v tex2svg >/dev/null  2>&1; then 

math_dependencies=missing

fi 

if [ ! -d /c/Users/$USER/AppData/Roaming/npm/node_modules/mathjax-node-cli/bin ]; then

math_dependencies=missing

fi

if [ ! -f /c/Users/$USER/AppData/Roaming/npm/node_modules/mathjax-node-sre/bin/mjsre.js ]; then

math_dependencies=missing

fi



if [[ "$math_dependencies" == "" ]]; then

printf "%-15s \e[1;32m%s\e[m\n" "Math Setup" "OK"

fi

if [[ "$math_dependencies" == "missing" ]]; then

printf "%-15s \e[1;31m%s\e[m\n" "Math Setup" ""

if  command -v node >/dev/null  2>&1; then 

printf "%-15s \e[1;32m%s\e[m\n" "Node.js" "OK"
else

printf "%-15s \e[1;31m%s\e[m\n" "Node.js" "Not Found"

fi

if  command -v tex2svg >/dev/null  2>&1; then 

printf "%-15s \e[1;32m%s\e[m\n" "tex2svg" "OK"
else

printf "%-15s \e[1;31m%s\e[m\n" "tex2svg" "Not Found"

fi

if [ -d /c/Users/$USER/AppData/Roaming/npm/node_modules/mathjax-node-cli/bin ]; then

printf "%-15s \e[1;32m%s\e[m\n" "MathJaxCLI" "OK"
else

printf "%-15s \e[1;31m%s\e[m\n" "MathJaxCLI" "Not Found"

fi

if [ -f /c/Users/$USER/AppData/Roaming/npm/node_modules/mathjax-node-sre/bin/mjsre.js ]; then

printf "%-15s \e[1;32m%s\e[m\n" "MathJaxSRE" "OK"
else

printf "%-15s \e[1;31m%s\e[m\n" "MathJaxSRE" "Not Found"

fi

fi

if command -v vim &> /dev/null ; then

printf "%-15s \e[1;32m%s\e[m\n" "Vim" "OK"
else

printf "%-15s \e[1;31m%s\e[m\n" "Vim" "Not Found"

fi

if [ -f /c/scripts/canvas_token.txt ]; then

printf "%-15s \e[1;32m%s\e[m\n" "Canvas Token" "OK"

else

printf "%-15s \e[1;31m%s\e[m\n" "Canvas Token" "Not Found"

fi

exit 1

fi

##

if [ -n "$upload" ]; then

if [ ! -f /c/scripts/canvas_token.txt ]; then

echo -e "\n\033[1;31mError: Could not find canvas_token.txt file in ~/scripts/ folder. Exiting..." >&2

exit 1

fi

token=`cat /c/scripts/canvas_token.txt | sed -n 2p`

if [[ "$token" == "" ]]; then

echo -e "\n\033[1;31mError: No API token found on line 2 of canvas_token.txt. Copy and paste the API token to line 2. Exiting..." >&2

exit 1

fi

canvas_domain=`cat /c/scripts/canvas_token.txt | sed -n 4p`

if [[ "$canvas_domain" == "" ]]; then

echo -e "\n\033[1;31mError: No Canvas domain found on line 4 of canvas_token.txt. Copy and paste the Canvas domain to line 4. Exiting..." >&2

exit 1

fi

echo -ne '\n'

read -p "Enter the course number of the Canvas course where you wish to post the HTML file:  " class_number

curl -sS https://$canvas_domain/api/v1/courses/$class_number/files -H 'Authorization: Bearer '$token'' | sed 's/.*url":"//g' | sed 's/","upload.*//g' > ./canvas_test.txt

if 	grep -q 'Invalid' ./canvas_test.txt ; then

echo -e "\n\033[1;31mError: Invalid API token. Check API token in ~/scripts/canvas_token.txt.\033[0m"

rm ./canvas_test.txt

exit 1

fi

if 	grep -q 'resolve' ./canvas_test.txt ; then

echo -e "\n\033[1;31mError: Could not find Canvas domain. Check Canvas domain in ~/scripts/canvas_token.txt. Exiting...\033[0m"

rm ./canvas_test.txt

exit 1

fi 

if 	grep -q 'exist' ./canvas_test.txt  ; then

echo -e "\n\033[1;31mError: Invalid course number. Check Canvas course number. Exiting...\033[0m"

rm ./canvas_test.txt 

exit 1

fi 

echo -ne "\n"

while true; do

read -n1 -p "Do you wish to upload the file as a course page [1] or to the Files area [2] in Canvas? [1/2]?" answer

case $answer in
1 ) 
       course_page=yes
       echo -ne "\n"
       break
	   ;;
	   
2 ) 
       course_page=no
       echo -ne "\n"
       break
	   ;;	
	*)
	   echo -e "\n"
       echo -e "\033[1;31mError: Invalid entry\033[0m "$answer". \033[1;31mYou must enter one of the following values: [ 1 / 2].\033[0m\n"
	   ;;

	   
esac

done

rm ./canvas_test.txt

fi

# Make --mathjax the default math variable when the -m option is not used

        if [[ "$math" == "" ]]; then 
         math=mathjax        
        fi

if [[ "$math" == "webtex" ]]; then 

if [ -n "$inspect" ]; then

inspect=off

echo -e "\n\033[1;31mError: -i option does not work with webtex option. You must select either -m svg or -m mathspeak." >&2

fi
fi
		
# Make --webtex the math variable when the -m option is  speech

        if [[ "$math" == "mathspeak" ]]; then 
         
         if ! [ -x "$(command -v tex2svg)" ]; then

        echo -e "\n\033[1;31mError: tex2svg was not found. Please install Node.js (https://nodejs.org/en/download/) and  mathjax-node-cli (https://github.com/mathjax/mathjax-node-cli). Make sure tex2svg is available in your path. Math will be displayed using default option (mathjax)...\033[0m" >&2
        
        math=mathjax
        
        else
        
        speech=on
        
        math=webtex

        fi
         
        fi


if [[ "$speech" == "on" ]]; then

if [ -n "$inspect" ]; then

inspect=on

fi
fi
		
# Make --webtex the math variable when the -m option is SVG

        if [[ "$math" == "svg" ]]; then 
         
         if ! [ -x "$(command -v tex2svg)" ]; then

        echo -e "\n\033[1;31mError: tex2svg was not found. Please install Node.js (https://nodejs.org/en/download/) and  mathjax-node-cli (https://github.com/mathjax/mathjax-node-cli). Make sure tex2svg is available in your path. Math will be displayed using default option (mathjax)...\033[0m" >&2
        
        math=mathjax
        
        else
        
        SVG=on
        
        math=webtex

        fi
         
        fi	
		
	if [[ "$SVG" == "on" ]]; then
	
	if [ -n "$inspect" ]; then
	
	inspect=on

	fi
	fi

if [[ "$math" == "mathjax" ]]; then 

if [ -n "$inspect" ]; then

inspect=off

echo -e "\n\033[1;31mError: -i option does not work with mathjax option. You must select either -m svg or -m mathspeak." >&2

fi
fi

if [[ "$math" == "mathml" ]]; then 

if [ -n "$inspect" ]; then

inspect=off

echo -e "\n\033[1;31mError: -i option does not work with mathml option. You must select either -m svg or -m mathspeak." >&2

fi
fi


	
# Make Standard.css the default stylesheet when the -s option is not used

        if [[ "$stylesheet" == "" ]]; then 
         stylesheet=standard        
        fi
		
# Make Yes the default check variable when the -c option is not used

        if [[ "$check" == "" ]]; then 
         check=on        
        fi

# Turn off check flag if Edit is on (to avoid duplication of output)

        if [ -n "$edit" ]; then
            check=off
            fi

# Remove _HTML from the name of the DOCX files in current working directory if MS Word is closed (requires tasklist)			

if [ -f /c/scripts/tasklist.exe ]; then
			
if ! /c/scripts/tasklist.exe //FI "IMAGENAME eq WINWORD.EXE" 2> /dev/null | grep -q "WINWORD.EXE" 2> /dev/null ; then

for x in ./*.docx; do

mv "$x" "`echo $x | sed 's/_HTML//'`"

done

fi

fi 
			
		
# Check if Pandoc is installed; if not, exit the script.

if ! [ -x "$(command -v pandoc)" ]; then

echo -e "\n\033[1;31mError: Pandoc (https://pandoc.org/installing.html)is not installed. Exiting...\033[0m" >&2

exit 1

fi

# Check if the specfied stylesheet exists in the correct directory

if [ ! -f /c/stylesheets/"$stylesheet".css ]; then

echo -e "\n\033[1;31mCould not locate \033[1;35m"$stylesheet".css. \033[0m\033[1;31mPlace the stylesheet in \033[0m\033[1;44m~/stylesheets/\033[0m\033[1;31m and run the script again. Exiting...\033[0m">&2
  
exit 1

fi

# Check if Nu HTML Checker is installed. if not, exit the script.

if [ ! -f  /c/vnu-runtime-image/bin/vnu.bat ]; then

echo -e "\n\033[1;31mError: Nu HTML Checker (https://validator.github.io/validator) was not found. Install Java 8 and place vnu.jar in your home (~/) directory. Exiting....\033[0m\n" >&2

exit 1

fi

if [ -f ./tmp ] ; then

rm ./tmp

fi

if [ -f ./~ ] ; then

rm ./~

fi

find . -type f -name "~*.docx" -exec rm -f {} \;

if [ ! -n "$(find . -maxdepth 1 -name '*.docx' -type f -print -quit)" ]; then

echo -e "\033[1;31mDOCX files are not located in this directory. Exiting...\033[0m"

exit

fi

for x in ./*.docx; do

        basePath=${x%.*}
        baseName=${basePath##*/}
        export baseName
        name=${baseName%???????}
        TIMESTAMP=`date "+%m-%d-%Y %H:%M"`

# Create Directories

if [ ! -d ./"${x%.*}" ]; then

# mkdir "${x%.*}"

mkdir ./"$baseName"

fi
  
if [ ! -d ./Converted-DOCX-HTML ]; then

mkdir Converted-DOCX-HTML

fi

if [ ! -d ./Converted-DOCX-HTML/log.txt ]; then

touch ./Converted-DOCX-HTML/log.txt 

fi

cp  "$x" ./"$baseName"_edited.docx 2> /dev/null

rm ./~*.docx 2> /dev/null 

#

if [ -n "$upload" ]; then	
		
if [[ "$SVG" == "on" ]]; then

course_page=no

echo -e "\n\033[1;33mATTENTION:\033[0m Canvas currently does not support SVG images. \033[1;32m"$baseName".html\033[0m will be uploaded as a standalone HTML file..."

fi

curl -sS https://$canvas_domain/api/v1/courses/$class_number -H 'Authorization: Bearer '$token'' | sed 's/.*"name":"//g' | sed 's/",.*//g' > ./"$baseName"/canvas_course.txt

canvas_course=`cat ./"$baseName"/canvas_course.txt`

if [[ $course_page == "no" ]]; then

echo -ne '\n'

read -p "Enter the folder in the Canvas course where you wish to post the HTML file (Use / after each parent folder OR just press Enter/Return to place the HTML file in the Files area OR type 'same' to create a folder with the same name as the HTML file:  " canvas_path_name

if [[ "$canvas_path_name" == "same" ]]; then 

canvas_path_name=$baseName

fi

fi

fi

# Create HTML File
		
echo -e "\nConverting \033[1;35m"$baseName".docx\033[0m to \033[1;32m"$baseName".html\033[0m..."

if [[ $course_page == "yes" ]]; then

pandoc "$baseName"_edited.docx -s -t html5 --metadata pagetitle="$baseName" --toc --toc-depth=3 -M document-css=false -H /c/stylesheets/"$stylesheet".css --"$math" --extract-media=./"$baseName" -o ./"$baseName"/"$baseName".html

else

pandoc "$baseName"_edited.docx --self-contained -t html5 --metadata pagetitle="$baseName" --toc --toc-depth=3 -M document-css=false -H /c/stylesheets/"$stylesheet".css --"$math" -o ./"$baseName"/"$baseName".html

perl -pi -e 's/(src="data:application\/javascript;.*)("><\/script>)/src="https:\/\/cdn.jsdelivr.net\/npm\/mathjax@3\/es5\/tex-chtml-full.js$2/g' ./"$baseName"/"$baseName".html

fi

# Correct HTML Title Name

sed -i 's/_edited<\/title>/<\/title>/g' ./"$baseName"/"$baseName".html

# Add Language Text to HTML

sed -i 's/xml:lang=""//g' ./"$baseName"/"$baseName".html

sed -i 's/lang=""/lang="en"/g' ./"$baseName"/"$baseName".html

sed -i 's/lang xml:lang/lang="en"/g' ./"$baseName"/"$baseName".html
 
# Clean up Invalid HTML
	
sed -i 's/ type="text\/javascript"//g' ./"$baseName"/"$baseName".html
	
sed -i 's/ type="text\/css"//g' ./"$baseName"/"$baseName".html
        
# Clean up Path to Images

perl -0777 -pi -e 's/<img\ src=".*\\media\\/<img\ src=".\/media\//g' ./"$baseName"/"$baseName".html
 
echo -ne '\n#######                    \033[1;33m(33%)\033[0m\r'
sleep 1 

# Add an ARIA main <main> landmark for the main region of the document.	

if grep -qi "</nav>" ./"$baseName"/"$baseName".html > /dev/null ; then perl -0777 -pi -e 's/<\/nav>\n/<\/nav>\n<main>\n/g' ./"$baseName"/"$baseName".html ; else perl -0777 -pi -e 's/<\/head>\n<body>/<\/head>\n<body>\n<main>/g' ./"$baseName"/"$baseName".html ; fi		
	
# Add a closing element for the ARIA main </main> region of the document.

perl -0777 -pi -e 's/<\/body>/<\/main>\n<\/body>/g' ./"$baseName"/"$baseName".html

# Remove ARIA role for the NAV region in the document (role="doc-toc").

sed -i 's/<nav id="TOC" role="doc-toc">/<nav id="TOC">/g' ./"$baseName"/"$baseName".html
           
# Add an ARIA landmark in the document <footer> and add text about how to get in touch with the Alternative Media Unit of DSP.
		
perl -0777 -pi -e  "s/<\/main>\n/<\/main>\n<footer>\n<p role=\"contentinfo\">This document was created by the Alternative Media Unit of the Disabled Students' Program at UC Berkeley. For questions or concerns about this document, please contact us at dspamc@berkeley.edu.<\/p>\n<\/footer>\n/g" ./"$baseName"/"$baseName".html
        
# Perform Find and Replace in HTML for text that has dotted underline formatting ($$$)
	
sed -i 's/\$\$\$/<span class="dotted">/g' ./"$baseName"/"$baseName".html
		
# Perform Find and Replace in HTML for text that has dashed underline formatting (^^^)
		
sed -i 's/\^\^\^/<span class="dashed">/g' ./"$baseName"/"$baseName".html
		
# Perform Find and Replace in HTML for text that has double underline formatting (+++)
		
# sed -i 's/+++/<span class="doubleunderline">/g' ./"$baseName"/"$baseName".html
		
# Perform Find and Replace in HTML for text that has highlight formatting (~~~)
		
sed -i 's/~~~/<mark>/g' ./"$baseName"/"$baseName".html
		
# Perform Find and Replace in HTML for text that has closing tag for highlight formatting (***)
		
sed -i 's/\*\*\*/<\/mark>/g' ./"$baseName"/"$baseName".html
		
# Perform Find and Replace in HTML for text that has double strikethrough formatting (***)
		
sed -i 's/???/<del style="text-decoration-style: double;">/g' ./"$baseName"/"$baseName".html

# Perform Find and Replace in HTML for text that has closing tag for double strikethrough formatting (!!!)

sed -i 's/!!!/<\/del>/g' ./"$baseName"/"$baseName".html

# Change Footnote Opening Text from "Begin Footnote:" to "Footnote Begin:"

sed -i 's/<p>Begin Footnote:<\/p>/<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Footnote Opening if not capitalized

sed -i 's/<p>Footnote begin:<\/p>/<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Opening Text from "Begin Secondary Text:" to "Secondary Text Begin:"
		
sed -i 's/<p>Begin Secondary Text:<\/p>/<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text if not capitalized
		
sed -i 's/<p>Secondary text begin:<\/p>/<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Opening Text from "Begin Description:" to "Description Begin:"
		
sed -i 's/<p>Begin Description:<\/p>/<p>Description Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Opening Text if not capitalized
		
sed -i 's/<p>Description begin:<\/p>/<p>Description Begin:<\/p>/g' ./"$baseName"/"$baseName".html

# Change Footnote Opening Text from "Begin Footnote" to "Footnote Begin:"

sed -i 's/<p>Begin Footnote<\/p>/<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Opening Text from "Begin Secondary Text" to "Secondary Text Begin:"
		
sed -i 's/<p>Begin Secondary Text<\/p>/<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Opening Text from "Begin Description" to "Description Begin:"
		
sed -i 's/<p>Begin Description<\/p>/<p>Description Begin:<\/p>/g' ./"$baseName"/"$baseName".html

# Change Footnote Opening Text from "Footnote Begin" to "Footnote Begin:"

sed -i 's/<p>Footnote Begin<\/p>/<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Opening Text from "Secondary Text Begin" to "Secondary Text Begin:"
		
sed -i 's/<p>Secondary Text Begin<\/p>/<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Text Opening Text from "Description Begin" to "Description Begin:"
		
sed -i 's/<p>Description Begin<\/p>/<p>Description Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Footnote Ending Text from "Footnote End" to "Footnote End."
		
sed -i 's/<p>Footnote End<\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Footnote Ending Text if not capitalized
		
sed -i 's/<p>Footnote end.<\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Ending Text from "Secondary Text End" to "Secondary Text End."
		
sed -i 's/<p>Secondary Text End<\/p>/<p>Secondary Text End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Ending Text if not capitalized
		
sed -i 's/<p>Secondary text end.<\/p>/<p>Secondary Text End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Ending Text from "Description End" to "Description End."
		
sed -i 's/<p>Description End<\/p>/<p>Description End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Ending Text if not capitalized
		
sed -i 's/<p>Description end.<\/p>/<p>Description End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Footnote Ending Text from "End Footnote." to "Footnote End."
		
sed -i 's/<p>End Footnote.<\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Ending Text from "End Secondary Text." to "Secondary Text End."
		
sed -i 's/<p>End Secondary Text.<\/p>/<p>Secondary Text End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Description Ending Text from "End Description." to "Description End."
		
sed -i 's/<p>End Description.<\/p>/<p>Description End.<\/p>/g' ./"$baseName"/"$baseName".html

# Change Footnote Ending Text from "End Footnote" to "Footnote End."

sed -i 's/<p>End Footnote<\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Secondary Text Ending Text from "End Secondary Text" to "Secondary Text End."
		
sed -i 's/<p>End Secondary Text<\/p>/<p>Secondary Text End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Figcaption Beginning Text from "Figcaption begin:" to "Figcaption Begin:"
		
sed -i 's/<p>Figcaption begin:<\/p>/<p>Figcaption Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Figcaption Ending Text from "Figcaption end." to "Figcaption End."
		
sed -i 's/<p>Figcaption end.<\/p>/<p>Figcaption End.<\/p>/g' ./"$baseName"/"$baseName".html

# Change Figcaption Beginning Text from "Begin Figcaption:" to "Figcaption Begin:"
		
sed -i 's/<p>Begin Figcaption:<\/p>/<p>Figcaption Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Figcaption Ending Text from "End Figcaption." to "Figcaption End."
		
sed -i 's/<p>End Figcaption.<\/p>/<p>Figcaption End.<\/p>/g' ./"$baseName"/"$baseName".html

# Change Caption Beginning Text from "Caption begin:" to "Caption Begin:"
		
sed -i 's/<p>Caption begin:<\/p>/<p>Caption Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Caption Ending Text from "Caption end." to "Caption End."
		
sed -i 's/<p>Caption end.<\/p>/<p>Caption End.<\/p>/g' ./"$baseName"/"$baseName".html

# Change Caption Beginning Text from "Begin Caption:" to "Caption Begin:"
		
sed -i 's/<p>Begin Caption:<\/p>/<p>Caption Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Caption Ending Text from "End Caption." to "Caption End."
		
sed -i 's/<p>End Caption.<\/p>/<p>Caption End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Transcriber Beginning Text from "Transcriber Note begin:" to "Transcriber Note Begin:"
		
sed -i 's/<p>Transcriber Note begin:<\/p>/<p>Transcriber Note Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Transcriber Ending Text from "Transcriber Note end." to "Transcriber Note End."
		
sed -i 's/<p>Transcriber Note end.<\/p>/<p>Transcriber Note End.<\/p>/g' ./"$baseName"/"$baseName".html

# Change Transcriber Beginning Text from "Begin Transcriber Note:" to "Transcriber Note Begin:"
		
sed -i 's/<p>Begin Transcriber Note:<\/p>/<p>Transcriber Note Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Change Transcriber Ending Text from "End Transcriber Note." to "Transcriber Note End."
		
sed -i 's/<p>End Transcriber Note.<\/p>/<p>Transcriber Note End.<\/p>/g' ./"$baseName"/"$baseName".html		
			
# Change Description Ending Text from "End Description" to "Description End."
		
sed -i 's/<p>End Description<\/p>/<p>Description End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Add <aside> markup to Footnotes, Secondary Text, and Description text areas (for easier navigation and clarity about regions in a document) #

# Remove superscript if applied to Footnote Begin Text
		
sed -i 's/<p><sup>Footnote Begin:<\/sup><\/p>/<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Remove superscript if applied to Footnote End Text
		
sed -i 's/<p><sup>Footnote End.<\/sup><\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html
		
# Remove <strong> element if applied to Footnote End Text
		
sed -i 's/<p><strong>Footnote End.<\/strong><\/p>/<p>Footnote End.<\/p>/g' ./"$baseName"/"$baseName".html

# Add <aside> element + ARIA role="doc-footnote" to the beginning of a line that has text "Footnote Begin:"

perl -0777 -pi -e 's/<p>Footnote Begin:<\/p>/<aside role="doc-footnote" class="footnote">\n<p>Footnote Begin:<\/p>/g' ./"$baseName"/"$baseName".html

# Add closing </aside> element to the end of a line that has text "Footnote End."

perl -0777 -pi -e 's/<p>Footnote End.<\/p>/<p>Footnote End.<\/p>\n<\/aside>/g' ./"$baseName"/"$baseName".html

# Prevent script error when there is a % sign within <code> and <figcaption>

sed -i 's/\([0-9]\)\(%\)\( \)/\1%% /g' ./"$baseName"/"$baseName".html

# Transcriber's Notes:

# Replace Transcriber Summary Notes Tags with <div role="banner"> tags and remove all the line breaks in between

awk '/^<p>Transcriber Summary Begin:<\/p>/{a=1;b="<div role=\"banner\" class=\"transcriber-note-summary\"><p><strong>Transcriber\047s Notes:</strong></p>";next}/^<p>Transcriber Summary End.<\/p>/{a=0;print"</div>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Replace Transcriber Note with <aside> tag plus an aria-label "Transcriber's Note

awk '/^<p>Transcriber Note Begin:<\/p>/{a=1;b="<aside class=\"transcriber-note\" aria-label=\"transcriber note\"><p><strong>Transcriber\047s Note:</strong></p>";next}/^<p>Transcriber Note End.<\/p>/{a=0;print"</aside>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Move transcriber's Summary Notes before the Nav section of the document

grep "<div role=\"banner\"" ./"$baseName"/"$baseName".html > ./transcriber.txt
		
		
perl -0777 -pi -e 's/<div role="banner".*\n//g' ./"$baseName"/"$baseName".html
		
		
awk '/<nav/{system("cat ./transcriber.txt")}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html
		
rm ./transcriber.txt

# Replace Figfoot Tags with <aside role="note"> tags and remove all the line breaks in between

awk '/^<p>Figfooter Begin:<\/p>/{a=1;b="<aside role=\"note\" aria-label=\"Figure Footnote\" class=\"figure-footnote\">";next}/^<p>Figfooter End.<\/p>/{a=0;print"</aside></figure>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html	
		
# Remove "Footnote Begin: " text now that this section is wrapped in an <aside> tag with the proper role (doc-footnote) to avoid screen reader output redundancy.

perl -0777 -pi -e 's/\n<p>Footnote Begin:<\/p>//g' ./"$baseName"/"$baseName".html
		
# Remove "Footnote End." text now that this section is wrapped in an <aside> tag with the proper role (doc-footnote) to avoid screen reader output redundancy.		
	
perl -0777 -pi -e 's/\n<p>Footnote End.<\/p>//g' ./"$baseName"/"$baseName".html

# Add <aside> element + class="complimentary" to the beginning of a line that has text "Secondary Text Begin:"

perl -0777 -pi -e 's/<p>Secondary Text Begin:<\/p>/<aside role="complementary" class="complimentary">\n<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
		
# Same as above when tags are bold

perl -0777 -pi -e 's/<p><strong>Secondary Text Begin:<\/strong><\/p>/<aside role="complementary" class="complimentary">\n<p>Secondary Text Begin:<\/p>/g' ./"$baseName"/"$baseName".html
    
# Table Markup

# Remove <tbody> when it immediately follows <table> (Table header not marked in MS Word)

perl -0777 -pi -e 's/<table>\n<tbody>/<table>/g' ./"$baseName"/"$baseName".html

# Add class="table-body-start" when tables are marked with header row in MS Word

perl -0777 -pi -e 's/<\/thead>.*\n.*<tbody>.*\n.*<tr class="odd">/<\/thead>\n<tbody>\n<tr class="table-body-start">/g' ./"$baseName"/"$baseName".html

#### Adjusted in 1.7.0.4.1

# Add class="table-body-start" when tables are NOT marked with header row in MS Word (table has parent columns with column headers) and previous cell begins with <td>$ (column header)

# Adjusted (was missing </tr> in replace)

# perl -0777 -pi -e 's/(<td>\$.*\n).*<\/tr>.*\n.*<tr class="odd">/$1<\/tr>\n<\/thead>\n<tbody>\n<tr class="table-body-start">/g' ./"$baseName"/"$baseName".html

# Adjusted (was missing </tr>) in replace)

# perl -0777 -pi -e 's/(<td>\$.*\n).*<\/tr>.*\n.*<tr class="even">/$1<\/tr>\n<\/thead>\n<tbody>\n<tr class="table-body-start">/g' ./"$baseName"/"$baseName".html 

# Add class="table-body-start" when tables are NOT marked with header row in MS Word (table has parent columns with column headers) and previous cell begins with <td>0$ (not a column header)

#####

perl -0777 -pi -e 's/(<td>0\$<\/td>.*\n).*<\/tr>.*\n.*<tr class="odd">/$1<\/tr>\n<\/thead>\n<tbody>\n<tr class="table-body-start">/g' ./"$baseName"/"$baseName".html

# Add class="table-body-start" when tables are NOT marked with header row in MS Word (table has parent columns with column headers) and previous cell is empty - <td><\/td> (left over cells in the row, which occurs when cells are merged in the parent headers)

perl -0777 -pi -e 's/(<td><\/td>.*\n)(.*<\/tr>.*\n)(.*<tr class=.*\n)(.*<td>\d\^ tbody)/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">\n$4/g' ./"$baseName"/"$baseName".html

# Add <th scope="col"> markup (column Headers) to first row in table, which has <th> elements (table header)

# New in 1.6.8
	
sed -i 's/<th>/<th scope="col" id="th_#link_to_header#">/g' ./"$baseName"/"$baseName".html

#

perl -0777 -pi -e 's/<tr class="even">\n<td><\/td>\n<td><\/td>/<tr class="even">/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<tr class="even">\n<td><\/td>/<tr class="even">/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<tr class="odd">\n<td><\/td>\n<td><\/td>/<tr class="odd">/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<tr class="odd">\n<td><\/td>/<tr class="odd">/g' ./"$baseName"/"$baseName".html

# Remove CSS class="even" from <tr> elements that Pandoc exports
		
sed -i 's/ class="even"//g' ./"$baseName"/"$baseName".html
		
# Remove CSS class="odd" from <tr> elements that Pandoc exports
		
sed -i 's/ class="odd"//g' ./"$baseName"/"$baseName".html
		
# Place all of the text within Caption Begin...Caption End tags on one line
	
awk '/^<p>Caption Begin:<\/p>/{a=1;b="<caption>";next}/^<p>Caption End.<\/p>/{a=0;print"</caption>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html		
	
# Move table caption text inside the table element (<caption> is before the <table>

perl -0777 -pi -e 's/(.*<caption>.*)(\n)(<table>)/$3$2$1/g' ./"$baseName"/"$baseName".html
		
# Add class to cells at beginning of a row that should NOT be a header cells

perl -0777 -pi -e 's/(\n<tr>\n)(<td>0^ )/\n<tr class="no-row-header">\n<td>/g' ./"$baseName"/"$baseName".html 

perl -0777 -pi -e 's/(\n<tr>\n)(<td><p>0^ )/\n<tr class="no-row-header">\n<td><p>/g' ./"$baseName"/"$baseName".html

# Mark tbody in table when it is missing after a table with multiple parent columns and *the first cell in a row that is not a header cells

perl -0777 -pi -e 's/(<\/tr>\n)(<tr>\n)(<th scope="row">)(tbody)/$1<\/thead>\n$2<tbody>\n<td>/g' ./"$baseName"/"$baseName".html

# Add Row Headers to first column

perl -0777 -pi -e 's/(\n<tr>\n)(<td>)/$1<th scope="row">/g' ./"$baseName"/"$baseName".html 

perl -0777 -pi -e 's/(\n<tr class="table-body-start">\n)(<td>)/$1<th scope="row">/g' ./"$baseName"/"$baseName".html

sed -i 's/\(<th scope="row">.*\)\(<\/td>\)/\1<\/th>/g' ./"$baseName"/"$baseName".html

# Add <tbody> when "tbody" tag is used

perl -0777 -pi -e 's/(<tr class="no-row-header">.*\n)(.*<td>tbody)/<\/thead>\n<tbody>\n<tr class="table-body-start">\n<td>/g' ./"$baseName"/"$baseName".html

# Complex Tables (Irregular Column Headers)

# Create the master column headers (using 2-9 $)

# New (1.6.8)

# perl -0777 -pi -e 's/(<td>)([2-9])(\$ )(.*)(<\/td>)/<th colspan="$2" scope="colgroup">$4<\/th>/g' ./"$baseName"/"$baseName".html 

perl -0777 -pi -e 's/(<td>)([2-9])(\$ )(.*)(<\/td>)/<th colspan="$2" scope="colgroup" id="th_#link_to_header#">$4<\/th>/g' ./"$baseName"/"$baseName".html 

# New in 1.6.9

perl -0777 -pi -e 's/(<td>)([2-9])(\^)([1-9])(\$)(.*)(<\/td>)/<th rowspan="$2" colspan="$4" scope="colgroup" id="th_#link_to_header#">$6<\/th>/g' ./"$baseName"/"$baseName".html 

#

# Create the master column headers (using 2-9 $)

# perl -0777 -pi -e 's/(<th scope="row">)([2-9])(\$ )/<th colspan="$2" scope="colgroup">/g' ./"$baseName"/"$baseName".html 

perl -0777 -pi -e 's/(<th scope="row">)([2-9])(\$ )/<th colspan="$2" scope="colgroup" id="th_#link_to_header#">/g' ./"$baseName"/"$baseName".html 

# New in 1.7.0 *Replaced first line with second line

# perl -0777 -pi -e 's/(<th scope="row">)(\$)/<th scope="col">/' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row">)(\$)/<th scope="col" id="th_#link_to_header#">/' ./"$baseName"/"$baseName".html

#

# Create the master column headers (using 1 $)

# New in 1.7.0 *Replaced first line with second line

# perl -0777 -pi -e 's/(<td>)(1)(\$ )(.*)(<\/td>)/<th scope="col">$4<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<td>)(1)(\$ )(.*)(<\/td>)/<th scope="col" id="th_#link_to_header#">$4<\/th>/g' ./"$baseName"/"$baseName".html

# Create the Rowspan for top row (using NUMBER ^)
	
perl -0777 -pi -e 's/(<th scope="row">)([0-9])(\^)(@[0-9]+)(<\/th>)/<td rowspan="$2">$4<\/td>/g' ./"$baseName"/"$baseName".html

# New in 1.6.9

perl -0777 -pi -e 's/(<th scope="row">)([1-9])(\^\$)(@[0-9]+)/<th rowspan="$2" scope="colgroup" id="th_#link_to_header#">$4/g' ./"$baseName"/"$baseName".html 

# 



# Create the Rowspan for middle rows (using NUMBER ^)

# 1.6.9

perl -0777 -pi -e 's/(<th scope="row">)([1-9])(\^)([1-9])(\$)/<th rowspan="$2" colspan="$4" scope="colgroup" id="th_#link_to_header#">/g' ./"$baseName"/"$baseName".html

# 
	
perl -0777 -pi -e 's/(<th scope="row">)([1-9])(\^)/<th rowspan="$2" scope="rowgroup">/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row"><p>)(\d+)(\^)(.*\n.*\n.*\n)(.*)(<\/td>)/<th rowspan="$2" scope="rowgroup"><p>$4$5<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row"><p>)(\d+)(\^)(.*\n.*\n)(.*)(<\/td>)/<th rowspan="$2" scope="rowgroup"><p>$4$5<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row"><p>)(\d+)(\^)(.*\n)(.*)(<\/td>)/<th rowspan="$2" scope="rowgroup"><p>$4$5<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row"><p>)(\d+)(\^)(.*\n)(.*)(<\/td>)/<th rowspan="$2" scope="rowgroup"><p>$4$5<\/th>/g' ./"$baseName"/"$baseName".html

# Create the Rowspan for second column in top row (using NUMBER ^)
	
sed -i 's/\(<td>\)\([1-9]\)\(\^\)\(.*\)\(<\/td>\)/<th rowspan="\2" scope="rowgroup">\4<\/th>/g' ./"$baseName"/"$baseName".html

# Create the Rowspan for middle rows (using NUMBER ^) when there are more than 9 rows

perl -0777 -pi -e 's/(<th scope="row">)([1-9][0-9])(\^)/<th rowspan="$2" scope="rowgroup">/g' ./"$baseName"/"$baseName".html

# Create the colspan for the first cell (using 2-9 $)

perl -0777 -pi -e 's/(<th scope="row">)([2-9])(\$)(@[0-9]+)/<th colspan="$2" scope="colgroup" id="th_#link_to_header#">$4/g' ./"$baseName"/"$baseName".html

# Create the colspan for the first cell (using 1 $)

perl -0777 -pi -e 's/(<th scope="row">)(1)(\$)(@[0-9]+)/<th scope="col" id="th_#link_to_header#">$4/g' ./"$baseName"/"$baseName".html

# Convert cells that have 0 $ with SCOPE=ROW into <td> cells 

perl -0777 -pi -e 's/(<th scope="row">)(0)(\$)(<\/th>)/<td>\&nbsp;<\/td>/g' ./"$baseName"/"$baseName".html

## Fixed in 1.5.8 (replace 0$ with EMPTY)

# Convert cells that have 0 $ with SCOPE=COL into <td> cells 

perl -0777 -pi -e 's/(<th scope="col">)(0)(\$)(<\/th>)/<td>EMPTY<\/td>/g' ./"$baseName"/"$baseName".html

# Remove 0$ from cells that have <td>0$</td>

perl -0777 -pi -e 's/<td>0\$<\/td>/<td>EMPTY<\/td>/g' ./"$baseName"/"$baseName".html

# Remove 0$ from cells that have <td>0$</td>

perl -0777 -pi -e 's/<td>0\$<\/td>/<td>\&nbsp;<\/td>/g' ./"$baseName"/"$baseName".html

# Remove the scope=row from the first cell in the table if it has 0$

perl -0777 -pi -e 's/(<th scope="row">)(0)(\$)(@[0-9]+)(<\/th>)/<td>$4<\/td>/g' ./"$baseName"/"$baseName".html


## Begin Removal (1.7.0.3)


# step 1 (Move the @ tags before the row and add the <thead> element

# Only one line
# sed -zi 's/\(<tr>\n\)\(<th .*\)\(\@[[:digit:]]\+\)/~%~\3\n<thead>\n<tr>\n\2/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<tr>\n)(<th .*)(\@\d+)/~%~$3\n<thead>\n<tr>\n$2/g' ./"$baseName"/"$baseName".html


# Step 2 Add @ sign before each number in table formula

sed -i '/\~%~@/s/[[:digit:]]/\@&/2g' ./"$baseName"/"$baseName".html

# Step 3 Replace the @formula with the correct table markup

# perl -0777 -pi -e 's/(\@)([1-9])/<colgroup span="$2"><\/colgroup>\n/g'
sed -i '/\~%~/s/\(\@\)\([[:digit:]]\)/<colgroup span="\2"><\/colgroup>\n/g' ./"$baseName"/"$baseName".html

# Step 4 Remove Line Marker for tables

sed -i 's/~%~//g' ./"$baseName"/"$baseName".html

# Step 5 Remove the empty line between colgroup and <thead>

perl -0777 -pi -e 's/(<\/colgroup>\n)(\n)(<thead>)/$1$3/g' ./"$baseName"/"$baseName".html


#### End delete Section 1.7.0.3


# Delete empty first data cell in second row after first master row

perl -0777 -pi -e 's/(<tr>)(\n<th scope="row"><\/th>)/$1/g' ./"$baseName"/"$baseName".html

# New in 1.7.0 Replace First Line with second line

## Add column headers (<th scope="col">...</th>) in second row when they begin with $ 

# perl -0777 -pi -e 's/(<td>)(\$ )(.*)(<\/td>)/<th scope="col">$3<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<td>)(\$ )(.*)(<\/td>)/<th scope="col" id="th_#link_to_header#">$3<\/th>/g' ./"$baseName"/"$baseName".html

# New in 1.7.0 Replace First Line with Second Line

# Add column headers (<th scope="col">...</th>) in first row when they begin with scope=row 

# perl -0777 -pi -e 's/(<th scope="row">)(\$ )(.*)(<\/th>)/<th scope="col">$3<\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="row">)(\$ )(.*)(<\/th>)/<th scope="col" id="th_#link_to_header#">$3<\/th>/g' ./"$baseName"/"$baseName".html

#

# Add row headers (<th scope="row">...</th>) in second columns when they begin with ^ 

perl -0777 -pi -e 's/(<td>)(\^ )(.*)(<\/td>)/<th scope="row">$3<\/th>/g' ./"$baseName"/"$baseName".html

sed -i 's/<th scope="row">^ /<th scope="row">/g' ./"$baseName"/"$baseName".html

# Correct row headers if they still have 0^

sed -i 's/\(<th scope="row">0^ \)\(.*\)\(<\/th>\)/<td>\2<\/td>/g' ./"$baseName"/"$baseName".html

# Correct row headers when they still have 0^ and there are multiple paragraphs in the first cell

sed -i 's/\(<th scope="row"><p>0^ \)\(.*\)\(<\/p>\)/<td><p>\2\3/g' ./"$baseName"/"$baseName".html

sed -i 's/<th scope="row">0^<\/th>/<td>\&#160;<\/td>/g' ./"$baseName"/"$baseName".html

# New

# Rows that have a unordered list but that are not row headers
# 

perl -0777 -pi -e 's/<th scope="row"><ul>/<td><ul>/g' ./"$baseName"/"$baseName".html

sed -i 's/<li>0^ /<li>/g' ./"$baseName"/"$baseName".html


########## Begin Possible Deletion Section (1.7.0.3)

# Add opening <thead> element at the beginning of first row with master columns when master columns end with closing colgroup tag <\colgroup> tag

# perl -0777 -pi -e 's/<\/colgroup>\n<tr>/<\/colgroup>\n<thead>\n<tr>/g' ./"$baseName"/"$baseName".html

# Add opening <thead> element at the beginning of first row with master columns when master columns end with<col> tag

# perl -0777 -pi -e 's/<col>\n<tr>/<col>\n<thead>\n<tr>/g' ./"$baseName"/"$baseName".html


######### End Possible Deletion Section (1.7.0.3)


## Table Footer Markup ##

# Replace Footer Begin: with <tfoot>

perl -0777 -pi -e 's/(<\/table>\n)(<p>Footer Begin:<\/p>)/<tfoot><tr>/g' ./"$baseName"/"$baseName".html

# Replace Footer Begin: with <tfoot> when Footer Begin: is bold

perl -0777 -pi -e 's/(<\/table>\n)(<p><strong>Footer Begin:<\/strong><\/p>)/<tfoot><tr>/g' ./"$baseName"/"$baseName".html

# Replace Footer End with </tfoot>

perl -0777 -pi -e 's/<p>Footer End.<\/p>/<\/td>\n<\/tr><\/tfoot>\n<\/table>/g' ./"$baseName"/"$baseName".html

# Replace Footer End with </tfoot> when Footer End. is bold

perl -0777 -pi -e 's/<p><strong>Footer End.<\/strong><\/p>/<\/td>\n<\/tr><\/tfoot>\n<\/table>/g' ./"$baseName"/"$baseName".html

# Add correct colspan number to table footer based on the NUMBER % in the first line

perl -0777 -pi -e 's/(<tfoot><tr>\n)(<p>)([0-9]+)(%)/$1<td colspan="$3"><p>/g' ./"$baseName"/"$baseName".html

# Add correct colspan number to table footer based on the NUMBER % in the first line when the % and number has <strong> tag

perl -0777 -pi -e 's/(<tfoot><tr>\n)(<p><strong>)([0-9]+)(%)/$1<td colspan="$3"><p><strong>/g' ./"$baseName"/"$baseName".html

# Add accessibility markup for blank table cells

sed -i 's/<td><\/td>/<td>\&nbsp;<\/td>/g' ./"$baseName"/"$baseName".html

# Remove empty cells in a row that has column headers

sed -i '/<td>\&nbsp;<\/td>/N;/^\(.*\)\n\1$/!P; D' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<\/th>)(\n<td>\&nbsp;<\/td>)/$1/g' ./"$baseName"/"$baseName".html

sed -i 's/<td>EMPTY<\/td>/<td>\&nbsp;<\/td>/g' ./"$baseName"/"$baseName".html

## Add <tbody> after a row ending with a cell that has "colgroup" and before a row beginning with "rowspan"

# perl -0777 -pi -e 's/(scope="colgroup" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<tr>.*\n)(.*<th rowspan)/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">\n$4/g' ./"$baseName"/"$baseName".html

## Add <tbody> after a row ending with a cell that has "colgroup" and before a row beginning with scope="row"

# perl -0777 -pi -e 's/(scope="colgroup" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<tr>.*\n)(.*<th scope="row")/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">\n$4/g' ./"$baseName"/"$baseName".html

## Correct multiple <thead> elements when there are two rowgroups when there are multiple rows that have a rowgroup

# perl -0777 -pi -e 's/(scope="colgroup" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<\/thead>.*\n.*<tbody>.*\n<tr class="table-body-start">.*\n)/$1\<\/tr>\n<tr>\n/g' ./"$baseName"/"$baseName".html

## Add <tbody> when a table has no <thead> element and the first row starts with a header cell that has scope="row"

perl -0777 -pi -e 's/(<\/caption>.*\n)(.*<tr>.*\n)(.*<th scope="row">)/$1<tbody>\n$2$3/g' ./"$baseName"/"$baseName".html

# perl -0777 -pi -e 's/(scope="colgroup" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<tr class="no-row-header">)/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">/g' ./"$baseName"/"$baseName".html

# New in 1.7.0

# Add closing </thead> and opening <tbody> when they are missing from tables that have multiple column headers

# perl -0777 -pi -e 's/(scope="col" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<tr>.*\n)(.*<th scope="row">)/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">\n$4/g' ./"$baseName"/"$baseName".html

# perl -0777 -pi -e 's/(scope="col" id="th_#link_to_header#">.*\n)(.*<\/tr>.*\n)(.*<tr>.*\n)(.*<th rowspan)/$1$2<\/thead>\n<tbody>\n<tr class="table-body-start">\n$4/g' ./"$baseName"/"$baseName".html

#

# Add ARIA- Label "table Footer" to the <tfoot> element

sed -i 's/<tfoot>/<tfoot aria-label="Table Footer">/g' ./"$baseName"/"$baseName".html

# Make cells with 0$ be a data cell not a header cell.

sed -i 's/<th scope="row"><p>0\$/<td><p>/g' ./"$baseName"/"$baseName".html

# New in 1.7.0

# Remove Blank in Table Row header cells

sed -i 's/<th scope="row">EMPTY<\/th>/<th scope="row"><\/th>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<th scope="col" )(id="th_.*)(>EMPTY<\/th>)/$1$2><\/th>/g' ./"$baseName"/"$baseName".html

# Remove empty rows if there are more than two column headers

perl -0777 -pi -e 's/(<tr class="table-body-start">)(.*\n<th scope="row"><\/th>)(.*\n<\/tr>)/$1/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<tr>.*\n)(<td>&nbsp;<\/td>.*\n)(<\/tr>.*\n)//g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<tr class="table-body-start">)(.*\n<tr>)/$1/g' ./"$baseName"/"$baseName".html

#

# Add progressive numbers to table headers

awk '{for(x=1;x<=NF;x++)if($x~/#link_to_header#/){sub(/#link_to_header#/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# 

### New in 1.7.0.4

# Put space between $ and number if there is none

sed -i 's/\(>\$\)\([0-9]\)/\1 \2/g' ./"$baseName"/"$baseName".html

# Add missing <tbody> if it is missing

perl -0777 -pi -e 's/(<th scope="col" .*<\/th>)(\n<\/tr>)(\n<tr>)(.*\n<th scope="row")/$1$2\n<\/thead>\n<tbody>\n<tr class="table-body-start">$4/g' ./"$baseName"/"$baseName".html

# New in 1.7.2

perl -0777 -pi -e 's/(<th scope="col" .*<\/th>)(\n<\/tr>)(\n<tr>)(.*\n<th rowspan)/$1$2\n<\/thead>\n<tbody>\n<tr class="table-body-start">$4/g' ./"$baseName"/"$baseName".html

#


perl -0777 -pi -e 's/(<th scope="col" .*<\/th>)(\n<\/tr>)(\n<tr>)(.*\n<th colspan)/$1$2\n<\/thead>\n<tbody>\n<tr class="table-body-start">$4/g' ./"$baseName"/"$baseName".html


# perl -0777 -pi -e 's/(scope="colgroup" .*<\/th>)(\n<\/tr>)(\n<tr>)(.*\n<th scope="row")/$1$2\n<\/thead>\n<tbody>\n<tr class="table-body-start">$4/g' ./"$baseName"/"$baseName".html

# perl -0777 -pi -e 's/(th colspan="\d" scope="colgroup" .*<\/th>)(.*\n<\/tr>)(.*\n<tr>)(.*\n<th scope="row")/$1$2\n<\/thead>\n<tbody>\n<tr class="table-body-start">$4/g' ./"$baseName"/"$baseName".html

# sed -zi 's/\(<\/th>\)\(\n<\/tr>\n\)\(<tr>\n\)\(<th scope="row"\)/\1\2<\/thead>\n<tbody>\n<tr class="table-body-start">\n\4/g' ./"$baseName"/"$baseName".html

# Add missing <thead> if it is missing

# perl -0777 -pi -e 's/(<\/th>)(\n<\/tr>)(\n<tbody>)/$1$2\n<\/thead>$3/g' ./"$baseName"/"$baseName".html

###

# Add closing </aside> element to the end of a line that has text "Secondary Text End."

perl -0777 -pi -e 's/<p>Secondary Text End.<\/p>/<p>Secondary Text End.<\/p>\n<\/aside>/g' ./"$baseName"/"$baseName".html

# Same as above when tags are bold

perl -0777 -pi -e 's/<p><strong>Secondary Text End.<\/strong><\/p>/<p>Secondary Text End.<\/p>\n<\/aside>/g' ./"$baseName"/"$baseName".html

# Headings #

# Add tabindex="0" to Heading 6 for easier keyboard navigation by page

sed -i 's/<h6 /<h6 tabindex="0" /g' ./"$baseName"/"$baseName".html

# Lists #

# Remove opening <p> tags inside list items

sed -i 's/<li><p>/<li>/g' ./"$baseName"/"$baseName".html

# Remove closing </p> tags inside list items

sed -i 's/<\/p><\/li>/<\/li>/g' ./"$baseName"/"$baseName".html

# Add missing closing </li> tag from item at the first level of an ordered list

sed -i 's/\(<li>.*\)\(<\/p>\)/\1<\/li>/g' ./"$baseName"/"$baseName".html

# Remove stray closing </li> tag from item at the first level of an ordered list

sed -i 's/<\/ul><\/li>/<\/ul>/g' ./"$baseName"/"$baseName".html

# Remove stray closing </li> tag from the last item of an ordered list

sed -i 's/<\/ol><\/li>/<\/ol>/g' ./"$baseName"/"$baseName".html

# Clean up nested list error: remove closing </li> tag that appears before a new ordered list 

perl -0777 -pi -e 's/(<\/li>)(\n<ol)/$2/g' ./"$baseName"/"$baseName".html

# Clean up nested list error: remove closing </li> tag that appears before a new unordered list 

perl -0777 -pi -e 's/(<\/li>)(\n<ul)/$2/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has THREE nested ordered lists

perl -0777 -pi -e 's/<\/ol>\n<\/ol>\n<\/ol>\n<\/ol>/<\/ol>\n<\/li>\n<\/ol>\n<\/li>\n<\/ol>\n<\/li>\n<\/ol>/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has TWO nested ordered lists

perl -0777 -pi -e 's/<\/ol>\n<\/ol>\n<\/ol>/<\/ol>\n<\/li>\n<\/ol>\n<\/li>\n<\/ol>/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has One nested ordered lists

perl -0777 -pi -e 's/<\/ol>\n<\/ol>/<\/ol>\n<\/li>\n<\/ol>/g' ./"$baseName"/"$baseName".html

echo -ne '#############              \033[1;33m(66%)\033[0m\r'
sleep 1

# Fix nested list error 

perl -0777 -pi -e 's/<\/ol>\n<li>/<\/ol>\n<\/li>\n<li>/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has THREE nested unordered lists

perl -0777 -pi -e 's/<\/ul>\n<\/ul>\n<\/ul>\n<\/ul>/<\/ul>\n<\/li>\n<\/ul>\n<\/li>\n<\/ul>\n<\/li>\n<\/ul>/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has TWO nested unordered lists

perl -0777 -pi -e 's/<\/ul>\n<\/ul>\n<\/ul>/<\/ul>\n<\/li>\n<\/ul>\n<\/li>\n<\/ul>/g' ./"$baseName"/"$baseName".html

# Add closing </li> tag in a list that has One nested unordered lists

perl -0777 -pi -e 's/<\/ul>\n<\/ul>/<\/ul>\n<\/li>\n<\/ul>/g' ./"$baseName"/"$baseName".html

# Add missing </li> tag in the middle of an nested unordered list

 perl -0777 -pi -e 's/<\/li>\n<\/ul>\n<li>/<\/li>\n<\/ul>\n<\/li>\n<li>/g' ./"$baseName"/"$baseName".html

# Add missing </li> tag in the middle of an nested unordered list when there is one TAB

 perl -0777 -pi -e 's/<\/li>\n<\/ul>\t\n<li>/<\/li>\n<\/ul>\n<\/li>\n<li>/g' ./"$baseName"/"$baseName".html

# Add missing </li> tag in the middle of an nested unordered list when there are two TABs

 perl -0777 -pi -e 's/<\/li>\n<\/ul>\t\t\n<li>/<\/li>\n<\/ul>\n<\/li>\n<li>/g' ./"$baseName"/"$baseName".html

 # Remove spurious </p> tag before a nested ordered list
 perl -0777 -pi -e 's/(<li>.*)(<\/p>)(\n<ol)/$1$3/g' ./"$baseName"/"$baseName".html
 
  # Remove spurious </p> tag before a nested ordered list
 perl -0777 -pi -e 's/(<li>.*)(<\/p>)(\n<ul)/$1$3/g' ./"$baseName"/"$baseName".html
 
 # Add <br> between two paragraphs within one list item
 
 perl -0777 -pi -e 's/<\/li>\n<p>/<br>\n/g' ./"$baseName"/"$baseName".html

# Add Lanugage Markup

if [ -n "$language1" ];

then

# Languages #

# Switch the order of @@@ and <em> element if the <em> element comes before the @@@ tag.

sed -i 's/<em>@@@/@@@<em>/g' ./"$baseName"/"$baseName".html

# Multiple Inline languages

sed -i 's/>@@@9/ lang="'"$language9"'" xml:lang="'"$language9"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###9/<span lang="'"$language9"'" xml:lang="'"$language9"'" class="language">/g' ./"$baseName"/"$baseName".html	

sed -i 's/>@@@8/ lang="'"$language8"'" xml:lang="'"$language8"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###8/<span lang="'"$language8"'" xml:lang="'"$language8"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@7/ lang="'"$language7"'" xml:lang="'"$language7"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###7/<span lang="'"$language7"'" xml:lang="'"$language7"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@6/ lang="'"$language6"'" xml:lang="'"$language6"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###6/<span lang="'"$language6"'" xml:lang="'"$language6"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@5/ lang="'"$language5"'" xml:lang="'"$language5"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###5/<span lang="'"$language5"'" xml:lang="'"$language5"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@4/ lang="'"$language4"'" xml:lang="'"$language4"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###4/<span lang="'"$language4"'" xml:lang="'"$language4"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@3/ lang="'"$language3"'" xml:lang="'"$language3"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###3/<span lang="'"$language3"'" xml:lang="'"$language3"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/>@@@2/ lang="'"$language2"'" xml:lang="'"$language2"'" class="language">/g' ./"$baseName"/"$baseName".html
	
sed -i 's/###2/<span lang="'"$language2"'" xml:lang="'"$language2"'" class="language">/g' ./"$baseName"/"$baseName".html
#

# Add language markup xml lang="foo" and lang="foo" to text where the main language switches *at the beginning* of text (paragraphs, headings etc.). Use the variable "$language", which is entered manually after the script in the terminal, to enter the proper ISO value

sed -i 's/>@@@1/ lang="'"$language1"'" xml:lang="'"$language1"'" class="language">/g' ./"$baseName"/"$baseName".html
	
# Add language markup <xml lang="foo" and lang="foo"> to text where the main language switches *in the middle* of a paragraph. Uses the same  variable "$language".	
		
sed -i 's/###1/<span lang="'"$language1"'" xml:lang="'"$language1"'" class="language">/g' ./"$baseName"/"$baseName".html	

# Add closing </span> tags for text areas where the secondary language ends in the middle of the paragraph.
	
sed -i 's/%%%/<\/span>/g' ./"$baseName"/"$baseName".html
		
# Clean Up order of closing </span> tags when the secondary language text also includes formatting.

sed -i 's/<\/span>,<\/em>/<\/em>,<\/span>/g' ./"$baseName"/"$baseName".html

sed -i -E 's/(<em>“)(<span lang=".*">)/\2\1/g' ./"$baseName"/"$baseName".html

sed -i -E 's/(<em>")(<span lang=".*">)/\2\1/g' ./"$baseName"/"$baseName".html

sed -i 's/~~#/<mark><span lang="'"$language1"'" xml:lang="'"$language1"'" class="language">/g' ./"$baseName"/"$baseName".html

sed -i 's/##\$/<span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="dotted">/g' ./"$baseName"/"$baseName".html

sed -i 's/##^/<span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="dashed">/g' ./"$baseName"/"$baseName".html

sed -i 's/##+/<span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="doubleunderline">/g' ./"$baseName"/"$baseName".html

sed -i 's/#~\$/<mark><span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="dotted">/g' ./"$baseName"/"$baseName".html

sed -i 's/#~^/<mark><span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="dashed">/g' ./"$baseName"/"$baseName".html

sed -i 's/#~+/<mark><span lang="'"$language1"'" xml:lang="'"$language1"'" class="language" class="doubleunderline">/g' ./"$baseName"/"$baseName".html

fi

# Add Opening Tags for Fancy Formatting

sed -i 's/~~\$/<mark><span class="dotted">/g' ./"$baseName"/"$baseName".html

sed -i 's/~~^/<mark><span class="dashed">/g' ./"$baseName"/"$baseName".html

sed -i 's/~~+/<mark><span class="doubleunderline">/g' ./"$baseName"/"$baseName".html

# Add Closing Tags for Fancy Formatting

sed -i 's/\*\*%/<\/span><\/mark>/g' ./"$baseName"/"$baseName".html

# Remove "Secondary Text Begin:" text

perl -0777 -pi -e 's/(\n)(<p>Secondary Text Begin:<\/p>)//g' ./"$baseName"/"$baseName".html

# Remove "Secondary Text End." text

perl -0777 -pi -e 's/(\n)(<p>Secondary Text End.<\/p>)//g' ./"$baseName"/"$baseName".html

# Change <b> to <strong>

sed -i 's/<b>/<strong>/g' ./"$baseName"/"$baseName".html

sed -i 's/<\/b>/<\/strong>/g' ./"$baseName"/"$baseName".html

# Change <i> to <em>

sed -i 's/<i>/<em>/g' ./"$baseName"/"$baseName".html

sed -i 's/<\/i>/<\/em>/g' ./"$baseName"/"$baseName".html

# Figures #

## Change alternative text that is marked as "decorative" to alt="" (Null-alt) and give it the proper ARIA role (presentation).
		
sed -i 's/alt="decorative"/alt="" role="presentation"/g' ./"$baseName"/"$baseName".html
		
## Change alternative text that is marked as "Decorative" to alt="" (Null-alt) and give it the proper ARIA role (presentation).
		
sed -i 's/alt="Decorative"/alt="" role="presentation"/g' ./"$baseName"/"$baseName".html
		
## Change alternative text that is marked as "Decorative" to alt="" (Null-alt) and give it the proper ARIA role (presentation).
		
sed -i 's/alt="DECORATIVE"/alt="" role="presentation"/g' ./"$baseName"/"$baseName".html
		
## Change alternative text that is marked as alt=" " to alt="" (Null-alt) and give it the proper ARIA role (presentation).
		
sed -i 's/alt=" "/alt="" role="presentation"/g' ./"$baseName"/"$baseName".html

# 1.5.1 Change

awk '/^<p>Figcaption Begin:<\/p>/{a=1;b="<figcaption>";next}/^<p>Figcaption End.<\/p>/{a=0;print"</figcaption>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html
			
# Replace Figcaption Begin: with <figcaption> tag

sed -i 's/<p>Figcaption Begin:<\/p>/<figcaption>/g' ./"$baseName"/"$baseName".html

# Replace Figcaption End. with </figcaption> tag

sed -i 's/<p>Figcaption End.<\/p>/<\/figcaption>/g' ./"$baseName"/"$baseName".html

# Move <figcaption> onto same line as text

perl -0777 -pi -e 's/<figcaption>\n<p>/<figcaption><p>/g' ./"$baseName"/"$baseName".html

# Move </figcaption> onto same line as text

perl -0777 -pi -e 's/<\/p>\n<\/figcaption>/<\/p><\/figcaption>/g' ./"$baseName"/"$baseName".html

# Move <figcaption> before the <img> tag

perl -0777 -pi -e 's/(<p><img.*>)(<\/p>)(\n)(<figcaption>.*<\/figcaption>)/$4\n$1$2/g'  ./"$baseName"/"$baseName".html

## Add <figure> element around images that no caption

# perl -0777 -pi -e 's/(<p>)(<img.* \/>)(<\/p>)/<figure>$2<\/figure>/;t'  ./"$baseName"/"$baseName".html

perl -i -pe 's/(<p>)(<img.*\/>)(<\/p>)/<figure>$2<\/figure>/g' ./"$baseName"/"$baseName".html 

## Remove <figure> element before image if there is a <figcaption>

perl -0777 -pi -e 's/(<\/figcaption>\n)(<figure>)/$1/g'  ./"$baseName"/"$baseName".html

## Add <figure role="group"> element before <figcaption> tag

sed -i 's/<figcaption>/<figure role="group"><figcaption>/g' ./"$baseName"/"$baseName".html

## Extended Descriptions

# Remove </figure> tag if it is followed by a new line that has "Description Begin:" text

perl -0777 -i -pe 's/(<\/figure>)(\n)(<p>Description Begin:<\/p>)/\n$3/g' ./"$baseName"/"$baseName".html

# Replace Description Begin tags with <details> and <summary> tags

perl -0777 -pi -e 's/<p>Description Begin:<\/p>/<details><summary>Extended Description:<\/summary>/g' ./"$baseName"/"$baseName".html

perl -0777 -i -pe 's/<p>Description Begin:<\/p>/<details><summary>Extended Description:<\/summary>/g' ./"$baseName"/"$baseName".html

# Remove "Description End." text

perl -0777 -pi -e 's/<p>Description End.<\/p>\n/<\/details><\/figure>\n/g' ./"$baseName"/"$baseName".html

# Catch missing Remove "Description End." text (missing </p>) # New

perl -0777 -pi -e 's/<p>Description End.\n/<\/details>\n<\/figure>\n/g' ./"$baseName"/"$baseName".html

# Remove <figure> closing tag when there are footnotes for figures

perl -0777 -pi -e 's/(<\/details><\/figure>.*\n)(.*<aside role="note")/<\/details>\n$2/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<\/figure>.*\n)(.*<aside role="note")/\n$2/g' ./"$baseName"/"$baseName".html

# Math

# Remove spurious backslashes within math equations that have text style (as long as the equations are on their own lines)

sed -i 's/\(\\text{.*\)\\ \(.*}\)/\1 \2/g' ./"$baseName"/"$baseName".html

## New in 1.7.1

#

# Find and replace the &amp; with &

sed -i 's/&amp\; /\& /g' ./"$baseName"/"$baseName".html

sed -i 's/<mi>&amp\;<\/mi>//g' ./"$baseName"/"$baseName".html

sed -i 's/\\\& /\& /g' ./"$baseName"/"$baseName".html

#

# New in 1.7.7

# Correct code for displaying Desmos graphs

sed -i 's/<p>&lt;iframe/<iframe/g' ./"$baseName"/"$baseName".html

sed -i 's/&gt;&lt;\/iframe&gt;<\/p>/><\/iframe>/g' ./"$baseName"/"$baseName".html

sed -i 's/frameborder=0//g' ./"$baseName"/"$baseName".html

sed -i 's/500px/500/g' ./"$baseName"/"$baseName".html 

#

# Correct YouTube Embed Code

sed -i 's/frameborder="0"/style="border: 1px solid #ccc"/g'  ./"$baseName"/"$baseName".html 

#

# Correct Amara Embed Code

sed -i 's/<p>&lt;div class="amara/<div class="amara/g' ./"$baseName"/"$baseName".html 

sed -i 's/"null"&gt;&lt;\/div&gt;<\/p>/"null"><\/div>/g' ./"$baseName"/"$baseName".html

sed -i 's/<p>https:\/\/amara.org\/en\/videos\//<div class="amara-embed" data-hide-logo="true" data-width="560px" data-initial-language="en" data-show-subtitles-default="true" data-video-id="/g' ./"$baseName"/"$baseName".html

sed -i 's/\/info\/.*\/<\/p>/" data-team="null"><\/div>/g' ./"$baseName"/"$baseName".html

grep -c "data-team=\"null\"" ./"$baseName"/"$baseName".html | sed -i "s/<script /<script src=\"https:\/\/amara.org\/embedder-iframe\"><\/script><script /" ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<\/script><script/<\/script>\n<script/g' ./"$baseName"/"$baseName".html

#


# Blockquotes:

perl -0777 -pi -e 's/<p>Citation Begin:<\/p>/<footer class="blockquote-footer">/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<p>Citation End.<\/p>/<\/footer>\n<\/blockquote>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<p>Quote Begin:<\/p>/<blockquote>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<p>Quote End.<\/p>/<\/blockquote>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<\/blockquote>\n)(<footer class="blockquote-footer">)(\n<blockquote>)/$2/g' ./"$baseName"/"$baseName".html

# NEW 1.6.8

perl -0777 -pi -e 's/(<\/blockquote>\n)(<footer class="blockquote-footer">)/$2/g' ./"$baseName"/"$baseName".html

#

perl -0777 -pi -e 's/(<\/blockquote>\n)(<\/footer>\n)(<\/blockquote>)/$3/g' ./"$baseName"/"$baseName".html

# Remove spurious blockquotes when "Secondary Text End." tag is indented.

perl -0777 -pi -e 's/(<blockquote>)(\n<\/aside>\n)(<\/blockquote>)//g' ./"$baseName"/"$baseName".html

# Correct path to the images in files
		
perl -0777 -pi -e 's/(src=".*)(\\media\\)/src=".\/media\//g' ./"$baseName"/"$baseName".html

# Fix Incorrect Figure Formatting (<figure role="group"> before <figure>)

perl -0777 -pi -e 's/(<figure role="group">)(\n)(<figure>)/$1/g'  ./"$baseName"/"$baseName".html

# Fix Incorrect Figure Formatting (<\figure> before <figcaption>)

perl -0777 -pi -e 's/(<\/figure>)(\n)(<figcaption>)/$3/g'  ./"$baseName"/"$baseName".html

# Fix incorrect closing <\/p> tags after the <img> element

sed -i 's/" \/><\/p><\/p>/" \/><\/p>/g' ./"$baseName"/"$baseName".html

# Clean up Complex tables
# Add correct table row header markup when there are multiple paragraphs in cell

sed -i 's/\(<td><p>^ \)\(.*<\/p>\)/<th scope="row"><p>\2/g' ./"$baseName"/"$baseName".html

# Add correct table row header markup when there are multiple paragraphs in cell and there is a missing closing </p> tag

sed -i 's/\(<td><p>^ \)\(.*\)/<th scope="row"><p>\2<\/p>/g' ./"$baseName"/"$baseName".html

# Replace $ tag at the end of a  bulleted list with closing </th> tag

perl -0777 -pi -e 's/($<\/li>\n)(<\/ul><\/td>)/<\/li>\n<\/ul><\/th>/g' ./"$baseName"/"$baseName".html

# New in 1.7.2

#

perl -0777 -pi -e 's/><p>\^ /><p>/g' ./"$baseName"/"$baseName".html

sed -zi 's/$<\/li>\n<\/ul><\/td>/<\/li>\n<\/ul><\/th>/g' ./"$baseName"/"$baseName".html

#


# Replace $ tag at the end of a  multiparagraph row header with closing </th> tag

sed -i 's/\(\$\)\(<\/p>\)\(<\/td>\)/\2<\/th>/g' ./"$baseName"/"$baseName".html

# Table skip links

# Add skip link before <table> element

perl -0777 -pi -e 's/(<table>)/<p><a href="#table_#link_to_table#">Skip table<\/a><\/p>\n$1/g'  ./"$baseName"/"$baseName".html

# Add skip link target after the </table> element

perl -0777 -pi -e 's/(<\/table>)/$1\n<a id="table_%link_to_table%" tabindex="-1" aria-label="Table Skipped"><\/a>/g'  ./"$baseName"/"$baseName".html

# Add progressive numbers to skip link for tables

awk '{for(x=1;x<=NF;x++)if($x~/#link_to_table#/){sub(/#link_to_table#/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Add progressive numbers to skip link target link for tables

awk '{for(x=1;x<=NF;x++)if($x~/%link_to_table%/){sub(/%link_to_table%/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Add ARIA Labelledby ID (page-"foo") to the page numbers of the document.

sed -i 's/\(id=\)\("page-[0-9]*"\)/aria-labelledby=\2 \1\2/g' ./"$baseName"/"$baseName".html

# Assign an ARIA labelledby value to all of the Secondary Text and Footnote text areas for each page, for easier navigation and for better screen reader verbosity.

sed -i '
/aria-labelledby="page-/{
h
s/.*\( aria-labelledby="page-[0-9]*"\).*/\1/
x
s/ aria-labelledby="page-[0-9]*"//
}
/aside role="\(doc-footnote\|complementary\)"/{
G
s/aside\(.*\)\n\(.*\)/aside\2\1/
}' ./"$baseName"/"$baseName".html

# Remove ARIA role of "complementary"

sed -i 's/role="complementary" //g' ./"$baseName"/"$baseName".html

sed -i 's/\(aria-labelledby="\)\(page[0-9]*\)\("\)\( role="doc-footnote"\)/aria-label="\2 footnote region"\4/g' ./"$baseName"/"$baseName".html

# Add <div> for responsive table markup

perl -0777 -pi -e 's/<table>/<div class="table-container" tabindex="0">\n<table>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<\/table>/<\/table>\n<\/div>/g' ./"$baseName"/"$baseName".html

# Clean up missing <p> tags at the beginning of a line

perl -0777 -pi -e 's/\n<strong>/\n<p><strong>/g' ./"$baseName"/"$baseName".html

# Add aria-label and heading to End Notes section when there are footnotes

perl -0777 -pi -e 's/doc-endnotes\">\n<hr \/>/doc-endnotes\">\n<hr aria-label=\"End Notes Section\"\/>\n<h2>End Notes<\/h2>/g' ./"$baseName"/"$baseName".html

# Remove aria role=doc-endnotes from Footnotes section

sed -i 's/<section class=\"footnotes\" role=\"doc-endnotes\">/<section class=\"footnotes\">/g' ./"$baseName"/"$baseName".html

# Add horizontal rule to <aside> element for footnotes

perl -0777 -pi -e 's/<aside class=\"footnote\"/<hr aria-label=\"Extra Content. Press Tab to go to next page\"\/>\n<aside class=\"footnote\"/g' ./"$baseName"/"$baseName".html

# Add horizontal rule to <aside> element for secondary text

perl -0777 -pi -e 's/<aside aria-labelledby/<hr aria-label=\"Extra Content. Press Tab to go to next page\"\/>\n<aside aria-labelledby/g' ./"$baseName"/"$baseName".html

# Remove horizontal rule when there is both a footnotes section and a secondary text section

perl -0777 -pi -e 's/<\/aside>\n<hr aria-label=\"Extra Content. Press Tab to go to next page\"\/>/<\/aside>/g' ./"$baseName"/"$baseName".html

# Remove Horizontal line for Transcriber's notes

perl -0777 -pi -e 's/(<hr aria-label=\"Extra Content. Press Tab to go to next page\"\/>\n)(<aside aria-label="page[0-9]*)( Transcriber)/$2$3/g' ./"$baseName"/"$baseName".html

# Add "Return to text" aria-label for left pointing arrows in Footnotes section

sed -i 's/role=\"doc-backlink\"/aria-label=\"Return to Text\" role=\"doc-backlink\"/g' ./"$baseName"/"$baseName".html

# Correct duplicate values for footnote regions when there are two footnote regions on a single page (inside secondary text and inside main body)

perl -0777 -pi -e 's/(<\/aside.*\n.*)(.*<\/aside>.*\n)(<aside aria-label="page\d)/$1$2$3 main body/g' ./"$baseName"/"$baseName".html

# Remove duplicate </figure> tags

sed -i 's/<\/figure><\/figure>/<\/figure>/g' ./"$baseName"/"$baseName".html

# Fill in the blank tags - 2 underscores (middle of a sentence)

sed -i 's/ __ /<span role="math" aria-label="fill in the blank"> _____ <\/span>/g' ./"$baseName"/"$baseName".html

# Fill in the blank tags - 2 underscores (beginning of a sentence)

sed -i 's/<p>__ /<p><span role="math" aria-label="fill in the blank">_____ <\/span>/g' ./"$baseName"/"$baseName".html

# Fill in the blank tags - 2 underscores (end of a sentence)

sed -i 's/ __<\/p>/<span role="math" aria-label="fill in the blank"> _____<\/span><\/p>/g' ./"$baseName"/"$baseName".html

# Fill in the blank tags - 2 underscores (end of a sentence)

sed -i 's/ ­­__<\/p>/<span role="math" aria-label="fill in the blank"> _____<\/span><\/p>/g' ./"$baseName"/"$baseName".html

# Fill in the blank tags - 2 underscores (on its own line)

sed -i 's/<p>__<\/p>/<p><span role="math" aria-label="fill in the blank">_____<\/span><\/p>/g' ./"$baseName"/"$baseName".html

# Fill in the answer checkbox

sed -i 's/=== /<span role="math" aria-label="fill in the answer bubble">\&#9633\; <\/span>/g' ./"$baseName"/"$baseName".html

# Fill in the answer bubble

sed -i 's/``` /<span role="math" aria-label="fill in the answer bubble">\&#9675\; <\/span>/g' ./"$baseName"/"$baseName".html

# Code Blocks

# Correct percent signs so that script can perform correctly

perl -i -pe 's/%&gt;%/%%&gt;%%/g' ./"$baseName"/"$baseName".html

awk '/^<p>Code Begin:<\/p>/{a=1;b="<pre>";next}/^<p>Code End.<\/p>/{a=0;print"</pre>";next}a{printf b$0;b="";next}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

perl -i -pe 's%(<pre>.*?</pre>)% $1 =~ s/<p>/<code>/gr %eg' ./"$baseName"/"$baseName".html

perl -i -pe 's%(<pre>.*?</pre>)% $1 =~ s/<\/p>/<\/code>/gr %eg' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<code>/\n<code>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<\/code><\/pre>/<\/code>\n<\/pre>/g' ./"$baseName"/"$baseName".html

sed -i 's/&lt;&lt;&lt;/<code>/g' ./"$baseName"/"$baseName".html

sed -i 's/&gt;&gt;&gt;/<\/code>/g' ./"$baseName"/"$baseName".html

# restore percent signs after script has processed code correctly
perl -i -pe 's/%%&gt;%%/%&gt;%/g' ./"$baseName"/"$baseName".html

sed -i 's/\([0-9]\)\(%%\)\( \)/\1% /g' ./"$baseName"/"$baseName".html

sed -i 's/\(<td colspan="[1-9]"><p>\)\(% \)/\1/g' ./"$baseName"/"$baseName".html

sed -i 's/\(<td colspan="[1-9][0-9]"><p>\)\(% \)/\1/g' ./"$baseName"/"$baseName".html

# Find lines with missing <p> tags and add them

perl -0777 -pi -e 's/(<p>.*[^>])(\n)/$1<\/p>\n/g'  ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<p>.*<\/span>)(\n)/$1<\/p>\n/g' ./"$baseName"/"$baseName".html

# Remove </p> tags that appear at the end of a display equation opening block

# sed -i 's/\(<p><span class="math display">.*\)\(<\/p>\)/\1/g' ./"$baseName"/"$baseName".html

# sed -i 's/\(<p><span class="math inline">.*\)\(<\/p>\)/\1/g' ./"$baseName"/"$baseName".html

# Correct missing </p>

perl -0777 -pi -e 's/(<p>.*)(<\/em>\n)/$1<\/em><\/p>\n/g' ./"$baseName"/"$baseName".html

# Remove empty hyperlinks

sed -i 's/\(<a href="about:blank">\)\(.*\)\(<\/a>\)/\2/g' ./"$baseName"/"$baseName".html

sed -i 's/_edited<\/title>/<\/title>/g' ./"$baseName"/"$baseName".html

#

# Remove extra </p> if they exist after \begin matrix}

sed -i 's/\\begin{bmatrix}<\/p>/\\begin{bmatrix}/g' ./"$baseName"/"$baseName".html

sed -i 's/\\begin{matrix}<\/p>/\\begin{matrix}/g' ./"$baseName"/"$baseName".html

#

# Add Footnotes

if [ -n "$footnote" ]; then

if grep -q 'doc-footnote' ./"$baseName"/"$baseName".html; then
			
# Remove MS Word hyperlinks

sed -i 's/\(<a href="about:blank#.*>\)\(<sup>.*<\/sup>\)\(<\/a>\)/\2/g' ./"$baseName"/"$baseName".html

# Add Footnotes to document

# Add <br> after each line in Footnote section

sed -i '/role="doc-footnote"/,\%<\/aside%s:$:<br>:' ./"$baseName"/"$baseName".html

# Remove <br> when it appears after list elements (which is invalid)

sed -i 's/<\/li><br>/<\/li>/g' ./"$baseName"/"$baseName".html

sed -i 's/<ul><br>/<ul>/g' ./"$baseName"/"$baseName".html

sed -i 's/<\/ul><br>/<\/ul>/g' ./"$baseName"/"$baseName".html

# Catch footnote referents that may be superscripted and make them normal

perl -0777 -pi -e 's/(<br>\n)(<p>)(<sup>)([0-9]+)(<\/sup>)/$1$2$4/g' ./"$baseName"/"$baseName".html

# Add space between footnote reference and text if there is none.

perl -0777 -pi -e 's/(<br>\n)(<p>)([0-9]+)([A-Za-z])/$1$2$3 $4/g' ./"$baseName"/"$baseName".html

# Account for footnotes that may already be in the MS Word document

sed -i 's/noteref"><sup>/noteref"><sup >/g'  ./"$baseName"/"$baseName".html 

# Account for bookmarks that may already be in the MS Word Document

sed -i 's/\(<a href="#.*>\)\(<sup>\)/\1<sup >/g'  ./"$baseName"/"$baseName".html

# Add hyperlink for footnotes (superscripted numbers)

perl -pi -e 's/(<sup>)([0-9]+)(<\/sup>)/<a id="$2-#footnote#-footnote" href="#$2-%footnote%-referent" class="footnote" role="doc-noteref">$1$2$3<\/a>/g' ./"$baseName"/"$baseName".html

# Add hyperlink for footnote references followed by a period in footnote region.

perl -0777 -pi -e 's/(<br>\n)(<p>)([0-9]+)(\.)/$1<p id="$3-#referent#-referent"><a href="#$3-%referent%-footnote" aria-label="footnote $3" role="doc-backlink" class="footnote" title="Go to note reference">$3$4<\/a>/g' ./"$baseName"/"$baseName".html

# Add hyperlink for footnote references followed by a space in footnote region.

perl -0777 -pi -e 's/(<br>\n)(<p>)([0-9]+)( )/$1<p id="$3-#referent#-referent"><a href="#$3-%referent%-footnote" aria-label="footnote $3" role="doc-backlink" class="footnote" title="Go to note reference">$3<\/a> /g' ./"$baseName"/"$baseName".html

# Remove hyperlinks that were incorrectly created for superscripted numbers in the TOC

sed -i 's/\(<li>\)\(<a href="#.*\)\(<a id=".*>\)\(<sup>.*<\/a>\)\(<\/a>\)/\1\2\4/g' ./"$baseName"/"$baseName".html

# Add progressive numbers to footnotes

awk '{for(x=1;x<=NF;x++)if($x~/#referent#/){sub(/#referent#/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Add progressive numbers to footnotes

awk '{for(x=1;x<=NF;x++)if($x~/%referent%/){sub(/%referent%/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Add progressive numbers to footnotes

awk '{for(x=1;x<=NF;x++)if($x~/#footnote#/){sub(/#footnote#/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

# Add progressive numbers to footnotes

awk '{for(x=1;x<=NF;x++)if($x~/%footnote%/){sub(/%footnote%/,++i)}}1' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

fi

fi

# Add Line Numbers

if [ -n "$linenumbers" ];

then

# Reformat lines that have a space plus a year at the end
# New in 1.6.2 (years must have two spaces before them to differentiate between line number that have four digits) 

		perl -0777 -pi -e 's/(  )([0-9][0-9][0-9][0-9])(<\/p>)/$2$3/g' ./"$baseName"/"$baseName".html

# Line breaks (1-6-7)		
		perl -0777 -pi -e 's/(  )([0-9][0-9][0-9][0-9])(<br \/>)/$2$3/g' ./"$baseName"/"$baseName".html

# Wrap line numbers that appear at the end of a line in an <aside> element with ARIA landmark role="complementary" for easier navigation and screen reader output.

		perl -0777 -pi -e 's/ ([0-9]+)(<\/p>)\n/<\/p>\n<aside class="line-number" aria-label="line number $1">$1<\/aside>\n/g' ./"$baseName"/"$baseName".html
		
# Line breaks (1-6-7)

		perl -0777 -pi -e 's/ ([0-9]+)(<br \/>)\n/<br \/>\n<aside class="line-number" aria-label="line number $1">$1<\/aside>\n/g' ./"$baseName"/"$baseName".html
		
# Clean up <aside> elements for line numbers
		
		perl -0777 -pi -e 's/(\n<p>.*)(<aside .*>)([0-9]+)(<\/aside>)(<\/p>)/$2$3$4$1$5/g' ./"$baseName"/"$baseName".html

# Wrap line numbers that appear at the *beginning* of a line in an <aside> element with ARIA landmark role="complementary" for easier navigation and screen reader output.		
		
		perl -0777 -pi -e 's/\n(<p>)([0-9]+ )/\n<aside class="line-number" aria-label="line number $2">$2<\/aside>\n<p>/g' ./"$baseName"/"$baseName".html
		
# Line breaks (1-6-7)

		perl -0777 -pi -e 's/(<br \/>\n)([0-9]+ )/<br \/>\n<aside class="line-number" aria-label="line number $2">$2<\/aside>\n/g' ./"$baseName"/"$baseName".html

# Add back the space before the year

		perl -0777 -pi -e 's/([0-9][0-9][0-9][0-9])(,)([0-9][0-9][0-9][0-9])(<\/p>)/$1$2 $3$4/g' ./"$baseName"/"$baseName".html
		
		perl -0777 -pi -e 's/([0-9][0-9][0-9][0-9])(<br \/>)/ $1$2/g' ./"$baseName"/"$baseName".html
		
# Fix stray paragraph tags when line breaks are present

perl -0777 -pi -e 's/(<p>)(.*)(<br \/>)/$2$3/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<br \/>.*)(\n)(.*<\/p>)/$1$2$3<br \/>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/<\/p><br \/>/<br \/>/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(<p>.*)(<\/p>)(<br \/><br \/>)/$1$2/g' ./"$baseName"/"$baseName".html

fi

echo -ne '########################## \033[1;32mDone.\033[0m\r'
echo -ne '\n'

if [ -n "$footnote" ]; then

if ! grep -q 'doc-footnote' ./"$baseName"/"$baseName".html; then

echo -e "\n\033[1;33mATTENTION:\033[0m No Footnote regions were detected in \033[1;32m"$baseName".html\033[0m! You must use \"Footnote Begin...Footnote End\" tags in MS Word for the script to add foonotes."

fi

fi

# Remove Markup 

if [ -n "$remove" ];

then

# Remove MS Word hyperlinks for footnotes

sed -i 's/\(<a href="about:blank#.*>\)\(<sup>.*<\/sup>\)\(<\/a>\)/\2/g' ./"$baseName"/"$baseName".html

fi

# Add Better alternative text for math equations

if grep -q "title=\"" ./"$baseName"/"$baseName".html; then

if [ -n "$speech" ]; then

## Move title="*" onto its own line

perl -pi -e 's/ title="/\ntitle="/g' ./"$baseName"/"$baseName".html

## Move alt="*" onto its own line

perl -pi -e 's/(alt=".*")(\n)/\n$1$2/g' ./"$baseName"/"$baseName".html

## New in 1.7.1

# Correct Multiple lines when there are matrices

# Move alt="*" onto its own line if there are matrices

sed -i 's/\\begin{bmatrix}<\/p>/\\begin{bmatrix}/g' ./"$baseName"/"$baseName".html

sed -i 's/\\begin{matrix}<\/p>/\\begin{matrix}/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt="\\begin{bmatrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt="\\begin{matrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title="\\begin{bmatrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title="\\begin{matrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt=".*)(\\begin{matrix})(\n)/$1$2/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title=".*)(\\begin{matrix})(\n)/$1$2/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt=".*)(\\begin{matrix})/\n$1$2/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/\\\\\n/\\\\ /g' ./"$baseName"/"$baseName".html

# End New

## Put two dollar signs around the the math equations

perl -0777 -pi -e 's/(\n)(alt=")(.*)(")(\n)/$1\$\$$3\$\$$5/g' ./"$baseName"/"$baseName".html

# Extract display equations
sed -n 's/\(\$\$\)\(.*\)\(\$\$\)/\2/p' ./"$baseName"/"$baseName".html > ./display-log.txt

# Place spacein front of minus sign if it begins the LaTeX equation (causes a LaTeX parsing error)

sed -i 's/^-/ -/g' ./display-log.txt

# New in 1.7.4

# Remove comma within equations

perl -pi -e 's/&lt;/\\lt/g' ./display-log.txt

perl -pi -e 's/\\&amp;/\\ & /g' ./display-log.txt

perl -pi -e 's/&amp;/&/g' ./display-log.txt

perl -pi -e 's/\\\&/\&/g' ./display-log.txt

perl -pi -e 's/∰/\\iiint\\limits/g' ./display-log.txt

perl -pi -e 's/,//g' ./display-log.txt

## New in 1.7.4

sed -i 's/~/ /g' ./display-log.txt

sed -i '/\\text/ s/^/"/' ./display-log.txt

sed -i '/^"/ s/$/"/' ./display-log.txt

##

# Insert place marker for display equations

sed -i 's/\(\$\$\)\(.*\)\(\$\$\)/@@ \2/g' ./"$baseName"/"$baseName".html

# Delete Empty lines

sed -i '/^\s*$/d' ./display-log.txt

## Correct incorrect LaTex Code

sed -i 's/"//g'  ./display-log.txt

# New in 1.7.4
# Remove backslash SPACE if it exists within \text commands

perl -0777 -i -wpe's{(\\text\{ (?:(?!\\text\{|\}).)*? \})}{ $1 =~ s/\\ / /gr }egmsx' ./display-log.txt

# Remove zero-width spaces from math text

sed -i 's/\xe2\x80\x8b//g' ./display-log.txt 

sed -i 's/\xe2\x80\x8d//g' ./display-log.txt 

#

sed -i 's/\\%/%/g'  ./display-log.txt

perl -CD -i -wpe 's/\N{REPLACEMENT CHARACTER}//g' ./display-log.txt

# End New

touch ./display-log2.txt

##################

# New in 0.2.0

if [[ "$inspect" == "on" ]]; then 

echo -ne '\n'

mv ./display-log.txt ./"$baseName"/

mv ./display-log2.txt ./"$baseName"/

cp ./"$baseName"/display-log.txt ./"$baseName"/latex_full.txt

count=1
while IFS="" read -r p || [ -n "$p" ] ; do echo -ne "Processing equations... \033[1;33m$count\033[0m\r" ; tex2svg "$p" >> ./"$baseName"/display-log2.txt  ; count=$[ $count + 1 ] ; done <./"$baseName"/display-log.txt 

count=$[ $count - 1 ]

cp ./"$baseName"/display-log2.txt ./"$baseName"/svg_full.txt

sed -i -n 's/.*1-Title">//p' ./"$baseName"/display-log2.txt

IFS=$IFS_OLD

# Remove txt files

rm ./"$baseName"/display-log.txt 

# Delete Empty lines

sed -i '/^\s*$/d' ./"$baseName"/display-log2.txt 

# Remove <\/title>

sed -i 's/<\/title>//g' ./"$baseName"/display-log2.txt 

# Correct speech markup

# Remove "reverse solidus" text within equations that have text style

sed -i -e 's/ reverse-solidus//g' ./"$baseName"/display-log2.txt 


### Add More Corrections Here #####

# sed -i -e 's/ reverse-solidus//g' ./"$baseName"/display-log2.txt 

# 

# Add String to beginning of each line

sed -i -e 's/^/@@ /' ./"$baseName"/display-log2.txt 

cp ./"$baseName"/display-log2.txt ./"$baseName"/TTS_full.txt

	#### New in 0.1.7
	
	# Make Corrections
	
sed -i 's/ quotation-mark//g' ./"$baseName"/TTS_full.txt	

sed -i 's/ slash/ divided by/g' ./"$baseName"/TTS_full.txt

sed -i 's/ percent-sign/ percent/g' ./"$baseName"/TTS_full.txt

sed -i 's/ StartFraction/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ EndFraction/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ upper/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ left-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ right-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ right-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ comma //g' ./"$baseName"/TTS_full.txt

####

touch ./"$baseName"/math_equations.html

echo -e "<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml" lang="en">\n<head>\n<title>"$baseName" - Review Equations</title>\n<style>\n</style>\n</head>\n<body>\n<main>\n<h1>"$baseName" - Review Equations</h1>" | cat - ./"$baseName"/math_equations.html > temp && mv temp ./"$baseName"/math_equations.html

COUNTER=1
eval MAX=$count
Headers="<h2>Equation</h2>"

while (( $COUNTER <= $MAX )); do
        echo -e "<div>\n<h2>"$COUNTER"</h2>\n<p><textarea id=\"equation_"$COUNTER"\">\n@@\n</textarea></p>\n</div>" >> ./"$baseName"/math_equations.html
        let COUNTER=$COUNTER+1
done

#

echo -e "</main>\n<footer>\n<p role=\"contentinfo\">This document was created by the Alternative Media Unit of the Disabled Students' Program at UC Berkeley. For questions or concerns about this document, please contact us at dspamc@berkeley.edu.</p>\n</footer>\n</main>\n</body>\n</html>" >> ./"$baseName"/math_equations.html

perl -pi -e 's/<\/h2>/<\/h2>\n<p><code>\n##\n<\/code><\/p>\n<p>\n%%\n<\/p>/g' ./"$baseName"/math_equations.html

sed -i -e 's/^/## /g' ./"$baseName"/latex_full.txt

# Add line marker before SVG line

perl -0777 -pi -e 's/<svg /&&&\n<svg /g' ./"$baseName"/svg_full.txt

# Move SVG components onto the same line

awk '/^&&&/{a=1;b="";next}/^<\/svg>/{a=0;print"</svg>";next}a{printf b$0;b="";next}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

# Correct the IDs for each SVG to make them distinct

sed -i 's/aria-labelledby="MathJax-SVG-1-Title"/aria-labelledby="svg_title_~~~"/g' ./"$baseName"/svg_full.txt

sed -i 's/title id="MathJax-SVG-1-Title"/title id="svg_title_%%%"/g' ./"$baseName"/svg_full.txt

awk '{for(x=1;x<=NF;x++)if($x~/~~~/){sub(/~~~/,++i)}}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

awk '{for(x=1;x<=NF;x++)if($x~/%%%/){sub(/%%%/,++i)}}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

# Add math class to SVG files

sed -i -e 's/<svg /<svg class="math" /g' ./"$baseName"/svg_full.txt

# Add String to beginning of each line

sed -i -e 's/^/%% /' ./"$baseName"/svg_full.txt

mv ./"$baseName"/latex_full.txt ./

mv ./"$baseName"/svg_full.txt ./

mv ./"$baseName"/TTS_full.txt ./

awk '
    /^##/{                   
        getline <"./latex_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
awk '
    /^%%/{                   
        getline <"./svg_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
awk '
    /^@@/{                   
        getline <"./TTS_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
rm ./latex_full.txt

rm ./svg_full.txt
	
sed -i 's/^\(## \)*//g' ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g' ./"$baseName"/math_equations.html

sed -i 's/^\(@@ \)*//g'	./"$baseName"/math_equations.html

sed -zi 's/\(id="equation_[[:digit:]]\+>\)\(\n\)/\1/g' ./"$baseName"/math_equations.html

sed -i "s/<svg /<svg class="math" /g"	./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\n.math {\nbackground-color: #E7FFE7 ;\ndisplay: inline-block\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\ncode {\nbackground: #f4f4f4;background: #f4f4f4;\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\n.alt-text {\nbackground-color: #E6E6FA ;\ndisplay: inline-block\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\nh2 {\ncolor:blue;\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/(id="equation.*)(\n)/$1/g' ./"$baseName"/math_equations.html

cp ./TTS_full.txt ./"$baseName"/TTS_full_2.txt

rm ./TTS_full.txt 

sed -i 's/^\(@@ \)*//g'	./"$baseName"/TTS_full_2.txt

awk '{filename = sprintf("equation_%d.txt", NR); print >filename; close(filename)}' ./"$baseName"/TTS_full_2.txt

mv ./equation_*.txt ./"$baseName"/

rm ./"$baseName"/TTS_full_2.txt

echo -ne 'Processing equations... \033[1;32mDone.\033[0m\r'

echo -ne '\n\n'

echo -ne 'Opening MS Edge...'

echo -ne '\n\n'

cwd=$(pwd)

start msedge "$cwd/$baseName/math_equations.html"

while true; do

read -n1 -p "Would you like to correct the alternative text of math equations in $(echo -e "\033[1;44m$baseName.html\033[0m\x1B[49m\x1B[K")? [Y/N]?" answer

case $answer in
Y | y) 
	   echo -e "\n"
	   correct=on
	   break
	   ;;
	   
N | n) 
	   echo -e "\n"
	   correct=off
	   break
	   ;;	
	*)
	   echo -e "\n"
       echo -e "\033[1;31mError: Invalid entry\033[0m "$answer". \033[1;31mYou must enter one of the following values: [ y / n].\033[0m\n"
	   ;;

	   
esac

done

if [[ "$correct" == "on" ]]; then 

function alt_text_math {
if [ ! -f  "./$baseName/equation_new_$CHOICE.txt" ]; then 

sed -i -e 's/^## //' ./"$baseName"/equation_$CHOICE.txt

touch ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_$CHOICE.txt ./"$baseName"/equation_new_$CHOICE.txt

perl -pi -e 's/(equation_'$CHOICE'">.*\n)/$1<\/textarea><\/p>/' ./"$baseName"/math_equations.html

sed -i -e 's/^/%% /g' ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_new_$CHOICE.txt ./pronunciation.txt

awk '
    /^%%/{                   
        getline <"./pronunciation.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g'	./"$baseName"/math_equations.html

rm ./pronunciation.txt

#echo -ne '\n'

#echo -e "Refresh MS Edge browser (CTRL +R) to see the new alternative text for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K")."

fi

}

function equation_pronunciation {

echo -ne '\n'

read -p "Enter the correct pronunciation for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K"):" value

echo "$value" > ./"$baseName"/equation_new_$CHOICE.txt

perl -pi -e 's|(id="equation_'$CHOICE'">)(.*\n)|$1\n%%\n|g' ./"$baseName"/math_equations.html

perl -pi -e 's|^%%.*|%% |g' ./"$baseName"/math_equations.html

sed -i -e 's/^/%% /g' ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_new_$CHOICE.txt ./pronunciation.txt

awk '
    /^%%/{                   
        getline <"./pronunciation.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g'	./"$baseName"/math_equations.html

perl -pi -e 's|(id="equation_'$CHOICE'">.*)(\n)|$1|g' ./"$baseName"/math_equations.html

rm ./pronunciation.txt

echo -ne '\n'

echo -ne "Alternative text for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K") changed. Refresh MS Edge browser (CTRL +R) to see changes."

echo -ne '\n\n'

}

while :; do

	read -p "Enter the equation number $(echo -e "\033[1;44m(1-$MAX)\033[0m\x1B[49m\x1B[K"), or $(echo -e "\033[1;44mq\033[0m\x1B[49m\x1B[K") to exit:" CHOICE
    
	if [[ "$CHOICE" == "q" ]] ; then
	
	break;
	
	fi;
	
	if [[ "$CHOICE" -le "$MAX" ]] ; then
	
	alt_text_math
	
	equation_pronunciation
	
	else
	
	echo -e "\n\033[1;31mError: Invalid number\033[0m "$CHOICE". \033[1;31mYou must enter a number between\033[0m 1 \033[1;31mand\033[0m" $MAX"\033[1;31m.\033[0m\n"
	
	fi;
	
	done
	
	echo -ne '\n'

fi

touch ./"$baseName"/all.txt

counter_math=1
for x in ./"$baseName"/equation_*.txt; do

        basePath=${x%.*}
        Name=${basePath##*/}

if [ -f ./"$baseName"/equation_new_$counter_math.txt ]; then

perl -pi -e 's|^%% ||g' ./"$baseName"/equation_new_$counter_math.txt

cat ./"$baseName"/equation_new_$counter_math.txt > ./"$baseName"/equation_$counter_math.txt		
		
fi

if [ -f ./"$baseName"/equation_$counter_math.txt ]; then	

cat ./"$baseName"/equation_$counter_math.txt >> ./"$baseName"/all.txt

fi

counter_math=$[ $counter_math + 1 ] ; 
done

rm ./"$baseName"/equation_*.txt
sed -i -e 's/^/@@ /' ./"$baseName"/all.txt 
mv ./"$baseName"/all.txt ./"$baseName"/display-log2.txt
rm ./"$baseName"/math_equations.html

while true; do

read -n1 -p "Would you like to perform find and replace functions for the alternative text of math equations in $(echo -e "\033[1;44m$baseName.html\033[0m\x1B[49m\x1B[K")? [Y/N]?" answer

case $answer in
Y | y) 
	   echo -e "\n"
	   replace_correct=on
	   break
	   ;;
	   
N | n) 
	   echo -e "\n"
	   replace_correct=off
	   break
	   ;;	
	*)
	   echo -e "\n"
       echo -e "\033[1;31mError: Invalid entry\033[0m "$answer". \033[1;31mYou must enter one of the following values: [ y / n].\033[0m\n"
	   ;;

	   
esac

done

function replace_pronunciation {

while :; do

	read -p "Enter the word(s) that you wish to replace (type q and press Enter to exit):" find
	
	if [[ "$find" == "q" ]] ; then
	
	break;
	
	fi;

	#echo -e "\n"

read -p "Enter the word(s) that you wish to use instead of $(echo -e "\033[1;44m$find\033[0m\x1B[49m\x1B[K") (press enter to replace with NOTHING):" replace

sed -i "s/$find/$replace/gI" ./"$baseName"/display-log2.txt

if [[ ! $replace ]] ; then

echo -e "\n\033[1;44m$find\033[0m\x1B[49m\x1B[K removed.\n"

else 

echo -e "\n\033[1;44m$find\033[0m\x1B[49m\x1B[K changed to \033[1;44m$replace\033[0m\x1B[49m\x1B[K.\n"

fi
	
done

#echo -e "\n"

}

if [[ "$replace_correct" == "on" ]]; then 

replace_pronunciation

fi

mv ./"$baseName"/display-log2.txt ./

# Add String to beginning of each line

perl -pi -e 's|^@@ ||g' ./display-log2.txt

sed -i -e 's/^/@@ alt="/' ./display-log2.txt

### Remove spurious Unicode characters, such Synchronous idle

perl -CD -i -wpe 's/\N{SYNCHRONOUS IDLE}//g' ./display-log2.txt

###

# End New in 0.2.0

else

echo -ne '\n'

count=$1
while IFS="" read -r p || [ -n "$p" ] ; do echo -ne "Processing equations... \033[1;33m$count\033[0m\r" ; tex2svg "$p" | sed -n 's/.*1-Title">//p' >> display-log2.txt ; count=$[ $count + 1 ] ; done <./display-log.txt

IFS=$IFS_OLD

echo -ne 'Processing equations... \033[1;32mDone.\033[0m\r'
echo -ne '\n'

# Remove txt files

rm ./display-log.txt

# Delete Empty lines

sed -i '/^\s*$/d' ./display-log2.txt

# Remove <\/title>

sed -i 's/<\/title>//g' ./display-log2.txt

# Correct speech markup


# Add String to beginning of each line

sed -i -e 's/^/@@ alt="/' ./display-log2.txt

# Insert equations into txt file

# Replace display equations with lines from display-log2.txt

fi

awk '
    /^@@/{                   
        getline <"./display-log2.txt" 
    }
    1                      
    ' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

### New	
	
sed -i '/@@/s/quotation-mark//g' ./"$baseName"/"$baseName".html	

sed -i '/@@/s/slash/divided by/g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/percent-sign/percent/g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/StartFraction/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/EndFraction/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/upper/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/left-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/right-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/right-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/ comma //g' ./"$baseName"/"$baseName".html

###
	
# Replace placeholder text

sed -i -e 's/@@ //g' ./"$baseName"/"$baseName".html
    
# Remove txt files

rm ./display-log2.txt

# Reposition alternative text on the same line in the HTML file

perl -0777 -pi -e 's/(\n)(alt=")/ $2/g' ./"$baseName"/"$baseName".html

# Remove title text containing LaTeX (redundant output for screen reader). Requires Pandoc version 2.10 and up (class = math)

# perl -0777 -pi -e 's/(\n)(title=")/" $2/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(\n)(title=".*" )(class="math)/" $3/g' ./"$baseName"/"$baseName".html

# Place title text back in correct place if there are footnotes in the document

perl -0777 -pi -e 's/(\n)(title=".*")/ $2/g' ./"$baseName"/"$baseName".html

fi

fi

if grep -q "title=\"" ./"$baseName"/"$baseName".html; then

if [ -n "$SVG" ]; then

## New in 1-7-0-4

sed -i '/<p><img style=/s/\\%/%/g' ./"$baseName"/"$baseName".html

sed -i '/<p><img style=/s/\\\%/%/2g' ./"$baseName"/"$baseName".html

sed -i '/<p><img style=/s/~/ /2g' ./"$baseName"/"$baseName".html

# perl -pi -e 's/\\&(?!#\d+;)amp;//g if /<p><img/' ./"$baseName"/"$baseName".html

##

## Move title="*" onto its own line

perl -pi -e 's/ title="/\ntitle="/g' ./"$baseName"/"$baseName".html

## Move alt="*" onto its own line

perl -pi -e 's/(alt=".*")(\n)/\n$1$2/g' ./"$baseName"/"$baseName".html

## New in 1.7.1

# Correct Multiple lines when there are matrices

# Move alt="*" onto its own line if there are matrices

#

sed -i 's/\\begin{bmatrix}<\/p>/\\begin{bmatrix}/g' ./"$baseName"/"$baseName".html

sed -i 's/\\begin{matrix}<\/p>/\\begin{matrix}/g' ./"$baseName"/"$baseName".html

#

perl -pi -0777 -e 's/(alt="\\begin{bmatrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt="\\begin{matrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title="\\begin{bmatrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title="\\begin{matrix})(\n)/\n$1/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt=".*)(\\begin{matrix})(\n)/$1$2/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(title=".*)(\\begin{matrix})(\n)/$1$2/g' ./"$baseName"/"$baseName".html

perl -pi -0777 -e 's/(alt=".*)(\\begin{matrix})/\n$1$2/g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/\\\\\n/\\\\ /g' ./"$baseName"/"$baseName".html

# End New

## Put two dollar signs around the the math equations

perl -0777 -pi -e 's/(\n)(alt=")(.*)(")(\n)/$1\$\$$3\$\$$5/g' ./"$baseName"/"$baseName".html

# Extract display equations
sed -n 's/\(\$\$\)\(.*\)\(\$\$\)/\2/p' ./"$baseName"/"$baseName".html > ./display-log.txt

# Place spacein front of minus sign if it begins the LaTeX equation (causes a LaTeX parsing error)

sed -i 's/^-/ -/g' ./display-log.txt

# Insert place marker for display equations

sed -i 's/\(\$\$\)\(.*\)\(\$\$\)/@@ \2/g' ./"$baseName"/"$baseName".html

# Delete Empty lines

sed -i '/^\s*$/d' ./display-log.txt

## Correct incorrect LaTex Code

# Begin New in 1.7.4

# Remove comma within equations

perl -pi -e 's/&lt;/\\lt/g' ./display-log.txt

perl -pi -e 's/\\&amp;/\\ & /g' ./display-log.txt

perl -pi -e 's/&amp;/&/g' ./display-log.txt

perl -pi -e 's/\\\&/\&/g' ./display-log.txt

perl -pi -e 's/∰/\\iiint\\limits/g' ./display-log.txt

perl -pi -e 's/,//g' ./display-log.txt

## New in 0.1.7

sed -i 's/~/ /g' ./display-log.txt

sed -i '/\\text/ s/^/"/' ./display-log.txt

sed -i '/^"/ s/$/"/' ./display-log.txt

##

# Delete Empty lines

sed -i '/^\s*$/d' ./display-log.txt

# New in 0.1.7

sed -i 's/~/ /g' ./display-log.txt

sed -i 's/"//g'  ./display-log.txt

# New in 0.2.0
# Remove backslash SPACE if it exists within \text commands

perl -0777 -i -wpe's{(\\text\{ (?:(?!\\text\{|\}).)*? \})}{ $1 =~ s/\\ / /gr }egmsx' ./display-log.txt

# Remove zero-width spaces from math text

sed -i 's/\xe2\x80\x8b//g' ./display-log.txt

sed -i 's/\xe2\x80\x8d//g' ./display-log.txt

#

sed -i 's/\\%/%/g'  ./display-log.txt

####

touch ./display-log2.txt

##################

# New in 0.2.0

if [[ "$inspect" == "on" ]]; then 

echo -ne '\n'

mv ./display-log.txt ./"$baseName"/

mv ./display-log2.txt ./"$baseName"/

cp ./"$baseName"/display-log.txt ./"$baseName"/latex_full.txt

count=1
while IFS="" read -r p || [ -n "$p" ] ; do echo -ne "Processing equations... \033[1;33m$count\033[0m\r" ; tex2svg "$p" >> ./"$baseName"/display-log2.txt  ; count=$[ $count + 1 ] ; done <./"$baseName"/display-log.txt 

count=$[ $count - 1 ]

cp ./"$baseName"/display-log2.txt ./"$baseName"/svg_full.txt

sed -i -n 's/.*1-Title">//p' ./"$baseName"/display-log2.txt

IFS=$IFS_OLD

# Remove txt files

rm ./"$baseName"/display-log.txt 

# Delete Empty lines

sed -i '/^\s*$/d' ./"$baseName"/display-log2.txt 

# Remove <\/title>

sed -i 's/<\/title>//g' ./"$baseName"/display-log2.txt 

# Correct speech markup

# Remove "reverse solidus" text within equations that have text style

sed -i -e 's/ reverse-solidus//g' ./"$baseName"/display-log2.txt 


### Add More Corrections Here #####

# sed -i -e 's/ reverse-solidus//g' ./"$baseName"/display-log2.txt 

# 

# Add String to beginning of each line

sed -i -e 's/^/@@ /' ./"$baseName"/display-log2.txt 

cp ./"$baseName"/display-log2.txt ./"$baseName"/TTS_full.txt

	#### New in 0.1.7
	
	# Make Corrections
	
sed -i 's/ quotation-mark//g' ./"$baseName"/TTS_full.txt	

sed -i 's/ slash/ divided by/g' ./"$baseName"/TTS_full.txt

sed -i 's/ percent-sign/ percent/g' ./"$baseName"/TTS_full.txt

sed -i 's/ StartFraction/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ EndFraction/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ upper/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ left-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ right-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ right-parenthesis/ /g' ./"$baseName"/TTS_full.txt

sed -i 's/ comma //g' ./"$baseName"/TTS_full.txt

####

touch ./"$baseName"/math_equations.html

echo -e "<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml" lang="en">\n<head>\n<title>"$baseName" - Review Equations</title>\n<style>\n</style>\n</head>\n<body>\n<main>\n<h1>"$baseName" - Review Equations</h1>" | cat - ./"$baseName"/math_equations.html > temp && mv temp ./"$baseName"/math_equations.html

COUNTER=1
eval MAX=$count
Headers="<h2>Equation</h2>"

while (( $COUNTER <= $MAX )); do
        echo -e "<div>\n<h2>"$COUNTER"</h2>\n<p><textarea id=\"equation_"$COUNTER"\">\n@@\n</textarea></p>\n</div>" >> ./"$baseName"/math_equations.html
        let COUNTER=$COUNTER+1
done

#

echo -e "</main>\n<footer>\n<p role=\"contentinfo\">This document was created by the Alternative Media Unit of the Disabled Students' Program at UC Berkeley. For questions or concerns about this document, please contact us at dspamc@berkeley.edu.</p>\n</footer>\n</main>\n</body>\n</html>" >> ./"$baseName"/math_equations.html

perl -pi -e 's/<\/h2>/<\/h2>\n<p><code>\n##\n<\/code><\/p>\n<p>\n%%\n<\/p>/g' ./"$baseName"/math_equations.html

sed -i -e 's/^/## /g' ./"$baseName"/latex_full.txt

# Add line marker before SVG line

perl -0777 -pi -e 's/<svg /&&&\n<svg /g' ./"$baseName"/svg_full.txt

# Move SVG components onto the same line

awk '/^&&&/{a=1;b="";next}/^<\/svg>/{a=0;print"</svg>";next}a{printf b$0;b="";next}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

# Correct the IDs for each SVG to make them distinct

sed -i 's/aria-labelledby="MathJax-SVG-1-Title"/aria-labelledby="svg_title_~~~"/g' ./"$baseName"/svg_full.txt

sed -i 's/title id="MathJax-SVG-1-Title"/title id="svg_title_%%%"/g' ./"$baseName"/svg_full.txt

awk '{for(x=1;x<=NF;x++)if($x~/~~~/){sub(/~~~/,++i)}}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

awk '{for(x=1;x<=NF;x++)if($x~/%%%/){sub(/%%%/,++i)}}1' ./"$baseName"/svg_full.txt > tmp && mv tmp ./"$baseName"/svg_full.txt

# Add math class to SVG files

sed -i -e 's/<svg /<svg class="math" /g' ./"$baseName"/svg_full.txt

# Add String to beginning of each line

sed -i -e 's/^/%% /' ./"$baseName"/svg_full.txt

mv ./"$baseName"/latex_full.txt ./

mv ./"$baseName"/svg_full.txt ./

mv ./"$baseName"/TTS_full.txt ./

awk '
    /^##/{                   
        getline <"./latex_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
awk '
    /^%%/{                   
        getline <"./svg_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
awk '
    /^@@/{                   
        getline <"./TTS_full.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html
	
rm ./latex_full.txt
	
sed -i 's/^\(## \)*//g' ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g' ./"$baseName"/math_equations.html

sed -i 's/^\(@@ \)*//g'	./"$baseName"/math_equations.html

sed -zi 's/\(id="equation_[[:digit:]]\+>\)\(\n\)/\1/g' ./"$baseName"/math_equations.html

sed -i "s/<svg /<svg class="math" /g"	./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\n.math {\nbackground-color: #E7FFE7 ;\ndisplay: inline-block\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\ncode {\nbackground: #f4f4f4;background: #f4f4f4;\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\n.alt-text {\nbackground-color: #E6E6FA ;\ndisplay: inline-block\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/<style>/<style>\nh2 {\ncolor:blue;\n}\n/g' ./"$baseName"/math_equations.html

perl -pi -e 's/(id="equation.*)(\n)/$1/g' ./"$baseName"/math_equations.html

cp ./TTS_full.txt ./"$baseName"/TTS_full_2.txt

rm ./TTS_full.txt 

sed -i 's/^\(@@ \)*//g'	./"$baseName"/TTS_full_2.txt

awk '{filename = sprintf("equation_%d.txt", NR); print >filename; close(filename)}' ./"$baseName"/TTS_full_2.txt

mv ./equation_*.txt ./"$baseName"/

rm ./"$baseName"/TTS_full_2.txt

echo -ne 'Processing equations... \033[1;32mDone.\033[0m\r'

echo -ne '\n\n'

echo -ne 'Opening MS Edge...'

echo -ne '\n\n'

cwd=$(pwd)

start msedge "$cwd/$baseName/math_equations.html"

while true; do

read -n1 -p "Would you like to correct the alternative text of math equations in $(echo -e "\033[1;44m$baseName.html\033[0m\x1B[49m\x1B[K")? [Y/N]?" answer

case $answer in
Y | y) 
	   echo -e "\n"
	   correct=on
	   break
	   ;;
	   
N | n) 
	   echo -e "\n"
	   correct=off
	   break
	   ;;	
	*)
	   echo -e "\n"
       echo -e "\033[1;31mError: Invalid entry\033[0m "$answer". \033[1;31mYou must enter one of the following values: [ y / n].\033[0m\n"
	   ;;

	   
esac

done

if [[ "$correct" == "on" ]]; then 

function alt_text_math {
if [ ! -f  "./$baseName/equation_new_$CHOICE.txt" ]; then 

sed -i -e 's/^## //' ./"$baseName"/equation_$CHOICE.txt

touch ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_$CHOICE.txt ./"$baseName"/equation_new_$CHOICE.txt

perl -pi -e 's/(equation_'$CHOICE'">.*\n)/$1<\/textarea><\/p>/' ./"$baseName"/math_equations.html

sed -i -e 's/^/%% /g' ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_new_$CHOICE.txt ./pronunciation.txt

awk '
    /^%%/{                   
        getline <"./pronunciation.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g'	./"$baseName"/math_equations.html

rm ./pronunciation.txt

#echo -ne '\n'

#echo -e "Refresh MS Edge browser (CTRL +R) to see the new alternative text for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K")."

fi

}

function equation_pronunciation {

echo -ne '\n'

read -p "Enter the correct pronunciation for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K"):" value

echo "$value" > ./"$baseName"/equation_new_$CHOICE.txt

perl -pi -e 's|(id="equation_'$CHOICE'">)(.*\n)|$1\n%%\n|g' ./"$baseName"/math_equations.html

perl -pi -e 's|^%%.*|%% |g' ./"$baseName"/math_equations.html

sed -i -e 's/^/%% /g' ./"$baseName"/equation_new_$CHOICE.txt

cp ./"$baseName"/equation_new_$CHOICE.txt ./pronunciation.txt

awk '
    /^%%/{                   
        getline <"./pronunciation.txt" 
    }
    1                      
    ' ./"$baseName"/math_equations.html > tmp && mv tmp ./"$baseName"/math_equations.html

sed -i 's/^\(%% \)*//g'	./"$baseName"/math_equations.html

perl -pi -e 's|(id="equation_'$CHOICE'">.*)(\n)|$1|g' ./"$baseName"/math_equations.html

rm ./pronunciation.txt

echo -ne '\n'

echo -ne "Alternative text for $(echo -e "\033[1;44mequation $CHOICE\033[0m\x1B[49m\x1B[K") changed. Refresh MS Edge browser (CTRL +R) to see changes."

echo -ne '\n\n'

}

while :; do

	read -p "Enter the equation number $(echo -e "\033[1;44m(1-$MAX)\033[0m\x1B[49m\x1B[K"), or $(echo -e "\033[1;44mq\033[0m\x1B[49m\x1B[K") to exit:" CHOICE
    
	if [[ "$CHOICE" == "q" ]] ; then
	
	break;
	
	fi;
	
	if [[ "$CHOICE" -le "$MAX" ]] ; then
	
	alt_text_math
	
	equation_pronunciation
	
	else
	
	echo -e "\n\033[1;31mError: Invalid number\033[0m "$CHOICE". \033[1;31mYou must enter a number between\033[0m 1 \033[1;31mand\033[0m" $MAX"\033[1;31m.\033[0m\n"
	
	fi;
	
	done
	
	echo -ne '\n'

fi

touch ./"$baseName"/all.txt

counter_math=1
for x in ./"$baseName"/equation_*.txt; do

        basePath=${x%.*}
        Name=${basePath##*/}

if [ -f ./"$baseName"/equation_new_$counter_math.txt ]; then

perl -pi -e 's|^%% ||g' ./"$baseName"/equation_new_$counter_math.txt

cat ./"$baseName"/equation_new_$counter_math.txt > ./"$baseName"/equation_$counter_math.txt		
		
fi

if [ -f ./"$baseName"/equation_$counter_math.txt ]; then	

cat ./"$baseName"/equation_$counter_math.txt >> ./"$baseName"/all.txt

fi

counter_math=$[ $counter_math + 1 ] ; 
done

rm ./"$baseName"/equation_*.txt
sed -i -e 's/^/@@ /' ./"$baseName"/all.txt 
mv ./"$baseName"/all.txt ./"$baseName"/display-log2.txt
rm ./"$baseName"/math_equations.html

while true; do

read -n1 -p "Would you like to perform find and replace functions for the alternative text of math equations in $(echo -e "\033[1;44m$baseName.html\033[0m\x1B[49m\x1B[K")? [Y/N]?" answer

case $answer in
Y | y) 
	   echo -e "\n"
	   replace_correct=on
	   break
	   ;;
	   
N | n) 
	   echo -e "\n"
	   replace_correct=off
	   break
	   ;;	
	*)
	   echo -e "\n"
       echo -e "\033[1;31mError: Invalid entry\033[0m "$answer". \033[1;31mYou must enter one of the following values: [ y / n].\033[0m\n"
	   ;;

	   
esac

done

function replace_pronunciation {

while :; do

	read -p "Enter the word(s) that you wish to replace (type q and press Enter to exit):" find
	
	if [[ "$find" == "q" ]] ; then
	
	break;
	
	fi;

	echo -e "\n"

read -p "Enter the word(s) that you wish to use instead of $(echo -e "\033[1;44m$find\033[0m\x1B[49m\x1B[K") (press enter to replace with NOTHING):" replace

sed -i "s/$find/$replace/gI" ./"$baseName"/display-log2.txt

if [[ ! $replace ]] ; then

echo -e "\n\033[1;44m$find\033[0m\x1B[49m\x1B[K removed.\n"

else 

echo -e "\n\033[1;44m$find\033[0m\x1B[49m\x1B[K changed to \033[1;44m$replace\033[0m\x1B[49m\x1B[K.\n"

fi
	
done

# echo -e "\n"

}

if [[ "$replace_correct" == "on" ]]; then 

replace_pronunciation

fi

mv ./"$baseName"/display-log2.txt ./

# Combine TTS in SVG

##

cp ./display-log2.txt ./display-log3.txt

perl -pi -e 's/^%% /@@ /g' ./svg_full.txt

perl -pi -e 's/(id="svg_title_\d+">)(.*)(<\/title>)/$1\n%%\n$3/g' ./svg_full.txt

perl -pi -e 's/^@@ /%% /g' ./display-log3.txt

# Replace display equations with lines from display-log2.txt

awk '
    /^%%/{                   
        getline <"./display-log3.txt" 
    }
    1                      
    ' ./svg_full.txt > tmp && mv tmp ./svg_full.txt
	
perl -p00 -i -e 's/(\n\%\%)(.*)(\n)/$2/g' ./svg_full.txt

mv ./svg_full.txt ./display-log2.txt

rm ./display-log3.txt

### Remove spurious Unicode characters, such Synchronous idle

perl -CD -i -wpe 's/\N{SYNCHRONOUS IDLE}//g' ./display-log2.txt


###

##

# End New in 0.2.0

else

echo -ne '\n'

count=$1
while IFS="" read -r p || [ -n "$p" ] ; do echo -ne "Processing equations... \033[1;33m$count\033[0m\r" ; tex2svg "$p" >> display-log2.txt ; count=$[ $count + 1 ] ; done <./display-log.txt

IFS=$IFS_OLD

echo -ne 'Processing equations... \033[1;32mDone.\033[0m\r'
echo -ne '\n'

# Remove txt files

rm ./display-log.txt

# Add line marker before SVG line

perl -0777 -pi -e 's/<svg /&&&\n<svg /g' ./display-log2.txt

# Move SVG components onto the same line

awk '/^&&&/{a=1;b="";next}/^<\/svg>/{a=0;print"</svg>";next}a{printf b$0;b="";next}1' ./display-log2.txt > tmp && mv tmp ./display-log2.txt

# Correct the IDs for each SVG to make them distinct

sed -i 's/aria-labelledby="MathJax-SVG-1-Title"/aria-labelledby="svg_title_~~~"/g' ./display-log2.txt

sed -i 's/title id="MathJax-SVG-1-Title"/title id="svg_title_%%%"/g' ./display-log2.txt

awk '{for(x=1;x<=NF;x++)if($x~/~~~/){sub(/~~~/,++i)}}1' ./display-log2.txt > tmp && mv tmp ./display-log2.txt

awk '{for(x=1;x<=NF;x++)if($x~/%%%/){sub(/%%%/,++i)}}1' ./display-log2.txt > tmp && mv tmp ./display-log2.txt

# Correct speech markup


# Add math class to SVG files

sed -i -e 's/<svg /<svg class="math" /g' ./display-log2.txt

# Add String to beginning of each line

sed -i -e 's/^/@@ /' ./display-log2.txt

fi

# Insert equations into txt file

# Replace display equations with lines from display-log2.txt

awk '
    /^@@/{                   
        getline <"./display-log2.txt" 
    }
    1                      
    ' ./"$baseName"/"$baseName".html > tmp && mv tmp ./"$baseName"/"$baseName".html

### New	
	
sed -i '/@@/s/quotation-mark//g' ./"$baseName"/"$baseName".html	

sed -i '/@@/s/slash/divided by/g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/percent-sign/percent/g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/StartFraction/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/EndFraction/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/upper/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/left-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/right-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/right-parenthesis/ /g' ./"$baseName"/"$baseName".html

sed -i '/@@/s/ comma //g' ./"$baseName"/"$baseName".html

###

# NEW
 
perl -0777 -pi -e 's/(<img.*)(base64.*)(\n@@)/\n@@/g' ./"$baseName"/"$baseName".html
 
#
 
# Replace placeholder text

sed -i -e 's/@@ //g' ./"$baseName"/"$baseName".html
    
# Remove txt files

rm ./display-log2.txt

# Remove beginning of webtex content

perl -0777 -pi -e 's/(<img.*)(latex.codecogs.com.*)(\n)/\n/g' ./"$baseName"/"$baseName".html

# Reposition alternative text on the same line in the HTML file

perl -0777 -pi -e 's/(\n)(<svg)/ $2/g' ./"$baseName"/"$baseName".html

# Remove title text containing LaTeX (redundant output for screen reader)
# title is used in footnote areas which causes problems for conversion
# Requires Pandoc 2.10 and above (class=math)

perl -0777 -pi -e 's/(\n)(title=".*" )(class="math inline" \/>)//g' ./"$baseName"/"$baseName".html

perl -0777 -pi -e 's/(\n)(title=".*" )(class="math display" \/>)//g' ./"$baseName"/"$baseName".html

# Place title text back in correct place if there are footnotes in the document

perl -0777 -pi -e 's/(\n)(title=".*")/ $2/g' ./"$baseName"/"$baseName".html

# Remove figure element from display equations before SVG

sed -i 's/<figure> <svg/<p><svg/g' ./"$baseName"/"$baseName".html

sed -i 's/<\/svg><\/figure>/<\/svg><\/p>/g' ./"$baseName"/"$baseName".html

fi

fi

# New in version 1.7.0.4

if [[ "$math" == "webtex" ]]; then 

if [ ! -n "$SVG" ]; then

# perl -pi -e 's/\\text{\\&(?!#\d+;)amp;}//g if /<figure>/' ./"$baseName"/"$baseName".html

# perl -pi -e 's/\\ / /g if /<figure>/' ./"$baseName"/"$baseName".html

# New 

# Remove <figure> tags around webtex equations (inserting <p> tags instead)

sed -i 's/\(<figure>\)\(.*latex.codecogs.com.*\)\(<\/figure>\)/<p>\2<\/p>/g' ./"$baseName"/"$baseName".html

#

sed -i '/<p><img style=/s/\\%/%/g' ./"$baseName"/"$baseName".html

sed -i '/<p><img style=/s/\\\%/%/2g' ./"$baseName"/"$baseName".html

# Replace backslash only if it is within the alt attribute

perl -pi -e 's/({)(.*?)(})/$end_delim=$3; "$1" . $2=~s|~| |gr . "$end_delim"/ge' ./"$baseName"/"$baseName".html

# sed -i 's/\\text/&\n/;h;y/~/ /;H;g;s/\n.*\n//' ./"$baseName"/"$baseName".html

fi

fi

### New 1.7.0.4

# Add headings within <aside> areas if ##, ###, #### etc. are used

sed -i 's/\(<p>##### \)\(.*\)\(<\/p>\)/<h5>\2<\/h5>/g' ./"$baseName"/"$baseName".html

sed -i 's/\(<p>#### \)\(.*\)\(<\/p>\)/<h4>\2<\/h4>/g' ./"$baseName"/"$baseName".html

sed -i 's/\(<p>### \)\(.*\)\(<\/p>\)/<h3>\2<\/h3>/g' ./"$baseName"/"$baseName".html

sed -i 's/\(<p>## \)\(.*\)\(<\/p>\)/<h2>\2<\/h2>/g' ./"$baseName"/"$baseName".html

###

#

# Report Log #

# Print the name of the HTML file that was converted as well as the time to the log.txt file.

echo -e "\n"$baseName".html CONVERTED on "$TIMESTAMP"\n" >> ./Converted-DOCX-HTML/log.txt

# Print the number of pages found in the HTML file to the log.txt file.

grep -c "<h6" ./"$baseName"/"$baseName".html | sed 's/^/Pages: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of heading 1s found in the HTML file to the log.txt file.

grep -c "<h1" ./"$baseName"/"$baseName".html | sed 's/^/Heading 1s: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of heading 2s found in the HTML file to the log.txt file.

grep -c "<h2" ./"$baseName"/"$baseName".html | sed 's/^/Heading 2s: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of heading 3s found in the HTML file to the log.txt file.

grep -c "<h3" ./"$baseName"/"$baseName".html | sed 's/^/Heading 3s: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of heading 4s found in the HTML file to the log.txt file.

grep -c "<h4" ./"$baseName"/"$baseName".html | sed 's/^/Heading 4s: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of images found in the HTML file to the log.txt file.

grep -c "<figure" ./"$baseName"/"$baseName".html | sed 's/^/Images: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of images that have alternative text in the HTML file to the log.txt file.

grep -c -o 'alt=".*"' ./"$baseName"/"$baseName".html | sed 's/^/Images with Alternative Text: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of images that have captions in the HTML file to the log.txt file.

grep -c "<figcaption>" ./"$baseName"/"$baseName".html | sed 's/^/Images with Captions: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of images the have null alt attribute (alt="") in the HTML file to the log.txt file.

grep -c ""presentation"" ./"$baseName"/"$baseName".html | sed 's/^/Images with Null Alt: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of images that have extended descriptions in the HTML file to the log.txt file.

grep -c "<details>" ./"$baseName"/"$baseName".html | sed 's/^/Extended Descriptions: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of tables in the HTML file to the log.txt file.

grep -c "<table>" ./"$baseName"/"$baseName".html | sed 's/^/Tables: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of tables with captions in the HTML file to the log.txt file.

grep -c "<caption>" ./"$baseName"/"$baseName".html | sed 's/^/Tables with Captions: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of tables with column headers in the HTML file to the log.txt file.

grep -c "<thead>" ./"$baseName"/"$baseName".html | sed 's/^/Tables with Column Headers: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of ordered lists in the HTML file to the log.txt file.

grep -c "<ol" ./"$baseName"/"$baseName".html | sed 's/^/Numbered Lists: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of display equations in the HTML file to the log.txt file.

grep -c "math display" ./"$baseName"/"$baseName".html | sed 's/^/Display Equations: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of inline equations in the HTML file to the log.txt file.

grep -c "math inline" ./"$baseName"/"$baseName".html | sed 's/^/Inline Equations: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of <lang> attributes in the HTML file to the log.txt file.

grep -c "class=\"language\"" ./"$baseName"/"$baseName".html | sed 's/^/Language Tags: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of line numbers (poetry) in the HTML file to the log.txt file.

grep -c "class=\"line-number\"" ./"$baseName"/"$baseName".html | sed 's/^/Line Numbers: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of transcriber's notes in the HTML file to the log.txt file.

grep -c "class=\"transcriber-note\"" ./"$baseName"/"$baseName".html | sed "s/^/Transcriber's Notes: /" >> ./Converted-DOCX-HTML/log.txt

# Print the number of blockquotes

grep -c "<blockquote>" ./"$baseName"/"$baseName".html | sed 's/^/Blockquotes: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of <cite> attributes (citations) in the HTML file to the log.txt file.

grep -c "class=\"blockquote-footer\"" ./"$baseName"/"$baseName".html | sed 's/^/Blockquotes with Citations: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of Secondary Text Areas in the HTML file to the log.txt file.

grep -c "class=\"complimentary\"" ./"$baseName"/"$baseName".html | sed 's/^/Secondary Text Areas: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of Footnote text areas in the HTML file to the log.txt file.

grep -c "role=\"doc-footnote\"" ./"$baseName"/"$baseName".html | sed 's/^/Footnote Areas: /' >> ./Converted-DOCX-HTML/log.txt

# Print the number of footnotes in the HTML file to the log.txt file.

grep -c "aria-label=\"footnote" ./"$baseName"/"$baseName".html | sed 's/^/Footnotes: /' >> ./Converted-DOCX-HTML/log.txt

# Remove an empty line at the beginning of the log.txt file

sed -i '/./,$!d' ./Converted-DOCX-HTML/log.txt	
		
# Checking for validation issues

# echo -e "\nChecking \033[1;32m"$baseName".html\033[0m.... "	

# Print validation warnings to the terminal

if 	/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Possible misuse of “aria-label.*" --filterpattern ".*The first occurrence of ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | grep -q 'info warning:' ; then

if [ "$check" == "on" ]; then 

echo -e "\n\033[1;33mATTENTION:\033[0m These HTML validation \033[1;33mwarnings\033[0m were found in \033[1;32m"$baseName".html\033[0m:\n"

/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Possible misuse of “aria-label.*" --filterpattern ".*The first occurrence of ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(info warning: \)\(.*\)$/\n\2\4/p'

fi

/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Possible misuse of “aria-label.*" --filterpattern ".*The first occurrence of ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(info warning: \)\(.*\)$/\n\2\4/p' > ./display.txt

if [ -n "$edit" ];

then

############## New

IFS=$'\n'

file="./display.txt"

echo -e "\n\033[1;33mATTENTION:\033[0m These HTML validation \033[1;33mwarnings\033[0m were found in \033[1;32m"$baseName".html\033[0m:"

for line in $(cat $file); do

echo -e "\n$line\n"

number=$(echo "$line"| perl -nE'say/(\d+)/?$1:""')

read -n1 -p "Do you wish to go to this line in the HTML file[Y/N]?" answer
case $answer in
Y | y) 
       vim +"$number" ./"$baseName"/"$baseName".html
       echo -e "\n"
       ;;
N | n) echo ;;
     
esac
IFS=$IFS_OLD
done 
rm ./display.txt

if 	/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Possible misuse of “aria-label.*" --filterpattern ".*The first occurrence of ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | grep -q 'info warning:' ; then

/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Possible misuse of “aria-label.*" --filterpattern ".*The first occurrence of ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(info warning: \)\(.*\)$/\n\2\4/p' > ./display.txt

fi

if [ -f ./display.txt ] ; then

echo -e "\nHTML validation \033[1;33mwarnings\033[0m were still found in \033[1;32m"$baseName".html\033[0m! See the log.txt for more info.";

echo -e "\n HTML Warnings:\n" >> ./Converted-DOCX-HTML/log.txt

cat ./display.txt >> ./Converted-DOCX-HTML/log.txt

rm ./display.txt

else

echo -e "There are no more HTML \033[1;33mwarnings\033[0m in \033[1;32m"$baseName".html\033[0m!";

fi

fi

else

if [ "$check" == "on" ]; then 

echo -e "\nNo HTML validation \033[1;33mwarnings\033[0m were found in \033[1;32m"$baseName".html\033[0m!";

fi

fi

if [ -f ./display.txt ] ; then

echo -e "\n HTML Warnings:\n" >> ./Converted-DOCX-HTML/log.txt

cat ./display.txt >> ./Converted-DOCX-HTML/log.txt

rm ./display.txt

fi

# Print validation errors to the terminal

if /c/vnu-runtime-image/bin/vnu.bat --errors-only --filterpattern ".*Duplicate attribute “class”.*" --filterpattern ".*Duplicate ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | grep -q 'error:' ; then

if [[ "$check" == on ]]; then 
		
echo -e "\n\033[1;33mATTENTION:\033[0m These HTML validation \033[1;31merrors\033[0m were found in \033[1;32m"$baseName".html\033[0m:\n"
		
/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Duplicate attribute “class”.*" --filterpattern ".*Duplicate ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(error: \)\(.*\)$/\n\2\4/p'

fi

/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Duplicate attribute “class”.*" --filterpattern ".*Duplicate ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(error: \)\(.*\)$/\n\2\4/p' > ./display.txt

if [ -n "$edit" ];

then

IFS=$'\n'

file="./display.txt"

echo -e "\n\033[1;33mATTENTION:\033[0m These HTML validation \033[1;31merrors\033[0m were found in \033[1;32m"$baseName".html\033[0m:"

for line in $(cat $file); do

echo -e "\n$line\n"

number=$(echo "$line"| perl -nE'say/(\d+)/?$1:""')

read -n1 -p "Do you wish to go to this line in the HTML file[Y/N]?" answer
case $answer in
Y | y) 
       vim +"$number" ./"$baseName"/"$baseName".html
       echo -e "\n"
       ;;
N | n) echo ;;
     
esac
IFS=$IFS_OLD
done 
rm ./display.txt

if 	/c/vnu-runtime-image/bin/vnu.bat --errors-only --filterpattern ".*Duplicate attribute “class”.*" --filterpattern ".*Duplicate ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | grep -q 'error:' ; then

/c/vnu-runtime-image/bin/vnu.bat --filterpattern ".*Duplicate attribute “class”.*" --filterpattern ".*Duplicate ID “E.*" ./"$baseName"/"$baseName".html 2>&1 | sed -n -e 's/^\(.*":\)\(.*\)\(error: \)\(.*\)$/\n\2\4/p' > ./display.txt

fi

if [ -f ./display.txt ] ; then

echo -e "\nHTML validation \033[1;31merrors\033[0m were still found in \033[1;32m"$baseName".html\033[0m! See the log.txt for more info.";

echo -e "\n HTML Errors:\n" >> ./Converted-DOCX-HTML/log.txt

cat ./display.txt >> ./Converted-DOCX-HTML/log.txt

rm ./display.txt

else

echo -e "\nThere are no more HTML \033[1;31merrors\033[0m in \033[1;32m"$baseName".html\033[0m!";

fi

if 	grep -q 'class="language' ./"$baseName"/"$baseName".html ; then
    
echo -e "\nThere are secondary languages \033[1;45m\033[1;39m(purple background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m.\n"

read -n1 -p "Do you wish to remove the $(echo -e "\033[1;45m\033[1;39mpurple background\033[0m\033[0m") in $(echo -e "\033[1;32m"$baseName".html\033[0m")[Y/N]?" answer
case $answer in
Y | y) 
       sed -i 's/ class="language"//g' ./"$baseName"/"$baseName".html
       echo -e "\n"
       echo -e "\033[1;45m\033[1;39mPurple background\033[0m\033[0m removed from \033[1;32m"$baseName".html\033[0m.."
       ;;
N | n) 
		echo -e "\n\033[1;33mATTENTION:\033[0m Check the secondary language passages \033[1;45m\033[1;39m(purple background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m and run the \033[1;95mLangClass- Remove.sh\033[0m Script!" 
		;;

esac		
		
fi

fi
		
else 

if [ "$check" == "on" ]; then 
		
echo -e "\nNo HTML validation \033[1;31merrors\033[0m were found in \033[1;32m"$baseName".html\033[0m!";

fi

fi

if [ -f ./display.txt ] ; then

echo -e "\n HTML Errors:\n" >> ./Converted-DOCX-HTML/log.txt

cat ./display.txt >> ./Converted-DOCX-HTML/log.txt

rm ./display.txt

fi

###### New

if [ -n "$language" ];

then

if 	grep -q 'class="language' ./"$baseName"/"$baseName".html ; then
    
echo -e "\nThere are secondary languages \033[1;45m\033[1;39m(purple background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m.\n"

read -n1 -p "Do you wish to remove the $(echo -e "\033[1;45m\033[1;39mpurple background\033[0m\033[0m") in $(echo -e "\033[1;32m"$baseName".html\033[0m")[Y/N]?" answer
case $answer in
Y | y) 
       sed -i 's/ class="language"//g' ./"$baseName"/"$baseName".html
       echo -e "\n"
       echo -e "\033[1;45m\033[1;39mPurple background\033[0m\033[0m removed from \033[1;32m"$baseName".html\033[0m.."
       ;;
N | n) 
		echo -e "\n\033[1;33mATTENTION:\033[0m Check the secondary language passages \033[1;45m\033[1;39m(purple background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m and run the \033[1;95mLangClass- Remove.sh\033[0m Script!" 
		;;
     
esac

fi

fi

if 	grep -q 'span class="math' ./"$baseName"/"$baseName".html ; then
    
echo -e "\n\033[1;33mATTENTION:\033[0m Check the math \033[1;102m\033[1;30m(green background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi

if 	grep -q 'MathML' ./"$baseName"/"$baseName".html ; then
    
echo -e "\n\033[1;33mATTENTION:\033[0m Check the math \033[1;102m\033[1;30m(green background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi

if 	grep -q 'class="math"' ./"$baseName"/"$baseName".html ; then
    
echo -e "\n\033[1;33mATTENTION:\033[0m Check the math \033[1;102m\033[1;30m(green background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi

if 	grep -q '<table>' ./"$baseName"/"$baseName".html ; then
    
echo -e "\n\033[1;33mATTENTION:\033[0m Check the table(s) \033[1;100m\033[1;39m(headers have a gray background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi
	
if 	grep -q '<blockquote>' ./"$baseName"/"$baseName".html ; then
    
echo -e "\n\033[1;33mATTENTION:\033[0m Check the blockquote(s) \033[1;100m\033[1;39m(indented and gray background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi
	
if 	grep -q 'class="line-number"' ./"$baseName"/"$baseName".html ; then
		
echo -e "\n\033[1;33mATTENTION:\033[0m Check the line numbers for poetry \033[1;105m\033[1;39m(pink background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi
    
if 	grep -q 'role="doc-noteref"' ./"$baseName"/"$baseName".html ; then
		
echo -e "\n\033[1;33mATTENTION:\033[0m Check the footnotes \033[1;103m\033[1;30m(light yellow background)\033[0m\033[0m in \033[1;32m"$baseName".html\033[0m!"

fi


   # mv ./"$baseName"_edited.docx ./Converted-DOCX-HTML/"$baseName"_HTML.docx 

	#rm ./"$baseName"_edited.docx 2> /dev/null 
    
   # echo -e "\n\033[1;35m"$baseName".docx\033[0m was moved to the \033[1;44mConverted-DOCX-HTML\033[0m folder."

#####

if [ -n "$just" ]; then

# Delete everything before the <main> element

sed -i '0,/^<body>$/d' ./"$baseName"/"$baseName".html

sed -i -n '/<footer>/q;p' ./"$baseName"/"$baseName".html

fi

# For PDF conversion

if [ -n "$pdf" ]; then

cp ./"$baseName"/"$baseName".html ./"$baseName"/"$baseName"_pdf.html

sed -i '0,/^<main>$/d' ./"$baseName"/"$baseName"_pdf.html

sed -i -n '/<\/main>/q;p' ./"$baseName"/"$baseName"_pdf.html

sed -i 's/<a id=\"table.*//g' ./"$baseName"/"$baseName"_pdf.html

sed -i 's/<p><a href=\"#table.*//g' ./"$baseName"/"$baseName"_pdf.html

sed -i -e 's/<\/div>//g' ./"$baseName"/"$baseName"_pdf.html

sed -i -e 's/<div class=\"table-container\" tabindex=\"0\">//g' ./"$baseName"/"$baseName"_pdf.html

if [[ "$math" == "webtex" ]]; then 

sed -i -r 's/title="[^"]*" //g'  ./"$baseName"/"$baseName"_pdf.html

fi 

if [ -n "$SVG" ]; then

echo -e "\n\033[1;33mATTENTION:\033[0m The math equations in \033[1;35m"$baseName".html\033[0m are in SVG and cannot be converted back to DOCX format. Consider using the -m webtex or -m mathspeak options to generate alternative text for math in PDF workflows. Will not create \033[1;35m"$baseName"_pdf.docx\033[0m..."

rm ./"$baseName"/"$baseName"_pdf.html

else

pandoc ./"$baseName"/"$baseName"_pdf.html -t docx -o ./"$baseName"/"$baseName"_pdf.docx

echo -e "\n\033[1;33mATTENTION:\033[0m \033[1;35m"$baseName"_pdf.docx\033[0m was created in the \033[1;44m/"$baseName"/\033[0m folder."

rm ./"$baseName"/"$baseName"_pdf.html

fi
 
if [[ "$math" == "mathml" ]]; then 

echo -e "\n\033[1;33mATTENTION:\033[0m The math equations in \033[1;35m"$baseName"_pdf.docx\033[0m are in Office Math format. Consider using the -m webtex or -m mathspeak options to generate alternative text for math in PDF workflows."

fi

if [[ "$math" == "mathjax" ]]; then 

echo -e "\n\033[1;33mATTENTION:\033[0m The math equations in \033[1;35m"$baseName"_pdf.docx\033[0m are in LaTeX format. Consider converting these to MathType format or to Office Math format. Consider using the -m webtex or -m mathspeak options to generate alternative text for math in PDF workflows."

fi 

if [[ "$math" == "webtex" ]]; then 

if [ -n "$speech" ]; then

echo -e "\n\033[1;33mATTENTION:\033[0m The math equations in \033[1;35m"$baseName"_pdf.docx\033[0m have descriptive alt text."

else

echo -e "\n\033[1;33mATTENTION:\033[0m The math equations in \033[1;35m"$baseName"_pdf.docx\033[0m have LaTeX alt text."

fi

fi

if [ ! -n "$SVG" ]; then

echo -e "\nUse your preferred Save As PDF tool (e.g., axesWord) to convert to PDF."

fi

fi

#

####
   
if [ -n "$word" ]; then

if /c/scripts/tasklist.exe //FI "IMAGENAME eq WINWORD.EXE" 2> /dev/null | grep -q "WINWORD.EXE" 2> /dev/null ; then

echo -e "\nMS Word is running... \033[1;35m"$baseName".docx\033[0m will remain in the current folder and not moved to the \033[1;44mConverted-DOCX-HTML\033[0m folder."

rm ./"$baseName"_edited.docx 2> /dev/null

else

mv "$x" ./Converted-DOCX-HTML/"$baseName"_HTML.docx

rm ./"$baseName"_edited.docx 2> /dev/null 

echo -e "\nMoved \033[1;35m"$baseName".docx\033[0m to the \033[1;44mConverted-DOCX-HTML\033[0m folder."

fi

else 

    mv ./"$baseName"_edited.docx ./Converted-DOCX-HTML/"$baseName"_HTML.docx 

	rm ./"$baseName"_edited.docx 2> /dev/null 
    
    echo -e "\nA copy of \033[1;35m"$baseName".docx\033[0m was moved to the \033[1;44mConverted-DOCX-HTML\033[0m folder.\x1B[49m\x1B[K"

fi

# Create folder in Canvas

if [ -n "$upload" ]; then

if [[ $course_page == "no" ]]; then

curl -sS https://$canvas_domain/api/v1/courses/$class_number/files -F "name=$baseName.html" -F 'content_type=text/html' -F "parent_folder_path=$canvas_path_name" -H 'Authorization: Bearer '$token'' | sed 's/.*url":"//g' | sed 's/","upload.*//g' > ./"$baseName"/canvas_path.txt

canvas_path=`cat ./"$baseName"/canvas_path.txt`
 
# Upload HTML file to Canvas Files Area
 
curl -sS $canvas_path -F "filename=$baseName.html" -F "file=@./$baseName/$baseName.html" > /dev/null

fi

# Upload HTML to Course Page

if [[ $course_page == "yes" ]]; then

cp ./"$baseName"/"$baseName".html ./"$baseName"/"$baseName"_copy.html

awk '/<body>/{p=1;next}{if(p){print}}' ./"$baseName"/"$baseName"_copy.html > tmp && mv tmp ./"$baseName"/"$baseName"_copy.html

awk '/<footer>/ {exit} {print}' ./"$baseName"/"$baseName"_copy.html > tmp && mv tmp ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/\n//g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/\\ / /g' ./"$baseName"/"$baseName"_copy.html

#

# Extract LaTeX equations to avoid URL encoding change step

perl -pi -e 's/src="https:\/\/latex/\n~#%src="https:\/\/latex/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/(^~#%[^\s]+)/$1\n/g' ./"$baseName"/"$baseName"_copy.html

sed -n 's/\(^~#%\)\(.*\)/\2/p' ./"$baseName"/"$baseName"_copy.html > ./display-log.txt

# Add String to beginning of each line

sed -i -e 's/^/@@ /' ./display-log.txt

perl -pi -e 's/(^~#%)/@@ /g' ./"$baseName"/"$baseName"_copy.html

#

# Use entity codes to avoid Curl error

perl -pi -e 's/%/%25/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/&/%26/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/&gt;/>/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/&lt;/</g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/\+/%2b/g' ./"$baseName"/"$baseName"_copy.html

# Add LaTeX base64 images back into the file

awk '
    /^@@/{                   
        getline <"./display-log.txt"
    }
    1                      
    ' ./"$baseName"/"$baseName"_copy.html > tmp && mv tmp ./"$baseName"/"$baseName"_copy.html

sed -i -e 's/@@ //g' ./"$baseName"/"$baseName"_copy.html

# Change @ character to URL Encoding

perl -pi -e 's/@/%40/g' ./"$baseName"/"$baseName"_copy.html
#
	
rm ./display-log.txt

# Check if there are images in HTML file directory (BEGIN If Loop)

if [ -d ./"$baseName"/media ]; then

echo -ne "\nUploading files to Canvas...\n"

# Get Root Directory

curl  -sS https://$canvas_domain/api/v1/courses/$class_number/folders/root -H 'Authorization: Bearer '$token'' | sed 's/.*"id"://' | sed 's/,.*//g' > ./"$baseName"/canvas_folder_root.txt

# Assign Root Folder ID as variable

canvas_folder_root=`cat ./"$baseName"/canvas_folder_root.txt`

# Create Folder
#curl https://$canvas_domain/api/v1/courses/$class_number/folders -F "name=images - course pages" -F "parent_folder_id=$canvas_folder_root" -H 'Authorization: Bearer '$token'' | sed 's/.*"id"://' | sed 's/,.*//g' > ./"$baseName"/new_canvas_folder.txt

curl  -sS https://$canvas_domain/api/v1/courses/$class_number/folders -F "name=$baseName" -H 'Authorization: Bearer '$token'' | sed 's/.*"id"://' | sed 's/,.*//g' > ./"$baseName"/new_canvas_folder.txt

# Assign NEW Folder ID as variable

new_canvas_folder=`cat ./"$baseName"/new_canvas_folder.txt`

# LOOP to add images to New Folder (NESTED in IF Statement for if there is media folder)

counter_image=1
for x in ./"$baseName"/media/image*; do
        basePath=${x%}
        Name=${basePath##*/}

curl -sS https://$canvas_domain/api/v1/courses/$class_number/files -F "name=$Name" -F 'content_type=image/png' -F "parent_folder_id=$new_canvas_folder" -H 'Authorization: Bearer '$token'' | sed 's/.*url":"//g' | sed 's/","upload.*//g' > ./"$baseName"/canvas_path.txt 

canvas_path=`cat ./"$baseName"/canvas_path.txt`

curl -sS $canvas_path -F "filename=$Name" -F "file=@./$baseName/media/$Name" > /dev/null

counter_image=$[ $counter_image + 1 ] ; 
done


# Get list of images in the the NEW Folder

curl -sS https://$canvas_domain/api/v1/folders/$new_canvas_folder/files\?include=items\&per_page=100 -H 'Authorization: Bearer '$token'' > ./"$baseName"/canvas_images.txt

perl -pi -e 's/https:\/\/'$canvas_domain'\/files\//\n@@ https:\/\/'$canvas_domain'\/files\//g' ./"$baseName"/canvas_images.txt

perl -pi -e 's/(\d+)(\/download?.*)/$1\/download" data-api-endpoint="https:\/\/'$canvas_domain'\/api\/v1\/courses\/'$class_number'\/files\/$1" data-api-returntype="File"/g' ./"$baseName"/canvas_images.txt

perl -pi -e 's/\[\{"id".*\n//g' ./"$baseName"/canvas_images.txt

perl -pi -e 's/\\//g' ./"$baseName"/canvas_images.txt

mv ./"$baseName"/canvas_images.txt ./

# Prevent Latex base64 files from being extracted

perl -pi -e 's/src="https:\/\/latex/srcl="https:\/\/latex/g' ./"$baseName"/"$baseName"_copy.html

#

perl -pi -e 's/src="/$1\n@@/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/(@@.*")( style)/@@\n$2/g' ./"$baseName"/"$baseName"_copy.html

awk '
    /^@@/{                   
        getline <"./canvas_images.txt" 
    }
    1                      
    ' ./"$baseName"/"$baseName"_copy.html > tmp && mv tmp ./"$baseName"/"$baseName"_copy.html

rm ./canvas_images.txt

perl -pi -e 's/@@ /src="/g' ./"$baseName"/"$baseName"_copy.html

# Add the correct code for LaTex base64 files

perl -pi -e 's/srcl="https:\/\/latex/src="https:\/\/latex/g' ./"$baseName"/"$baseName"_copy.html

#

perl -pi -e 's/frd=1/frd=1"/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/\n//g' ./"$baseName"/"$baseName"_copy.html

rm ./"$baseName"/new_canvas_folder.txt

rm ./"$baseName"/canvas_folder_root.txt

rm ./"$baseName"/canvas_path.txt

fi

#

perl -pi -e 's/<img/\n<img/g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/(^<img[^>]+)/$1\n/g' ./"$baseName"/"$baseName"_copy.html

sed -n 's/\(^<img\)\(.*\)/<img\2/p' ./"$baseName"/"$baseName"_copy.html > ./display-log.txt

sed -i -e 's/^/@@ /' ./display-log.txt

sed -i -e "s/\"/'/g" ./display-log.txt

perl -pi -e 's/(^<img)/@@ <img/g' ./"$baseName"/"$baseName"_copy.html

awk '
    /^@@/{                   
        getline <"./display-log.txt"
    }
    1                      
    ' ./"$baseName"/"$baseName"_copy.html > tmp && mv tmp ./"$baseName"/"$baseName"_copy.html

sed -i -e 's/@@ //g' ./"$baseName"/"$baseName"_copy.html

perl -pi -e 's/\n//g' ./"$baseName"/"$baseName"_copy.html

rm ./display-log.txt

#

sed -i '1s/^/wiki_page[body]=/' ./"$baseName"/"$baseName"_copy.html

# Cannot Handle Too long files

#canvas_content=`cat ./"$baseName"/"$baseName"_copy.html`

#curl -sS -X -K POST -H "Authorization: Bearer $token" https://$canvas_domain/api/v1/courses/$class_number/pages --data-urlencode "wiki_page[title]=$baseName" --data-urlencode "wiki_page[body]=$canvas_content" > /dev/null

#

curl -sS -X POST -H "Authorization: Bearer $token" https://$canvas_domain/api/v1/courses/$class_number/pages --data-urlencode "wiki_page[title]=$baseName" --data @./"$baseName"/"$baseName"_copy.html > /dev/null

rm ./"$baseName"/"$baseName"_copy.html

echo -ne '\n'

echo -e "\033[1;32m"$baseName".html\033[0m was uploaded to \033[1;44m$canvas_course\033[0m Canvas course as a course page. \x1B[49m\x1B[K"

fi

#

if [[ $course_page == "no" ]]; then

echo -ne '\n'



if [[ $canvas_path_name == "" ]]; then

path_name="Files Area"

else

path_name=$canvas_path_name

fi

echo -e "\033[1;32m"$baseName".html\033[0m was uploaded to the \033[1;44m$path_name\033[0m folder in your \033[1;44m$canvas_course\033[0m Canvas course. \x1B[49m\x1B[K"

fi

rm ./"$baseName"/canvas_course.txt
 
fi

done

exit 1