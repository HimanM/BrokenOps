#!/bin/bash

# 1. Check if the directory exists
if [ ! -d /var/shared/project ]; then
  echo "FAILURE: The directory /var/shared/project does not exist."
  exit 1
fi

# 2. Check if the directory group is devs
dir_group=$(stat -c "%G" /var/shared/project)
if [ "$dir_group" != "devs" ]; then
  echo "FAILURE: The directory /var/shared/project is owned by group '$dir_group', expected 'devs'."
  exit 1
fi

# 3. Check if setgid bit is set
if [ ! -g /var/shared/project ]; then
  echo "FAILURE: The setgid bit is not set on /var/shared/project."
  exit 1
fi

# 4. Check if all existing files in /var/shared/project belong to devs
while IFS= read -r file; do
  if [ -n "$file" ]; then
    file_group=$(stat -c "%G" "$file")
    if [ "$file_group" != "devs" ]; then
      echo "FAILURE: File '$file' belongs to group '$file_group', expected 'devs'."
      exit 1
    fi
  fi
done <<< "$(find /var/shared/project -mindepth 1 2>/dev/null)"

# 5. Check if new files created inside inherit the group 'devs'
# Run touch as bob
if ! sudo -u bob touch /var/shared/project/.test_verify_file; then
  echo "FAILURE: User bob could not create a file in /var/shared/project."
  exit 1
fi

test_file_group=$(stat -c "%G" /var/shared/project/.test_verify_file)
rm -f /var/shared/project/.test_verify_file

if [ "$test_file_group" != "devs" ]; then
  echo "FAILURE: New files created in the directory inherit group '$test_file_group', expected 'devs'."
  exit 1
fi

echo "SUCCESS: The shared directory has setgid configured correctly, and group permissions are inherited!"
exit 0
