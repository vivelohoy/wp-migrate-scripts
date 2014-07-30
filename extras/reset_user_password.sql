-- Use the exact username as it appears in the user's WordPress profile
UPDATE wp_users
    SET user_pass = MD5(NEW PASSWORD HERE IN SINGLE QUOTES),
    WHERE user_name = USERNAME IN SINGLE QUOTES;
-- For example:
-- UPDATE wp_users
--     SET user_pass = MD5('deportEs!2014'),
--     WHERE user_name = 'Jose Luis Sanchez Pando';