# Firebase Realtime Database BACKUP script

## Introduction

This script is intended to be used on **Linux** servers or local machines to run database backups of your firebase projects. It enables you to add and remove projects that you want to backup.

The output of the backup is saved in the *_BACKUP* folder, located at the location of the script. Each project will have its own subfolder, named after the project alias. After the backup is finished, you will get a nicely formatted **JSON** file, named like *DDMMYYYY_HHmm.json*. The time is in 24hr format.

A backup started on the **9th of November 2017 at 10:42 PM** would result in a backup file path like this

> **_BACKUP/project-alias/09112017_2242.json**

The JSON output will be the same as the file you would get by exporting the database by hand from the Firebase Dashboard.

## Setup

> NOTE: For the script to run you need to have `firebase-tools` installed on the machine you intend to use to backup your databases. To install Firebase CLI tools follow the instructions from [this site](https://firebase.google.com/docs/cli/)

Before you can backup your databases, there are steps to go through:

1. get `firebase-tools`
1. make the script executable by running `chmod u+x firebase-backup.sh`
1. *(OPTIONAL)* add the script to your `$PATH` so you can run it form the command line without the full path
1. initialize the script
1. add firebase-tools location
1. add login token
1. add projects

### Initializing the script

To initialize the script run

`$ firebase-backup.sh -i`

This will create the necessary files and folders.

### Adding Firebase Tools location

If you have installed `firebase-tools` then the script should pick up the location during the initialization.

If fore some reason you get a prompt like this:

> `Cannot find firebase-tools. Please install firebase-tools from npm before proceeding.`

That means that the script did not successfully locate the firebase binary. You can add it manually with the `firebase-backup.sh -f <path>` or `firebase-backup.sh --firebase <path>` command.

This approach is sufficient if you plan to run the command from your terminal on your local machine. If you need it to be run by the system with a cronjob or something similar run the `sudo which firebase` command to obtain the system path to firebase and then add it manually with `firebase-backup.sh -f <path>` or `firebase-backup.sh --firebase <path>` command.

### Adding login token

This is required to access your Firebase projects. To get your token call `firebase login:ci`. This command will open a browser and ask you to authenticate yourself with Google. When you sign in to your account and accept the requested permissions from Firebase, a token will appear in your terminal. Add this token to the configuration by running `firebase-backup.sh -t <token>` or `firebase-backup.sh --token <token>` command.

### Adding projects

Now you are ready to add projects that you wish to be backed up. To add a project use the `firebase-backup.sh -a <project id>` or `firebase-backup.sh --add-project <project id>`

## Running a backup

To run a backup type the following command in the terminal at the location of your script

> `firebase-backup.sh -b`

## List of available commands

| Command                             | Description                                                                       |
| ------------------------------------|-----------------------------------------------------------------------------------|
|  -i, --init                         |   initialize script                                                               |
|  -f, --firebase [path]              |   set path to firebase-tools                                                      |
|  -t, --token [string]               |   set Firebase CI Authentication token                                            |
|  -a, --add-project [project id]     |   add project id to projects list                                                 |
|  -r, --remove-project [project id]  |   remove project id from projects list                                            |
|  -b, --backup                       |   backup app projects                                                             |
|  -h, --help                         |   help                                                                            |
|  -l [option]                        |   List configuration options: </br> **f** - firebase location </br> **t** - token |
|  -p                                 |   display all projects                                                            |