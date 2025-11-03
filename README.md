**Complete Template of the project**

```
 # Backup Automation Script (backup.sh)

### *1. Installation*
Clone this repository and navigate to the folder:
```bash
git clone https://github.com/<your-username>/backup-system.git
cd backup-system
```
Make the script executable:
```
chmod 744 backup.sh
```
create the configuration file to match your environment:

vim backup.config

*2️.Basic Usage*

Run the script by giving a source folder:
```
./backup.sh /path/to/source_folder
```
*3️.Optional: Dry Run Mode*

To see what the script would do without actually creating backups:
```
./backup.sh --dry-run /path/to/source_folder
```
 **How It Works**
* Step 1: Configuration*

The script reads backup settings (like destination folder, rotation count, etc.) from backup.config.

Example config:
```
BACKUP_DIR="/c/Users/Lenovo/backups"
ROTATE_COUNT=5
CHECKSUM_FILE="checksums.md5"
```
*Step 2: Backup Creation*

The script:

1.Creates a timestamped .tar.gz archive
2.Saves it in your backup folder
3.Generates a checksum file for verification

*Step 3: Verification*

After the backup, it uses sha256sum to verify file integrity.

* Step 4: Rotation*

If the number of backups exceeds the configured limit (like 5),
the script automatically deletes the oldest backup.

*Folder Structure*
```
backup-system/
├── backup.sh
├── backup.config
└── README.md

Backup Destination:
C:/Users/Lenovo/backups/
 ├── backup-2025-11-03-1520.tar.gz
 ├── backup-2025-11-03-1530.tar.gz
 ├── checksums.md5
```

|*Errrors (or) Challanges     |             *solution*|
|-Permission errors(windows paths) |    changed the path to mypath.|
|-Handling missing folders          |   Added if checks and clear error messages|

**Testing**
*Test 1: Successful Backup*
```
./backup.sh /c/Users/Lenovo/Documents
```
Output is like this:

<img width="1104" height="225" alt="image" src="https://github.com/user-attachments/assets/e37e93ca-ff82-4418-af6a-425595aa3610" />

*Test 2: Dry Run*
```
./backup.sh --dry-run /c/Users/Lenovo/Documents
```

Output is like this:

<img width="988" height="161" alt="image" src="https://github.com/user-attachments/assets/980bcd4d-2d4b-4974-9c42-0e0d81019c59" />

*Test 3: Missing Folder*
```
./backup.sh /wrong/path
```
Output is like this:


<img width="969" height="77" alt="image" src="https://github.com/user-attachments/assets/ac543c35-df32-4c27-aa4b-3c6e35ddc056" />





