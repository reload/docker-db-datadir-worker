-- If the stage_file_proxy module is not known yet we add it to the
-- system table. Setting the bootstrap field to one will trigger the
-- module to be correctly enabled for some reason.
INSERT IGNORE INTO `system` VALUES ('profiles/supershop/modules/contrib/stage_file_proxy/stage_file_proxy.module', 'stage_file_proxy', 'module', '', 1, 1, -1, 0, 'a:13:{s:4:"name";s:16:"Stage File Proxy";s:11:"description";s:80:"Proxies files from production server so you don''t have to transfer them manually";s:4:"core";s:3:"7.x";s:9:"configure";s:36:"admin/config/system/stage_file_proxy";s:7:"version";s:7:"7.x-1.7";s:7:"project";s:16:"stage_file_proxy";s:9:"datestamp";s:10:"1428604383";s:5:"mtime";i:1428604383;s:12:"dependencies";a:0:{}s:7:"package";s:5:"Other";s:3:"php";s:5:"5.2.4";s:5:"files";a:0:{}s:9:"bootstrap";i:0;}');
-- Generally make sure stage_file_proxy is enabled.
UPDATE `system` SET `status` = 1 WHERE `name` = 'stage_file_proxy';
-- Set admin password to admin.
UPDATE `users` SET `pass` = '$S$DnyhybQ1LS.tk1SaVb2M67Fo8Hba/2eSYAmXNlTOwMN0I.ionzAq' WHERE `uid` = 1;
