#! /bin/bash
# pullSource.sh
# This script:
# 1. Takes in command line argument and sets Variables
# 2. Creates a working source code directory for this instance of the build
# 3. Changes directory to working source code directory
# 4. Does a git clone of the repository supplied as the command line argument
# 5. Moves back to the working directory for the pipeline

repo=$1
repoPath=$2
gituser=$3
sourceDir=${repo}-${BUILD_ID}
homeDir=$(pwd)

echo "repo is: $repo"
echo "sourceDir is: $sourceDir"
echo "homeDir is: $homeDir"


# Access token to the git repository containing the ACE application source code is achieved by personal access token
# The token is read from a file on the Jenkins server in this example
# Devising an alternative solution for authenticating to git repository is advised when making a live pipeline
token=$(cat ~/git.txt)

# Make the working source code directory for this instance of the build
echo "mkdir ${homeDir}/${sourceDir}"
mkdir ${homeDir}/${sourceDir}

# Move to the working directory
cd ${homeDir}/${sourceDir}

# Perform git clone to pull down the ACE application source to server
git clone https://${gituser}:${token}@github.com/${repoPath}/${repo}.git

if [ $? != 0 ]; then
   echo "git clone failed"
   echo "Go back to cd $homeDir"
   cd $homeDir
   exit 78
fi

# Move back to directory that script was executed from
cd $homeDir

echo "Source for ACE application pulled from repo $repo and stored in $sourceDir"
