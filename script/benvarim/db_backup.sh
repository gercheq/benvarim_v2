#db backup script to fetch backups from heroku and send to an email address
#author: yigit
#requires backup_id.sh script withing the same folder!
now=`date`
#list backups
echo "listing backups"
cmd="sh backup_id.sh"
bid=`$cmd`
echo "backup id "$bid
#delete backup
echo "deleting backup"
cmd="heroku pgbackups:destroy --app bprod "$bid
$cmd
#add backup
echo "adding backup"
heroku pgbackups:capture --app bprod;
#fetch backup
echo "fetching latest backup"
curl -o latest.dump `heroku pgbackups:url --app bprod`;
#email it
echo "emailing backup"
uuencode latest.dump benvarim_prod | mail -s "db backup $now" iletisim@benvarim.com
#delete it
echo "deleting backup"
rm -rf latest.dump
# mv latest.dump "$now.dump"