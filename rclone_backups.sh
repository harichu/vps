#!/bin/bash
### NOTICE: Apply permission to execute: chmod +x /usr/local/sbin/rclone_backups.sh

SERVER_NAME=LINODE.DATA
REMOTE_NAMES=gdrive,yandex

TIMESTAMP=$(date +"%F")
BACKUP_DIR="/.BACKUPS/$TIMESTAMP"
BACKUP_LOCK="/.BACKUPS/backup.lock"
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
SECONDS=0

if [ ! -f $BACKUP_LOCK ]; then
  mkdir -p "$BACKUP_DIR"

  touch $BACKUP_LOCK

  mkdir -p "$BACKUP_DIR/mysql"
  databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)"`

  echo "Starting Backup Database";

  for db in $databases; do
		$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/mysql/$db.sql.gz"
  done
  echo "Finished";
  echo '';

  echo "Starting Backup Website";
  # Loop through /home directory
  for D in /home/*; do
		if [ -d "${D}" ]; then #If a directory
			domain=${D##*/} # Domain name
			if [ $domain != "backups" ]; then
				echo "- "$domain;
				zip -r $BACKUP_DIR/$domain.zip /home/$domain/ -q -x /home/$domain/*\*/wp-content/cache/**\* #Exclude cache
			fi
		fi
  done
  echo "Finished";
  echo '';

  echo "Starting Backup Nginx Configuration";
  cp -r /etc/nginx/ $BACKUP_DIR/nginx/
  echo "Finished";
  echo '';

  echo "Starting Backup Cronjob";
  cp -r /var/spool/cron/ $BACKUP_DIR/cron/
  echo "Finished";
  echo '';

  echo "Starting Backup Letsencrypt";
  cp -r /etc/letsencrypt/ $BACKUP_DIR/letsencrypt/
  echo "Finished";
  echo '';

  echo "Starting Backup Apache config";
  mkdir -p $BACKUP_DIR/apache/
  cp -r /usr/local/apache/conf/ $BACKUP_DIR/apache/conf/
  cp -r /usr/local/apache/conf.d/ $BACKUP_DIR/apache/conf.d/
  echo "Finished";
  echo '';

  size=$(du -sh $BACKUP_DIR | awk '{ print $1}')

  echo "Starting Uploading Backup";
	IFS=',' read -r -a REMOTE_NAME_ARR <<< "$REMOTE_NAMES"
	for REMOTE_NAME in "${REMOTE_NAME_ARR[@]}"
	do
		#echo "$REMOTE_NAME"	
		/usr/sbin/rclone move $BACKUP_DIR "$REMOTE_NAME:$SERVER_NAME/$TIMESTAMP" >> /var/log/rclone.log 2>&1
		/usr/sbin/rclone -q --min-age 7d delete "$REMOTE_NAME:$SERVER_NAME" #Remove all backups older than 7 day
		/usr/sbin/rclone -q --min-age 7d rmdirs "$REMOTE_NAME:$SERVER_NAME" #Remove all empty folders older than 7 day
	done
  # Clean up
  rm -rf $BACKUP_DIR
  echo "Finished";
  echo '';

  duration=$SECONDS
  echo "Total $size, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
	
	rm -f $BACKUP_LOCK
else
	echo "Backup action is running...";
fi
