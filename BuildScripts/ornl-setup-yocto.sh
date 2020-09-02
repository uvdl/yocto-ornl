#!/bin/bash

# The purpose of this script is to automate the set up that is involved with Yocto, following all the 
# instructions to set up the environment is tedious.  This script will be able to set up the entire build
# environment or just run the build script so you can ran bitbake.

# =================================================================================
# GLOBAL VARIABLES
# =================================================================================
ORNL_YOCTO_BRANCH="develop"
YOCTO_DIR_LOCATION=${PWD}
YOCTO_VERSION=sumo
TARGET_MACHINE=var-som-mx6-ornl
readonly YOCTO_DIR_NAME=ornl-dart-yocto

# =================================================================================
# GLOBAL TERMINAL MODIFIERS
# =================================================================================
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$'\e[1;32m'
CYAN=$'\e[1;36m'
END_COLOR=$'\e[0m'

# =================================================================================
# FUNCTIONS
# =================================================================================
function run_all()
{
    echo 
    echo "${BOLD}Installing host dependencies${NORMAL}"
    echo
    # First check to see if all dependencies have been downloaded
    sudo apt-get install -y gawk \
                            wget \
                            git-core \
                            diffstat \
                            unzip \
                            texinfo \
                            gcc-multilib \
                            build-essential \
                            chrpath \
                            socat \
                            cpio \
                            python \
                            python3 \
                            python3-pip \
                            python3-pexpect \
                            xz-utils \
                            debianutils \
                            iputils-ping \
                            libsdl1.2-dev \
                            xterm
    # Checking for install failures
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================="
            echo "${BOLD}Dependencies failed to install ${NORMAL}"
            echo "================================================="
            return 1
    fi
    # More host dependencies
    sudo apt-get install -y autoconf \
                            libtool \
                            libglib2.0-dev \
                            libarchive-dev \
                            python-git \
                            sed \
                            cvs \
                            subversion \
                            coreutils \
                            texi2html \
                            docbook-utils \
                            python-pysqlite2 \
                            help2man \
                            make \
                            gcc \
                            g++ \
                            desktop-file-utils \
                            libgl1-mesa-dev \
                            libglu1-mesa-dev \
                            mercurial \
                            automake \
                            groff \
                            curl \
                            lzop \
                            asciidoc \
                            u-boot-tools \
                            dos2unix \
                            mtd-utils pv \
                            libncurses5 \
                            libncurses5-dev \
                            libncursesw5-dev \
                            libelf-dev \
                            zlib1g-dev
    # Checking for install failures
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================="
            echo "${BOLD}Dependencies failed to install ${NORMAL}"
            echo "================================================="
            return 1
    fi

    # Need to have git configuration set for repo
    if (($(git config --get user.name) == "" || $(git config --get user.email) == ""))
        then
            prompt_user_git_info
    fi
    
    # Need repo in the next steps
    check_for_bin_repo

    # Need to prepare the machine platorm, default is Variscite
    case "$TARGET_MACHINE" in
    *)
        sync_variscite_platform
        ;;
    esac

    # Check the current ornl yocto repo
    checking_ornl_layer
    # Run the setup script
    run_setup_script

    echo
    echo
    echo "${BOLD}${GREEN}SUCCESS!!!!${END_COLOR}${NORMAL}"
    echo
    echo

}

# =================================================================================
#
# =================================================================================
function sync_variscite_platform()
{
    mkdir -p $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME
    if [ $? -ne 0 ]
        then
            echo
            echo "========================================================="
            echo "${BOLD}Creating Yocto build directory failed...${NORMAL}"
            echo "========================================================="
            return 1
    fi
    eval cd $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME
    repo init -u https://github.com/varigit/variscite-bsp-platform.git -b $YOCTO_VERSION
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================"
            echo "${BOLD}Failed to fetch Varisicte repo${NORMAL}"
            echo "================================================"
            return 1
    fi
    repo sync -j4
    if [ $? -ne 0 ]
        then
            echo
            echo "==============================================="
            echo "${BOLD}Failed to sync Varisicte repo${NORMAL}"
            echo "==============================================="
            return 1
    fi

}

# =================================================================================
#
# =================================================================================
function check_for_bin_repo()
{
    # Check for the bin directory in ~
    if [ ! -d ~/bin ]
        then
            # bin doesn't exist at home, lets create it
            mkdir ~/bin
            if [ $? -ne 0 ]
                then
                    echo
                    echo "====================================================="
                    echo "${BOLD}Failed making the bin directory...${NORMAL}"
                    echo "====================================================="
                    return 1
            fi
    fi
    # bin exists at this point, need to check for repo
    if [ ! -f ~/bin/repo ]
        then
            curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
            if [ $? -ne 0 ]
                then
                    echo
                    echo "============================================"
                    echo "${BOLD}Failed the curl repo command..."
                    echo "============================================"
                    return 1
            fi
            chmod a+x ~/bin/repo
            export PATH=~/bin:$PATH
    fi
}

