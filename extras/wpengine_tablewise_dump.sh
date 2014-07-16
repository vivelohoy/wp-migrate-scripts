#!/bin/zsh
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_blog_versions > wp_blog_versions.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_blogs > wp_blogs.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_commentmeta > wp_commentmeta.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_comments > wp_comments.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_links > wp_links.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_options > wp_options.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_postmeta > wp_postmeta.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_posts > wp_posts.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_registration_log > wp_registration_log.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_signups > wp_signups.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_site > wp_site.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_sitemeta > wp_sitemeta.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_term_relationships > wp_term_relationships.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_term_taxonomy > wp_term_taxonomy.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_terms > wp_terms.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_usermeta > wp_usermeta.sql
mysqldump --user=root --password="" --extended-insert=FALSE --complete-insert=TRUE tmp_vivelohoy_1 wp_users > wp_users.sql