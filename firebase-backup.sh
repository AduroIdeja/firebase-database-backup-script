#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
FILE_TIMESTAMP=`date +%d%m%Y_%H%M`
DISPLAY_DATE_FORMAT="+%d.%m.%Y. %T"
ROOT="."
BIN="$ROOT/bin"
BACKUP="$ROOT/_BACKUP"
CONFIG_FILE="$BIN/backup.conf"
PROJECTS_FILE="$BIN/projects.conf"
declare -A config
declare -a FIREBASE_PROJECT=()
config=(
    [firebase_location]="firebase"
    [firebase_ci_token]=""
)
# Initializes the necessarry folders and files
function init {
    sed -i -e 's,^\(ROOT=\).*,\1"'`readlink -f ${ROOT}`'",g' "firebase-backup.sh"
    echo "# Creating resource folders..."
    # Creates bin folder
    if [[ ! -d "$BIN" ]]; then
        mkdir ${BIN}
    fi
    # Creates backup configuration file if missing
    if [[ ! -e "$CONFIG_FILE" ]]; then
        touch $CONFIG_FILE
        echo "firebase_location=" >> $CONFIG_FILE
        echo "firebase_ci_token=" >> $CONFIG_FILE
        echo >> $CONFIG_FILE         
    fi
    firebase_loc=`which firebase`
    if [ -z "$firebase_loc" ]; then
        echo "# Cannot find ${bold}firebase-tools${normal}. Please install firebase-tools from ${bold}npm${normal} before proceeding."
    else
        echo "# Found firebase at ${firebase_loc}"
        sed -i -e 's,^\(firebase_location=\).*,\1'$firebase_loc',g' $CONFIG_FILE
    fi
    # Creates projects configuration file if missing
    if [[ ! -e "$PROJECTS_FILE" ]]; then
        touch $PROJECTS_FILE        
    fi
    # Creates backup folder if missing
    if [[ ! -d "$BACKUP" ]]; then
        mkdir ${BACKUP}
    fi
    echo "# Initialization is done. Next you should add the path to FIREBASE and TOKEN"
    echo "# Use -h or --help for info on which commands to use"
    exit 1
}
# Runs backup of all projects
function backup {
    # Checking resources
    if [ ! -d "$BIN" ]; then
        echo "# No $BIN folder found. Initialize script before backup. Run -h or --help for more info"; echo
        exit 1
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "# No $CONFIG_FILE file found. Initialize script before backup. Run -h or --help for more info"; echo
        exit 1
    fi
    if [ ! -f "$PROJECTS_FILE" ]; then
        echo "# No $PROJECTS_FILE file found. Initialize script before backup. Run -h or --help for more info"; echo
        exit 1
    fi
    # Load configuration
    while read line
    do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
        fi
    done < $CONFIG_FILE
    # Load project names
    while read line
    do
        value=$(echo "$line")
        FIREBASE_PROJECT+=("${value}")  
    done < $PROJECTS_FILE
    # Check for backup folder in current location
    if [ ! -d "$BACKUP" ]; then
        echo "# No _BACKUP folder found. Initialize script before backup. Run -h or -help for more info"; echo
        exit 1
    fi
    echo; echo "--- BACKUP STARTED ---"; echo
    # Loopt through projects
    for project in ${FIREBASE_PROJECT[@]};
    do
        # Check for project folder
        if [ ! -d "$BACKUP/$project" ]; then
            echo "# No ${project} folder found. Creating now..."; echo
            # create project folder if missing
            mkdir ${BACKUP}/${project}
        fi        
        echo "# Running backup for project " $project
        echo "# Backup started at `date "+%d.%m.%Y. %T"`"
        # Create blank json file for backup
        touch ${BACKUP}/${project}/${FILE_TIMESTAMP}.json
        # Get database backup for project and wrte it to a temp file
        ${config[firebase_location]} database:get --project $project --token ${config[firebase_ci_token]} --pretty / > ${BACKUP}/${project}/${FILE_TIMESTAMP}.json 
        # Remove temp file
        echo "# Backup finished at `date "+%d.%m.%Y. %T"`"; echo
        # done
    done
    echo "--- BACKUP COMPLETE ---"; echo
    exit 1    
}
function readConf {
    while read line
    do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
        fi
    done < $CONFIG_FILE
    while :
    do
        case "$1" in
            f) echo ${config[firebase_location]} && exit 1;;
            t) echo ${config[firebase_ci_token]} && exit 1;;
            *) echo "Unrecognized option. Use -h or --help to see available options for this command" && exit 1;;
        esac
    done
}
function displayProjects {
    while read line
    do
        value=$(echo "$line")
        echo "${value}"  
    done < $PROJECTS_FILE
    exit 1
}
# Prints help
function printHelp {
    echo "Usage: $ firebase-backup.sh [command...]" >&2
    echo
    echo "___________________________________________________________________________________"
    echo "|                                     |                                           |"
    echo "|  -i, --init                         |   initialize script                       |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -f, --firebase <path>              |   set path to firebase-tools              |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -t, --token <string>               |   set Firebase CI Authentication token    |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -a, --add-project <project id>     |   add project id to projects list         |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -r, --remove-project <project id>  |   remove project id from projects list    |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -b, --backup                       |   backup app projects                     |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|                                     |   List configuration options:             |"
    echo "|  -l [option]                        |   f for firebase location                 |"
    echo "|                                     |   t for token                             |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -p                                 |   display all projects                    |"
    echo "|_____________________________________|___________________________________________|"
    echo "|                                     |                                           |"
    echo "|  -h, --help                         |   help                                    |"
    echo "|_____________________________________|___________________________________________|"
    echo
    exit 1
}
while :
do
    case "$1" in
        -i | --init) init ;;
        -f | --firebase) sed -i -e 's,^\(firebase_location=\).*,\1'$2',g' $CONFIG_FILE && exit 1 ;;
        -t | --token) sed -i -e 's,^\(firebase_ci_token=\).*,\1'$2',g' $CONFIG_FILE && exit 1 ;;
        -a | --add-project) echo $2 >> $PROJECTS_FILE && exit 1 ;;
        -r | --remove-project) sed -i "/$2/d" $PROJECTS_FILE && exit 1 ;;
        -b | --backup) backup ;;
        -h | --help) printHelp ;;
        -l) readConf $2 ;;
        -p) displayProjects ;;
        *) echo "Unrecognized command. Use -h or --help to see available commands" && exit 1;;
    esac
done