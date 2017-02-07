-- Reset the admin-users password:
-- Set the reload users password to reload.
UPDATE `users` SET `pass` = '$S$DhJhihnTzLM3UvzF4klWpYorIt7IJ1vzO9M0Fic1WL7MzNV19Xec' WHERE `uid` = 1 AND `name` = 'reload';
UPDATE `variable` SET `value` = 's:4:"/tmp";' WHERE `name` = 'file_temporary_path';

