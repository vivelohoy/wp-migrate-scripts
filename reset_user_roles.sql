# Update the main admin user details
UPDATE wp_users
    SET user_login = 'vivelohoy3',
        user_pass = MD5(FILL_THIS_IN),          # TODO
        user_nicename = 'vivelohoy3',
        user_email = 'support@vivelohoy.com',
        display_name = 'vivelohoy3'
    WHERE ID = 1;

# Demote all users to Subscriber role
UPDATE wp_usermeta
    SET meta_value = 'a:1:{s:10:"subscriber";s:1:"1";}'
    WHERE meta_key LIKE 'wp_capabilities';

# Elevate main admin user to Administrator role
UPDATE wp_usermeta
    SET meta_value = 'a:1:{s:13:"administrator";s:1:"1";}'
    WHERE meta_key LIKE 'wp_capabilities'
        AND user_id = 1;

# Elevate Hoy writers and editors to Editor role
# Hoy staff identified in this Github issue comment:
# https://github.com/vivelohoy/vivelohoy-3.0/issues/54#issuecomment-48637092
UPDATE wp_usermeta
    SET wp_usermeta.meta_value = 'a:1:{s:6:"editor";s:1:"1";}'
    WHERE wp_usermeta.meta_key LIKE 'wp_capabilities'
        AND wp_usermeta.user_id IN (SELECT ID
                                    FROM wp_users
                                    WHERE display_name IN ('Jose Luis Sanchez Pando',
                                        'Gisela Orozco',
                                        'Leticia Espinosa',
                                        'Octavio López',
                                        'Jaime Reyes',
                                        'Roger Tino Morales',
                                        'Fernando Díaz',
                                        'samueljvega',
                                        'Rodolfo Jimenez',
                                        'Lorena Gonzalez',
                                        'Jacqueline Marrero'));