# =================================================================================
#
# =================================================================================
function checking_ornl_layer()
{
    # I'm assuming that IF you are running this script you have cloned the yocto-ornl repo
    # but lets check to make sure everything is here... unless they used the -c option
    if [ $ORNL_YOCTO_BRANCH != "" ]; then
        download_ornl_layer
    else
        if [ ! -d "../sources/meta-ornl" ]
            then   
                echo
                echo "No ORNL Yocto Layer found, cloning the yocto-ornl repo"
                download_ornl_layer
        fi
        if [! -d "../build/conf" ]
            then
                echo
                echo "No ORNL conf directory found, cloning the yocto-ornl repo"
                download_ornl_layer
        fi
    fi

    # Ok now we know to some extent that the directories are available to us, move on.
    cp -r $YOCTO_DIR_LOCATION/ornl_layer/sources/meta-ornl $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME/sources
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Copy of ORNL layer failed...${NORMAL}"
            echo "============================================"
            return 1
    fi

}

# =================================================================================
# 
# =================================================================================
function download_ornl_layer()
{
    if [ ! -d $YOCTO_DIR_LOCATION/ornl_layer ] || [ -z "$(ls -A $YOCTO_DIR_LOCATION/ornl_layer)" ]
        then
            # Clone ORNL repo and check to make sure the command succeeded
            git clone https://github.com/uvdl/yocto-ornl.git $YOCTO_DIR_LOCATION/ornl_layer
            if [ $? -ne 0 ]
                then
                    echo
                    echo "============================================"
                    echo "${BOLD}Git clone failed...${NORMAL}"
                    echo "============================================"
                    return 1
            fi
    fi
    
    # Checkout the branch needed
    git -C $YOCTO_DIR_LOCATION/ornl_layer checkout $ORNL_YOCTO_BRANCH
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Git failed to get branch...${NORMAL}"
            echo "============================================"
            return 1
    fi
}

# =================================================================================
# 
# =================================================================================
function prompt_user_git_info()
{
    echo "Please enter git user.name : "
    read USER_NAME
    echo "This is user.name : $USER_NAME"
    git config --global user.name $USER_NAME

    echo "Please enter git user.email : "
    read USER_EMAIL
    echo "This is user.email : $USER_EMAIL"
    git config --global user.email $USER_EMAIL
}

# =================================================================================
#
# =================================================================================
function run_setup_script()
{
    # Make sure the build directory actually exists
    if [ ! -d $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME ]
        then 
            echo
            echo "====================================================================="
            echo "${BOLD}$YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME does not exist...${NORMAL}"
            echo "====================================================================="
            return 1
    fi

    # From scope of script change into the directory.
    eval cd $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME

    # Run Variscite environment script
    MACHINE=$TARGET_MACHINE DISTRO=fslc-framebuffer . setup-environment build_ornl
    if [ $? -ne 0 ]
        then
            echo
            echo "======================================================"
            echo "${BOLD}Variscite environment script failed...${Normal}"
            echo "======================================================"
            return 1
    fi

    # lets do our copying of modified config files IF a new setup was completed
    # TODO :: This copies no matter what, we should do a file compare here.
    echo
    echo "Copying the ORNL local.conf file over... "
    echo
    cp -f $YOCTO_DIR_LOCATION/ornl_layer/build/conf/local.conf $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME/build_ornl/conf/
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Copy of local.conf failed...${NORMAL}"
            echo "============================================"
            return 1
    fi

    echo
    echo "Copying the ORNL bblayers.conf file over... "
    echo
    cp -f $YOCTO_DIR_LOCATION/ornl_layer/build/conf/bblayers.conf $YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME/build_ornl/conf/
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================="
            echo "${BOLD}Copy of bblayers.conf failed...${NORMAL}"
            echo "================================================="
            return 1
    fi
}

# =================================================================================
#
# =================================================================================
function help_menu()
{
    echo 
    echo "${BOLD}Looks like you need some assistence! No worries, lets get you fixed up.${NORMAL}"
    echo 
    echo "Usage : ./ornl-setup-yocto.sh [option [optarg1]] [arg1, arg2,]"
    echo "--------------------------------------------------------------------------------"
    echo "options : "
    echo "-b : Runs only the setup build environment [arg1 - location of yocto build directory]"
    echo "-c : Forces a new clone of ORNL Yocto repo [arg1 - name of branch to checkout]"
    echo "-h : A friendly reminder of how this script works"
    echo "--------------------------------------------------------------------------------"
    echo "${BOLD}If no options supplied it is assumed that the full build environment will be set up${NORMAL}"
    echo "${BOLD}${CYAN}-b can only be used independently, it will ONLY run the setup-environment script${END_COLOR}${NORMAL}"
    echo 
    echo "arg1 - The location of where the new yocto build directory will be made"
    echo "arg2 - The version of Yocto to be used: i.e. sumo, thud..."
    echo
    echo
    return 0
}

