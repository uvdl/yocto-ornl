#!/bin/bash

# The purpose of this script is to automate the set up that is involved with Yocto, following all the 
# instructions to set up the environment is tedious.  This script will be able to set up the entire build
# environment or just run the build script so you can ran bitbake.

# =================================================================================
# GLOBAL VARIABLES
# =================================================================================
YOCTO_DIR_LOCATION="$HOME"
YOCTO_VERSION=sumo
TARGET_MACHINE=""

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
function install_dependencies()
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
            exit 1
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
            exit 1
    fi
}

# =================================================================================
#
# =================================================================================
function run_build()
{
    
    # Need to have git configuration set for repo
    if [[ $(git config --get user.name) == "" ]]
        then
            prompt_user_git_info
    fi
    
    # Need to prepare the machine platorm, default is Variscite
    case "$TARGET_MACHINE" in
    var-som-mx6-ornl)
        sync_variscite_platform
        ;;
    jetson-xavier-nx-devkit-emmc)
        sync_xavier_platform
        ;;
    *)
        echo "${BOLD}No matching machine listed... ${NORMAL}"
        exit 1
    esac

    # Check the current ornl yocto repo
    copying_ornl_layer
    # make the build directory and
    # Run the setup script
    if [ ! -d $YOCTO_DIR_LOCATION/build_ornl ]
        then
            make_build_dir
    fi

    # copy config files for the desired TARGET_MACHINE
    copy_config_files

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
    # Need repo in the next steps
    check_for_bin_repo

    mkdir -p $YOCTO_DIR_LOCATION
    if [ $? -ne 0 ]
        then
            echo
            echo "========================================================="
            echo "${BOLD}Creating Yocto build directory failed...${NORMAL}"
            echo "========================================================="
            exit 1
    fi
    OLD_LOCATION=$PWD
    eval cd $YOCTO_DIR_LOCATION
    repo init -u https://github.com/varigit/variscite-bsp-platform.git -b $YOCTO_VERSION
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================"
            echo "${BOLD}Failed to fetch Varisicte repo${NORMAL}"
            echo "================================================"
            exit 1
    fi
    repo sync -j4
    if [ $? -ne 0 ]
        then
            echo
            echo "==============================================="
            echo "${BOLD}Failed to sync Varisicte repo${NORMAL}"
            echo "==============================================="
            exit 1
    fi
    eval cd $OLD_LOCATION
}

