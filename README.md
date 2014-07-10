wp-migrate-scripts
==================

Scripts used for migrating the WordPress database from TribApps hosting with WP 3.2 to WPEngine with WP 3.9.1+.

# Database Migration Sequence

0. SSH to vivelohoy admin server in TribApps AWS infrastructure and resume the vivelohoy screen session:

  ```
  ssh wordpress@admin.wp.tribapps.com -i ~/.ssh/frakkingtoasters.pem
  screen -R 16150.vivelohoy
  ```
  
1. database dump from production vivelohoy RDS DB server (get password from [production_settings.json](https://github.com/vivelohoy/vivelohoy-2.0/blob/master/data/production_settings.json#L45) of vivelohoy 2.0):

  ```
  mysqldump --user=vivelohoy --host=vivelohoy-db.c0petvek1fz0.us-east-1.rds.amazonaws.com --password --quick --skip-lock-tables vivelohoy | sed s/www.vivelohoy.com/WPDEPLOYDOMAN/g | bzip2 > /mnt/apps/sites/vivelohoy/data/data.sql.bz2
  ```
  
2. transfer database dump from vivelohoy admin server to local system
3. load database dump locally in a temporary schema (tmp_vivelohoy_1)

  ```
  mysql --user=root --password --execute='CREATE DATABASE IF NOT EXISTS tmp_vivelohoy_1 CHARACTER SET utf8;'
  mysql --user=root --password tmp_vivelohoy_1 < vivelohoy.sql
  ```
  
4. remove tables related to other blogs that are now defunct:

  ```
  mysql --user=root --password tmp_vivelohoy_1 < drop_sub_blog_tables.sql
  ```
  
5. remove tables associated with plugins:

  ```
  mysql --user=root --password tmp_vivelohoy_1 < drop_plugin_tables.sql
  ```
  
6. remove rows in wp_blogs table associated with other blogs
7. Dump local database to file

  ```
  mysqldump --user=root --password tmp_vivelohoy_1 > vivelohoy.sql
  ```
  
8. Load database dump to vagrant WordPress installation with:

  ```
  fab vagrant_reload_db:vivelohoy.sql,wordpress
  ```
  
9. Open http://vagrant.dev/wp-admin/ to initiate database version upgrade (to be compatible with WordPress 3.9.1 instead of 3.2)
10. Dump database from vagrant system to local using:

  ```
  fab vagrant_dump_db:vivelohoy-upgraded.sql,wordpress
  ```
  
11. replace “WPDEPLOYDOMAN” with “vivelohoy3.wpengine.com”

  ```
  cat vivelohoy-upgraded.sql | sed s/WPDEPLOYDOMAN/vivelohoy3.wpengine.com/g > vivelohoy-wpengine.sql 
  ```
  
12. Replace instances of the string “MyISAM” in the dump file with “InnoDB”

  ```
  cat vivelohoy-wpengine.sql | sed s/MyISAM/InnoDB/g > vivelohoy-innodb.sql
  ```

13. Drop and re-create the tmp_vivelohoy_1 schema and load this with the modified database dump

  ```
  mysql --user=root --password --execute='DROP DATABASE tmp_vivelohoy_1; CREATE DATABASE IF NOT EXISTS tmp_vivelohoy_1 CHARACTER SET utf8;'
  mysql --user=root --password tmp_vivelohoy_1 < vivelohoy-innodb.sql
  ```

14. Dump the database again but using:

  ```
  mysqldump -u root -p --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 > vivelohoy-completeinsert.sql
  ```
  
  This forces mysqldump to use a single INSERT statement for each record rather than trying to load all records in a table with a single INSERT. The latter is more efficient but WPEngine has had trouble loading that kind of dump file.

15. bzip the SQL file:

  ```
  bzip2 vivelohoy-completeinsert.sql
  ```

16. Upload the bzipped SQL file to wpengine over SFTP into the _wpeprivate folder.
17. Notify a WPEngine support staffer through Support/Live Chat that you have uploaded the file and you would like them to manually load the dump file into our database.
18. Through phpmyadmin, reset the vivelohoy admin user’s password to what is in our DEV LOGINS password file. This can be done with the SQL statement:

  ```sql
  UPDATE `wp_vivelohoy3`.`wp_users` SET `user_pass` = MD5( 'SECRET PASSWORD' ) WHERE `wp_users`.`user_login` LIKE 'vivelohoy3';
  ```
  
20. Through phpmyadmin, open the wp_posts table and change the options upload_path and upload_url_path to blank (instead of “../uploads” and “/wp-content/uploads”, respectively). This can also be done with the following SQL statements:

  ```sql
  UPDATE wp_options SET option_value = '' WHERE option_name LIKE 'upload_path';
  UPDATE wp_options SET option_value = '' WHERE option_name LIKE 'upload_url_path';
  ```

21. Reset options in wpengine wp-admin to what they should be
22. replace img src addresses from relative path /wp-content/uploads/ to full S3 address (https://s3.amazonaws.com/wpmedia.vivelohoy.com/wp-content/uploads/). This can be done in MySQL with the statement:

  ```sql
  UPDATE wp_posts
    SET post_content = REPLACE(post_content, 'src="/wp-content/uploads', 'src="https://s3.amazonaws.com/wpmedia.vivelohoy.com/wp-content/uploads');
  ```
