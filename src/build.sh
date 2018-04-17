#!/bin/bash

# Get current working directory
BASEDIR=$(dirname "$0")

if [ "$BASEDIR" == "." ]; then
   BASEDIR=$(pwd)
fi

# Check if the script has been executed using sudo
if [ ! "$EUID" == 0 ]
  then echo "You must run this program as root or using sudo!"
  exit
fi

# Set application constants
BUILD_DIR="$BASEDIR/../build"
EFI_DIR="$BASEDIR/efi"
BOOT_MANAGER_DIR="$BASEDIR/boot_manager"
GCC_COMPILER='gcc'

# Delete the previous build
rm -rf $BUILD_DIR

# Run Compiler for Boot Manager app if script is executed in macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Create a macOS build folder
    mkdir -p "$BUILD_DIR/macos"

    xcode-select --install
    xcode-select -s /Applications/Xcode.app/Contents/Developer
    xcodebuild -project "$BOOT_MANAGER_DIR/Boot Manager.xcodeproj" -alltargets -configuration Release
    xcode-select --switch /Library/Developer/CommandLineTools

    cp -r "$BOOT_MANAGER_DIR/build/Release/Boot Manager.app" "$BUILD_DIR/macos/"

    # Clean rules for Xcode build
    rm -rf "$BOOT_MANAGER_DIR/build/Boot Manager.build"
    rm -rf "$BOOT_MANAGER_DIR/build/Release"
    rm -rf "$BOOT_MANAGER_DIR/build/SharedPrecompiledHeaders"

    # Exit from the script, Next Loader can't be compiled in macOS
    exit
fi

# Create the build dir
mkdir -p "$BUILD_DIR/x64/loader/drivers_x64"
mkdir "$BUILD_DIR/x64/loader/tools_x64"
mkdir "$BUILD_DIR/x64/loader/themes"

mkdir -p "$BUILD_DIR/ia32/loader/drivers_ia32"
mkdir "$BUILD_DIR/ia32/loader/tools_ia32"
mkdir "$BUILD_DIR/ia32/loader/themes"

mkdir -p "$BUILD_DIR/aa64/loader/drivers_aa64"
mkdir "$BUILD_DIR/aa64/loader/tools_aa64"
mkdir "$BUILD_DIR/aa64/loader/themes"

# Compile Next Loader UEFI Application
export WORKSPACE="$BASEDIR/edk2/UDK2014/MyWorkSpace"
export EDK_TOOLS_PATH="$WORKSPACE/BaseTools"

mkdir -p /usr/local/UDK2014/
ln -s "$WORKSPACE" "/usr/local/UDK2014"

(cd "$EFI_DIR" && make all CC=$GCC_COMPILER)
(cd "$EFI_DIR" && make fs CC=$GCC_COMPILER)
(cd "$EFI_DIR" && make gptsync CC=$GCC_COMPILER --always-make)

cp "$EFI_DIR/loader/loader_x64.efi" "$BUILD_DIR/x64/loader/" >/dev/null 2>&1
cp "$EFI_DIR/loader/loader_ia32.efi" "$BUILD_DIR/ia32/loader/" >/dev/null 2>&1
cp "$EFI_DIR/loader/loader_aa64.efi" "$BUILD_DIR/aa64/loader/" >/dev/null 2>&1

cp "$EFI_DIR/filesystems/reiserfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ntfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/iso9660_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/hfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext4_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext2_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/btrfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1

cp "$EFI_DIR/filesystems/reiserfs_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ntfs_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/iso9660_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/hfs_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext4_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext2_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/btrfs_ia32.efi" "$BUILD_DIR/ia32/loader/drivers_ia32/" >/dev/null 2>&1

cp "$EFI_DIR/filesystems/reiserfs_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ntfs_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/iso9660_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/hfs_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext4_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/ext2_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1
cp "$EFI_DIR/filesystems/btrfs_aa64.efi" "$BUILD_DIR/aa64/loader/drivers_aa64/" >/dev/null 2>&1

cp "$EFI_DIR/gptsync/gptsync_x64.efi" "$BUILD_DIR/x64/loader/tools_x64" >/dev/null 2>&1
cp "$EFI_DIR/gptsync/gptsync_ia32.efi" "$BUILD_DIR/ia32/loader/tools_ia32" >/dev/null 2>&1
cp "$EFI_DIR/gptsync/gptsync_aa64.efi" "$BUILD_DIR/x64/loader/tools_aa64" >/dev/null 2>&1