# =================================================================================
# Script Start
# =================================================================================

# This looks awful, TODO :: change this to not be so clunky
# Basically we have to have > 1 arguments and less than 5. and no odd numbers 
if [ $# -lt 2 ] || [ $# -eq 3 ] || [ $# -gt 4 ]
    then
        help_menu
fi

# Checking for sudo access.
if [ "$EUID" -eq 0 ]
    then
        echo
        echo "You are logged in as root, some directories will be created with root only access if you continue."
        read -p "Do you wish to proceed? [Y/n] " lets_ride
        lets_ride=${lets_ride:-Y}
        if [ $lets_ride != "Y" ] || [ $lets_ride != "y" ]
            then
                return 0
        fi
fi

# Check what version of Ubuntu we are running.  We are compatible with 16.04
ubuntu_release=$(cut -f2 <<< "$(lsb_release -r)")
echo "Usring Ubuntu Version ${BOLD}$ubuntu_release${NORMAL}"

if [ "$ubuntu_release" != "16.04" ]
    then
        echo
        echo "This build is only guaranteed to work with Ubuntu 16.04"
        read -p "Do you wish to proceed [y/N]: " answer
        answer=${answer:-N}
        if [ $answer = "N" ] || [ $answer = "n" ]
            then
                return 0
        fi
fi


# Parse any / all options that were passed in to the script
while getopts "h?b:c:" opt; do
    case "$opt" in
    h|\?)
        help_menu
        ;;
    b)  temp_location="$2"
        # Check to see if the path exists
        if [[ ! -d $temp_location ]]
            then
                echo
                echo "${BOLD}${CYAN}Location does not exist!${END_COLOR}${NORMAL}"
                help_menu
        fi
        # Check to see if it is relative or absolute. We need an absolute
        if [[ "$temp_location" = /* ]]
        then
            YOCTO_DIR_LOCATION=$temp_location
        else
            YOCTO_DIR_LOCATION=${PWD}/$temp_location
        fi

        # Check to see if user sent the ornl_layer in directory
        base=$(basename $YOCTO_DIR_LOCATION)
        if [ $base  == $YOCTO_DIR_NAME ]
            then
                YOCTO_DIR_LOCATION=$(dirname $2)
        fi

        echo 
        echo "Current build location base is $YOCTO_DIR_LOCATION"
        echo
        run_setup_script
        return 0
        ;;
    c)  ORNL_YOCTO_BRANCH=$2
        echo
        echo "ORNL Branch chosen to checkout is $ORNL_YOCTO_BRANCH"
        echo  
        ;;
    esac
done

# Really crappy logic to determine argurment numbers.  There exists a much better way
# TODO :: Figure out that much better way
if [ $# -eq 2 ] 
    then
        temp_location=$1
        YOCTO_VERSION=$2
else
    temp_location=$3
    YOCTO_VERSION=$4
fi

# Check the Yocto version being used is compatible with our system
if [[ "$YOCTO_VERSION" != "sumo" ]] || [[ "$YOCTO_VERSION" != "sumo" ]]
    then
        echo
        echo "============================================================================"
        echo "Please choose a version of Yocto compatible with this system: sumo or thud"
        echo "============================================================================"
        return 1
fi

if [ ! -d $temp_location ]
    then
        echo
        echo "============================================================="
        echo "${BOLD}${CYAN}Location does not exist!${END_COLOR}${NORMAL}"
        echo "============================================================="
        help_menu
fi
# Check to see if it is relative or absolute. We need an absolute
if [[ "$temp_location" = /* ]]
then
    YOCTO_DIR_LOCATION=$temp_location
else
    YOCTO_DIR_LOCATION=${PWD}/$temp_location
fi

# Give user a review of what has been entered
echo 
echo "Yocto Version is ${BOLD}$YOCTO_VERSION${NORMAL}"
echo "Build Location is ${BOLD}$YOCTO_DIR_LOCATION${NORMAL}"
read -p "Are these correct [Y/n]: " acceptance
acceptance=${acceptance:-Y}

# Check to see if we should go on
if [ $acceptance != "Y" ] || [ $acceptance != "y" ]
    then
        help_menu
fi

# Run the full environment build at this point
run_all
