-- wp_terms
-----------
-- SELECT term_id FROM wp_terms WHERE slug = 'fotogalerias';

-- wp_term_taxonomy
-------------------
-- SELECT term_taxonomy_id FROM wp_term_taxonomy WHERE term_id = (SELECT term_id FROM wp_terms WHERE slug = 'fotogalerias');

-- wp_term_relationships
------------------------
-- SELECT object_id FROM wp_term_relationships
--     WHERE term_taxonomy_id = (SELECT term_taxonomy_id FROM wp_term_taxonomy
--                                 WHERE term_id = (SELECT term_id FROM wp_terms
--                                                     WHERE slug = 'fotogalerias'));

-- wp_posts
-----------
UPDATE wp_posts
    JOIN (SELECT ID FROM wp_posts
            WHERE post_status = 'publish' AND
                post_content NOT LIKE '%[gallery%' AND
                ID IN (SELECT object_id FROM wp_term_relationships
                        WHERE term_taxonomy_id = (SELECT term_taxonomy_id FROM wp_term_taxonomy
                                                    WHERE term_id = (SELECT term_id FROM wp_terms
                                                                        WHERE slug = 'fotogalerias')))) AS gallery_posts
    ON wp_posts.ID = gallery_posts.ID
    SET wp_posts.post_content = CONCAT(wp_posts.post_content, "\n\n[gallery]\n");