cp -r "$EFI_DIR/icons" "$BUILD_DIR/x64/loader/" >/dev/null 2>&1
cp -r "$EFI_DIR/keys" "$BUILD_DIR/x64/" >/dev/null 2>&1
cp -r "$EFI_DIR/scripts" "$BUILD_DIR/x64/" >/dev/null 2>&1
cp "$EFI_DIR/images/font.png" "$BUILD_DIR/x64/loader/" >/dev/null 2>&1
cp "$EFI_DIR/images/VolumeIcon.icns" "$BUILD_DIR/x64/" >/dev/null 2>&1

cp -r "$EFI_DIR/icons" "$BUILD_DIR/ia32/loader/" >/dev/null 2>&1
cp -r "$EFI_DIR/keys" "$BUILD_DIR/ia32/" >/dev/null 2>&1
cp -r "$EFI_DIR/scripts" "$BUILD_DIR/ia32/" >/dev/null 2>&1
cp "$EFI_DIR/images/font.png" "$BUILD_DIR/ia32/loader/" >/dev/null 2>&1
cp "$EFI_DIR/images/VolumeIcon.icns" "$BUILD_DIR/ia32/" >/dev/null 2>&1

cp -r "$EFI_DIR/icons" "$BUILD_DIR/aa64/loader/" >/dev/null 2>&1
cp -r "$EFI_DIR/keys" "$BUILD_DIR/aa64/" >/dev/null 2>&1
cp -r "$EFI_DIR/scripts" "$BUILD_DIR/aa64/" >/dev/null 2>&1
cp "$EFI_DIR/images/font.png" "$BUILD_DIR/aa64/loader/" >/dev/null 2>&1
cp "$EFI_DIR/images/VolumeIcon.icns" "$BUILD_DIR/aa64/" >/dev/null 2>&1

# Add prebuilt components to the build
cp "$EFI_DIR/prebuilt/drivers_x64/apfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/cr_screenshot_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/data_hub_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/fat_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/grub_exfat_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/grub_iso9660_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/grub_ntfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/grub_udf_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/apfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/hfs_plus_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/nvm_express_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/osx_fat_binary_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/pci_nvme_drv.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/ps2_mouse_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/usb_kb_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/usb_mouse_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/xhci_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/drivers_x64/zfs_x64.efi" "$BUILD_DIR/x64/loader/drivers_x64/" >/dev/null 2>&1

cp "$EFI_DIR/prebuilt/tools_x64/dbounce_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/dhclient_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/drawbox_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/dumpfv_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/dumpprot_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/ed_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/edit_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/ftp_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/gdisk_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/hexdump_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/hostname_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/ifconfig_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/loadarg_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/ping_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/pppd_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/route_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/shell_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/tcpipv4_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/textmode_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1
cp "$EFI_DIR/prebuilt/tools_x64/which_x64.efi" "$BUILD_DIR/x64/loader/tools_x64/" >/dev/null 2>&1

# Delete uncompiled architectures
if [ ! -e "$BUILD_DIR/x64/loader/loader_x64.efi" ]; then
    rm -rf "$BUILD_DIR/x64/"
fi 

if [ ! -e "$BUILD_DIR/ia32/loader/loader_ia32.efi" ]; then
    rm -rf "$BUILD_DIR/ia32/"
fi 

if [ ! -e "$BUILD_DIR/aa64/loader/loader_aa64.efi" ]; then
    rm -rf "$BUILD_DIR/aa64/"
fi 

# Compile UDK2018 Base tools
#export WORKSPACE="$BASEDIR/edk2/UDK2018/MyWorkSpace"
#export EDK_TOOLS_PATH="$WORKSPACE/BaseTools"

#(cd "$EDK_TOOLS_PATH" && export WORKSPACE="$WORKSPACE" && export EDK_TOOLS_PATH="$EDK_TOOLS_PATH" && make CC=$GCC_COMPILER)

# Compile UDK2018 MdeModulePkg
#(cd "$EDK_TOOLS_PATH/BinWrappers/PosixLike" && export WORKSPACE="$WORKSPACE" && export EDK_TOOLS_PATH="$EDK_TOOLS_PATH" && ./build -p MdeModulePkg/MdeModulePkg.dsc)

# Change file permissions
chmod -R 755 "$BUILD_DIR"

# Clean rules for build
#(cd "$EDK_TOOLS_PATH" && make clean)
(cd "$EFI_DIR" && make clean)

unlink "/usr/local/UDK2014/MyWorkSpace"
rm -rf /usr/local/UDK2014/
rm -rf "$WORKSPACE/Build"
