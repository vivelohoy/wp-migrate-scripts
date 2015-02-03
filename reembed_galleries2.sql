UPDATE wp_posts
    JOIN (SELECT ID FROM wp_posts
            WHERE post_status = 'publish' AND
                post_content NOT LIKE '%[gallery%' AND
                post_content NOT LIKE '%[caption%' AND
                post_content NOT LIKE '%<img%' AND
                ID IN (SELECT object_id FROM wp_term_relationships
                        WHERE term_taxonomy_id = (SELECT term_taxonomy_id FROM wp_term_taxonomy
                                                    WHERE term_id = (SELECT term_id FROM wp_terms
                                                                        WHERE slug = 'post-format-gallery')))) AS gallery_posts
    ON wp_posts.ID = gallery_posts.ID
    SET wp_posts.post_content = CONCAT("[gallery]\n\n", wp_posts.post_content);