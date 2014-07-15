/*

Extract video embed code from wp_postmeta table and concatenate it with the relevant
post's content to re-embed it in the post.

*/
UPDATE wp_posts 
    JOIN (SELECT post_id, meta_value 
            FROM wp_postmeta 
            WHERE meta_key = "_video_embed_code") AS embed_codes
    ON wp_posts.ID = embed_codes.post_id
    SET wp_posts.post_content = CONCAT(embed_codes.meta_value, "\n\n", wp_posts.post_content);