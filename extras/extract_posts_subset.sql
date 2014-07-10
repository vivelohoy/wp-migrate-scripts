# Create tables that contain data related to just posts after a certain date
#
# Prerequisites:
#
# 1. Create database.
#
#    $ mysql --user=root --password
#    SQL> CREATE DATABASE IF NOT EXIST tmp_vivelohoy_1 CHARACTER SET utf8;
#
# 2. Load original data into this database:
#
#    $ mysql --user=root --password tmp_vivelohoy_1 < vivelohoy_wp_tables.sql
#
# 3. In this file, change the date in the first CREATE TABLE query for wp_posts to the
#    cutoff date that you want.
#
# 4. Run this file to create a second temporary database, tmp_vivelohoy_2,
#    and create the new tables there. NOTE: this will delete the tmp_vivelohoy_2
#    database first:
#
#    $ mysql --user=root --password < extract_posts_subset.sql
#
# 5. Export the resulting tables with:
#
#    $ mysqldump --user=root --password tmp_vivelohoy_2 > vivelohoy_posts_subset.sql
#
DROP DATABASE IF EXISTS tmp_vivelohoy_2;

CREATE DATABASE tmp_vivelohoy_2 CHARACTER SET utf8;

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_posts;
CREATE TABLE tmp_vivelohoy_2.wp_posts AS
  (SELECT wp_posts.*
    FROM tmp_vivelohoy_1.wp_posts
    WHERE wp_posts.post_date >= '2014-05-01');

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_postmeta;
CREATE TABLE tmp_vivelohoy_2.wp_postmeta AS
  (SELECT wp_postmeta.*
    FROM tmp_vivelohoy_1.wp_postmeta INNER JOIN
      tmp_vivelohoy_2.wp_posts
    ON wp_posts.ID = wp_postmeta.post_ID);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_comments;
CREATE TABLE tmp_vivelohoy_2.wp_comments AS
  (SELECT wp_comments.*
    FROM tmp_vivelohoy_2.wp_posts INNER JOIN
       tmp_vivelohoy_1.wp_comments
    ON wp_comments.comment_post_ID = wp_posts.ID);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_commentmeta;
CREATE TABLE tmp_vivelohoy_2.wp_commentmeta AS 
  (SELECT wp_commentmeta.* 
    FROM tmp_vivelohoy_2.wp_comments INNER JOIN 
       tmp_vivelohoy_1.wp_commentmeta
   ON wp_comments.comment_ID = wp_commentmeta.comment_id);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_term_relationships;
CREATE TABLE tmp_vivelohoy_2.wp_term_relationships AS
  (SELECT DISTINCT wp_term_relationships.*
    FROM tmp_vivelohoy_2.wp_posts INNER JOIN
      tmp_vivelohoy_1.wp_term_relationships
    ON wp_term_relationships.object_id = wp_posts.ID
    ORDER BY wp_term_relationships.object_id,
      wp_term_relationships.term_taxonomy_id);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_term_taxonomy;
CREATE TABLE tmp_vivelohoy_2.wp_term_taxonomy AS
  (SELECT DISTINCT wp_term_taxonomy.*
    FROM tmp_vivelohoy_2.wp_term_relationships INNER JOIN
      tmp_vivelohoy_1.wp_term_taxonomy
    ON wp_term_taxonomy.term_taxonomy_id = wp_term_relationships.term_taxonomy_id
    ORDER BY wp_term_taxonomy.term_taxonomy_id);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_terms;
CREATE TABLE tmp_vivelohoy_2.wp_terms AS
  (SELECT DISTINCT wp_terms.*
    FROM tmp_vivelohoy_2.wp_term_taxonomy INNER JOIN
      tmp_vivelohoy_1.wp_terms
    ON wp_terms.term_id = wp_term_taxonomy.term_id
    ORDER BY wp_terms.term_id);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_users;
CREATE TABLE tmp_vivelohoy_2.wp_users AS
  (SELECT wp_users.*
    FROM tmp_vivelohoy_2.wp_posts INNER JOIN
      tmp_vivelohoy_1.wp_users
    ON wp_users.ID = wp_posts.post_author);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_usermeta;
CREATE TABLE tmp_vivelohoy_2.wp_usermeta AS
  (SELECT wp_usermeta.*
    FROM tmp_vivelohoy_2.wp_users INNER JOIN
      tmp_vivelohoy_1.wp_usermeta
    ON wp_users.ID = wp_usermeta.user_id);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_links;
CREATE TABLE tmp_vivelohoy_2.wp_links AS
  (SELECT wp_links.* 
    FROM tmp_vivelohoy_1.wp_links);

DROP TABLE IF EXISTS tmp_vivelohoy_2.wp_options;
CREATE TABLE tmp_vivelohoy_2.wp_options AS
  (SELECT wp_options.*
    FROM tmp_vivelohoy_1.wp_options);
