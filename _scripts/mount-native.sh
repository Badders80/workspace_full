#!/bin/bash
# Auto-mount native ext4 storage

VHDX_PATH="/mnt/s/WSL_Native_Storage/ext4.vhdx"
MOUNT_POINT="/mnt/native"

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "Native storage already mounted at $MOUNT_POINT"
    exit 0
fi

# Check if loop device exists
LOOP_DEV=$(sudo losetup -j "$VHDX_PATH" | cut -d: -f1)

if [ -z "$LOOP_DEV" ]; then
    # Create loop device
    sudo losetup -fP "$VHDX_PATH"
    LOOP_DEV=$(sudo losetup -j "$VHDX_PATH" | cut -d: -f1)
fi

# Mount
sudo mkdir -p "$MOUNT_POINT"
sudo mount "$LOOP_DEV" "$MOUNT_POINT"
sudo chown -R evo:evo "$MOUNT_POINT"

echo "Native storage mounted at $MOUNT_POINT"
df -h "$MOUNT_POINT"
