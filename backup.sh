#!/bin/bash	

CONFIG_FILE="./backup.config"
LOCK_FILE="/tmp/backup.lock"

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOGFILE"
}

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    source "$CONFIG_FILE"
    mkdir -p "$BACKUP_DESTINATION"
    touch "$LOGFILE"
}

cleanup_old_backups() {
    log "INFO: Cleaning up old backups..."
    find "$BACKUP_DESTINATION" -type f -name "*.tar.gz" -mtime +30 -exec rm -f {} \; -print | while read file; do
        log "INFO: Deleted old backup: $file"
    done
}

create_checksum() {
    local file="$1"
    local checksum_file="${file}.sha256"
    $CHECKSUM_CMD "$file" > "$checksum_file"
}

verify_backup() {
    local file="$1"
    local checksum_file="${file}.sha256"

    if ! $CHECKSUM_CMD -c "$checksum_file" &>/dev/null; then
        log "FAILED: Checksum verification failed for $file"
        return 1
    fi

    mkdir -p /tmp/test_extract
    if ! tar -tzf "$file" >/dev/null 2>&1; then
        log "FAILED: Backup file is corrupted!"
        return 1
    fi

    log "SUCCESS: Backup verified successfully!"
    rm -rf /tmp/test_extract
    return 0
}

create_backup() {
    local source="$1"
    local date_stamp
    date_stamp=$(date +"%Y-%m-%d-%H%M")
    local backup_file="$BACKUP_DESTINATION/backup-$date_stamp.tar.gz"

    log "INFO: Starting backup of $source"

    local exclude_args=()
    IFS=',' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    for pattern in "${patterns[@]}"; do
        exclude_args+=(--exclude="$pattern")
    done

    tar czf "$backup_file" "${exclude_args[@]}" "$source"
    if [ $? -ne 0 ]; then
        log "FAILED: Error creating backup archive!"
        exit 1
    fi

    log "SUCCESS: Backup created: $backup_file"
    create_checksum "$backup_file"
    verify_backup "$backup_file"
}

dry_run() {
    local source="$1"
    echo "Would backup folder: $source"
    echo "Would exclude: $EXCLUDE_PATTERNS"
    echo "Would save to: $BACKUP_DESTINATION/backup-$(date +%Y-%m-%d-%H%M).tar.gz"
    echo "Would keep last: $DAILY_KEEP daily, $WEEKLY_KEEP weekly, $MONTHLY_KEEP monthly backups"
}

check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        echo "Another backup process is already running!"
        exit 1
    fi
    touch "$LOCK_FILE"
}

cleanup_lock() {
    rm -f "$LOCK_FILE"
}

main() {
    if [ "$1" == "--dry-run" ]; then
        load_config
        dry_run "$2"
        exit 0
    fi

    if [ -z "$1" ]; then
        echo "Usage: $0 [--dry-run] /path/to/source_folder"
        exit 1
    fi

    check_lock
    trap cleanup_lock EXIT

    load_config
    SOURCE_FOLDER="$1"

    if [ ! -d "$SOURCE_FOLDER" ]; then
        log "FAILED: Source folder not found!"
        exit 1
    fi

    create_backup "$SOURCE_FOLDER"
    cleanup_old_backups
    cleanup_lock
    log "INFO: Backup process completed successfully!"
}

main "$@"

