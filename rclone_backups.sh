#!/bin/bash
### NOTICE: Apply permission to execute: chmod +x /usr/local/bin/rclone_backup
# cronjob
# EDITOR=nano crontab -e
# 0 3 * * * sh /usr/local/bin/rclone_backup > /dev/null 2>&1

SERVER_NAME=SERVER.DATA
REMOTE_NAMES=gdrive #support multi remote, ex: gdrive,yandex

TIMESTAMP=$(date +"%F")
WWW_DIR="/var/www"
BACKUP_DIR="/.backups/$TIMESTAMP"
BACKUP_LOCK="/.backups/backup.lock"
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
SECONDS=0

function in_array {
  ARRAY=$2
  for e in ${ARRAY[*]}
  do
    if [[ "$e" == "$1" ]]
    then
      return 0
    fi
  done
  return 1
}

if [ ! -f $BACKUP_LOCK ]; then
  mkdir -p "$BACKUP_DIR"

  touch $BACKUP_LOCK

  mkdir -p "$BACKUP_DIR/mysql"
  databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)"`

  echo "Starting Backup Database";

  for db in $databases; do
    $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/mysql/$db.sql.gz"
  done
  echo " ✈ Finished";
  echo '';

  echo "Starting Backup Website";
  # Loop through /home directory
  exclude_folder=("backups" "cake-dev" "cgi-bin" "error" "icons" "noindex")
  for D in $WWW_DIR/*; do
    if [ -d "${D}" ]; then #If a directory
      domain=${D##*/} # Domain name
	  if ! in_array "$domain" "${exclude_folder[*]}"
	  then
		  available_folder=1
	  else
		  available_folder=0
	  fi
      if [ "$available_folder" == "1" ]; then
        echo "- "$domain;
        #zip -r $BACKUP_DIR/$domain.zip $WWW_DIR/$domain -q -x "$WWW_DIR/$domain/**\*/wp-content/cache/**\*" #Exclude cache
        tar -zcvf $BACKUP_DIR/$domain.tar.gz $WWW_DIR/$domain --exclude=$WWW_DIR/$domain/*/wp-content/cache/* #Exclude cache
      fi
    fi
  done
  echo " ✈ Finished";
  echo '';

  if [ -d /etc/nginx/ ]; then
	  echo "Starting Backup Nginx Configuration";
	  mkdir -p $BACKUP_DIR/nginx/
	  cp -r /etc/nginx/ $BACKUP_DIR/nginx/
	  echo " ✈ Finished";
	  echo '';
  fi

  echo "Starting Backup Apache config";
  mkdir -p $BACKUP_DIR/apache/
  if [ -d /etc/httpd/ ]; then
    cp -r /etc/httpd/ $BACKUP_DIR/httpd/
  fi
  if [ -d /usr/local/apache/ ]; then
    cp -r /usr/local/apache/ $BACKUP_DIR/apache/
  fi
  echo " ✈ Finished";
  echo '';

  echo "Starting Backup Cronjob";
  mkdir -p $BACKUP_DIR/cron/
  sudo cp -r /var/spool/cron/ $BACKUP_DIR/cron/
  echo " ✈ Finished";
  echo '';

  if [ -d /root/.acme.sh/ ]; then
	  echo "Starting Backup acme.sh";
	  mkdir -p $BACKUP_DIR/acme.sh/
	  cp -r /root/.acme.sh/ $BACKUP_DIR/acme.sh/
	  echo " ✈ Finished";
	  echo '';
  fi

  if [ -d /root/letsencrypt/ ]; then
	  echo "Starting Backup Letsencrypt";
	  mkdir -p $BACKUP_DIR/letsencrypt/
	  cp -r /root/letsencrypt/ $BACKUP_DIR/letsencrypt/
	  echo " ✈ Finished";
	  echo '';
  fi
  
  sudo chown -R $USER:$USER $BACKUP_DIR  
  sudo touch /var/log/rclone.log  
  sudo chown -R $USER:$USER /var/log/rclone.log

  size=$(du -sh $BACKUP_DIR | awk '{ print $1}')

  echo "Starting Uploading Backup";
  IFS=',' read -r -a REMOTE_NAME_ARR <<< "$REMOTE_NAMES"
  for REMOTE_NAME in "${REMOTE_NAME_ARR[@]}"
  do
    echo "  - $REMOTE_NAME:";
    rclone mkdir "$REMOTE_NAME:$SERVER_NAME" #Make the path if it doesn't already exist.
    rclone copy $BACKUP_DIR "$REMOTE_NAME:$SERVER_NAME/$TIMESTAMP" >> /var/log/rclone.log 2>&1
    rclone -q --min-age 7d delete "$REMOTE_NAME:$SERVER_NAME" #Remove all backups older than 7 day
    rclone -q --min-age 7d rmdirs "$REMOTE_NAME:$SERVER_NAME" #Remove all empty folders older than 7 day
    rclone cleanup "$REMOTE_NAME:" #Cleanup Trash
  done
  # Clean up local backup
  sudo rm -rf $BACKUP_DIR
  echo " ✈ Finished";
  echo '';

  duration=$SECONDS
  echo "Total $size, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
  
  rm -f $BACKUP_LOCK
else
  echo "Backup action is running...";
fi
