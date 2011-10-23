echo "importing packup to local postgres"
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U benvarim -d benvarim latest.dump
echo "cleaning emails"
rake clean_emails_from_local_db
