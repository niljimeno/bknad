# BKNad -> File backup cli app
Backup application that copies files from a source to a target,
ignoring already existing files
and deleting files that aren't in the source.

It's meant to be a simpler replacement to rsync
that is less resource-intense (useful for USB backups).

## Usage
```bash
bknad source target

# example:
bknad Music /media/Music
```

## Installation
```bash
# compile it and save it to your bin directory
make
cp bknad /your/bin/directory
```

### To do:
- [ ] replace files with modified timestamp
