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
  mysqldump --user=vivelohoy --host=vivelohoy-db.c0petvek1fz0.us-east-1.rds.amazonaws.com --password --quick --skip-lock-tables vivelohoy | bzip2 > /mnt/apps/sites/vivelohoy/data/data.sql.bz2
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

6. re-embed videos into video posts:

  ```
  mysql --user=root --password tmp_vivelohoy_1 < reembed_videos.sql
  ```

7. re-embed gallery shortcodes into gallery posts that don't have the shortcode:

  ```
  mysql --user=root --password tmp_vivelohoy_1 < reembed_galleries.sql
  ```

7. remove rows in wp_blogs table associated with other blogs:

  ```
  mysql --user=root --password tmp_vivelohoy_1 --execute="DELETE FROM wp_blogs WHERE blog_id <> 1;"
  ```

8. Dump local database to file:

  ```
  mysqldump --user=root --password tmp_vivelohoy_1 > vivelohoy.sql
  ```
  
8. Prepare the database dump for use in the vagrant instance by replacing instances of the domain `www.vivelohoy.com` with `vagrant.dev`:

  ```
  cat vivelohoy.sql | sed s/www.vivelohoy.com/vagrant.dev/g > vivelohoy-vagrant.sql
  ```
  
9. Load database dump to vagrant WordPress installation with:

  ```
  fab vagrant_reload_db:vivelohoy-vagrant.sql,wordpress
  ```
  
10. Open http://vagrant.dev/wp-admin/ to initiate database version upgrade (to be compatible with the latest version of WordPress instead of 3.2)
11. Dump database from vagrant system to local using:

  ```
  fab vagrant_dump_db:vivelohoy-upgraded.sql,wordpress
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
17. Notify Tony Gilharry that we need the database reloaded using the uploaded SQL file.
18. Through phpmyadmin, reset the vivelohoy admin user’s password to what is in our DEV LOGINS password file. This can be done with the SQL statement:

  ```sql
  UPDATE `wp_vivelohoy3`.`wp_users` SET `user_pass` = MD5( 'SECRET PASSWORD' ) WHERE `wp_users`.`user_login` LIKE 'vivelohoy3';
  ```
  
19. Through phpmyadmin, open the wp_posts table and change the options upload_path and upload_url_path to blank (instead of “../uploads” and “/wp-content/uploads”, respectively). This can also be done with the following SQL statements:

  ```sql
  UPDATE wp_options SET option_value = '' WHERE option_name LIKE 'upload_path';
  UPDATE wp_options SET option_value = '' WHERE option_name LIKE 'upload_url_path';
  ```
  