# =================================================================================
#
# =================================================================================
function sync_xavier_platform()
{
    mkdir -p $YOCTO_DIR_LOCATION/sources
    if [ $? -ne 0 ]
        then
            echo
            echo "========================================================="
            echo "${BOLD}Creating Yocto build directory failed...${NORMAL}"
            echo "========================================================="
            exit 1
    fi

    OLD_LOCATION=$PWD
    eval cd $YOCTO_DIR_LOCATION/sources
    if [ ! -d "poky" ]
        then
        git clone -b gatesgarth git://git.yoctoproject.org/poky.git
        if [ $? -ne 0 ]
        then
            echo
            echo "==============================================="
            echo "${BOLD}Failed to clone Poky${NORMAL}"
            echo "==============================================="
            exit 1
        fi
    fi
    if [ ! -d "meta-openembedded" ]
        then
        git clone -b gatesgarth https://github.com/openembedded/meta-openembedded.git
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone openembedded${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi
    if [ ! -d "meta-python2" ]
        then
        git clone https://git.openembedded.org/meta-python2/
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone python2${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi
    if [ ! -d "meta-swupdate" ]
        then
        git clone -b master https://github.com/sbabic/meta-swupdate.git
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone swupdate${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi
    if [ ! -d "meta-tegra" ]
        then
        git clone -b gatesgarth https://github.com/OE4T/meta-tegra.git
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone tegridy farms${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi
    eval cd $OLD_LOCATION
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
                    exit 1
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
                    exit 1
            fi
            chmod a+x ~/bin/repo
            export PATH=~/bin:$PATH
    fi
}

# =================================================================================
#
# =================================================================================
function copying_ornl_layer()
{
    # Ok now we know to some extent that the directories are available to us, move on.
    cp -r sources/meta-ornl $YOCTO_DIR_LOCATION/sources
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Copy of ORNL layer failed...${NORMAL}"
            echo "============================================"
            exit 1
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
function make_build_dir()
{
    OLD_DIR=${PWD}
    # From scope of script change into the directory.
    eval cd $YOCTO_DIR_LOCATION/

    case "$TARGET_MACHINE" in
    var-som-mx6-ornl)
        # Run Variscite environment script
        MACHINE=$TARGET_MACHINE DISTRO=fslc-framebuffer . $YOCTO_DIR_LOCATION/setup-environment build_ornl
        if [ $? -ne 0 ]
            then
                echo
                echo "======================================================"
                echo "${BOLD}Variscite environment script failed...${Normal}"
                echo "======================================================"
                exit 1
        fi
        ;;
    jetson-xavier-nx-devkit-emmc)
        . $YOCTO_DIR_LOCATION/sources/poky/oe-init-build-env build_ornl
        if [ $? -ne 0 ]
            then
                echo
                echo "======================================================"
                echo "${BOLD}Variscite environment script failed...${Normal}"
                echo "======================================================"
                exit 1
        fi
        ;;
    esac

    eval cd ${OLD_DIR}
}

# =================================================================================
#
# =================================================================================
function copy_config_files()
{
    # Make sure the build directory actually exists
    if [ ! -d $YOCTO_DIR_LOCATION ]
        then 
            echo
            echo "====================================================================="
            echo "${BOLD}$YOCTO_DIR_LOCATION/ does not exist...${NORMAL}"
            echo "====================================================================="
            exit 1
    fi

    # lets do our copying of modified config files IF a new setup was completed
    # TODO :: This copies no matter what, we should do a file compare here.
    echo
    echo "Copying the ORNL local.conf file over... "
    echo
    cp -f build/conf/$TARGET_MACHINE/local.conf $YOCTO_DIR_LOCATION/build_ornl/conf/
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Copy of local.conf failed...${NORMAL}"
            echo "============================================"
            exit 1
    fi

    echo
    echo "Copying the ORNL bblayers.conf file over... "
    echo
    cp -f build/conf/$TARGET_MACHINE/bblayers.conf $YOCTO_DIR_LOCATION/build_ornl/conf/
    if [ $? -ne 0 ]
        then
            echo
            echo "================================================="
            echo "${BOLD}Copy of bblayers.conf failed...${NORMAL}"
            echo "================================================="
            exit 1
    fi

    if [ $TARGET_MACHINE == "var-mx6-som-ornl" ]
        then
            echo
            echo "Copying the ORNL Variscite Build Script file over... "
            echo
                # Copy the Variscite script over
            cp -f BuildScripts/var-create-yocto-sdcard.sh $YOCTO_DIR_LOCATION/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh
            if [ $? -ne 0 ]
                then
                    echo
                    echo "================================================="
                    echo "${BOLD}Copy of SD card build script failed...${NORMAL}"
                    echo "================================================="
                    exit 1
            fi
    fi
}

# =================================================================================
#
# =================================================================================
function copy_ornl_layer()
{
    # Make sure the build directory actually exists
    if [ ! -d $YOCTO_DIR_LOCATION ]
        then 
            echo
            echo "====================================================================="
            echo "${BOLD}$YOCTO_DIR_LOCATION/$YOCTO_DIR_NAME does not exist...${NORMAL}"
            echo "====================================================================="
            exit 1
    fi

    echo
    echo "Copying the ORNL source ... "
    echo
    cp -rf ../sources/meta-ornl $YOCTO_DIR_LOCATION/sources/meta-ornl
    if [ $? -ne 0 ]
        then
            echo
            echo "============================================"
            echo "${BOLD}Copy of ornl layer source failed...${NORMAL}"
            echo "============================================"
            exit 1
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
    echo "Usage : ./ornl-setup-yocto.sh [option [optarg1]] abs_build_directory"
    echo "--------------------------------------------------------------------------------"
    echo "options : "
    echo "-m : target machine: var-mx6-som-ornl or jetson-xavier-nx-devkit-emmc"
    echo "-h : A friendly reminder of how this script works"
    echo "--------------------------------------------------------------------------------"
    echo
    echo "${BOLD}Before running this script please set git config user.name and user.email${NORMAL}"
    echo
    echo
    exit 0
}

# =================================================================================
# Script Start
# =================================================================================

# This looks awful, TODO :: change this to not be so clunky
# Basically we have to have > 1 arguments and less than 5. and no odd numbers 
if [ $# -ne 3 ]
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
        case "$lets_ride" in
            Y|y)
                ;;
            *)
                exit 0
                ;;
        esac
fi

YOCTO_DIR_LOCATION=$3

# Check what version of Ubuntu we are running.  We are compatible with 16.04
ubuntu_release=$(cut -f2 <<< "$(lsb_release -r)")

if [[ ("$ubuntu_release" != "16.04") && ("$ubuntu_release" != "18.04") ]]
    then
        echo
        echo "${BOLD}Using Ubuntu Version $ubuntu_release${NORMAL}"
        echo "${BOLD}This build is only guaranteed to work with Ubuntu 16.04 or Ubuntu 18.04${NORMAL}"
fi

# Parse any / all options that were passed in to the script
while getopts "h?m:c:" opt; do
    case "$opt" in
    h|\?)
        help_menu
        ;;
    m)
        TARGET_MACHINE=$2
        ;;
    esac
done

if [ "$TARGET_MACHINE" == "var-mx6-som-ornl" ]
    then
        YOCTO_VERSION="sumo"
fi
if [ "$TARGET_MACHINE" == "jetson-xavier-nx-devkit-emmc" ]
    then
        YOCTO_VERSION="gatesgarth"
fi

# Give user a review of what has been entered
echo 
echo "Yocto Version is ${BOLD}$YOCTO_VERSION${NORMAL}"
echo "Build Location is ${BOLD}$YOCTO_DIR_LOCATION${NORMAL}"
echo

# Run the full environment build at this point
run_build

