-- If the stage_file_proxy module is not known yet we add it to the
-- system table.
INSERT IGNORE INTO `system` VALUES ('sites/all/modules/contrib/stage_file_proxy/stage_file_proxy.module', 'stage_file_proxy', 'module', '', 1, 1, -1, 0, 'a:13:{s:4:"name";s:16:"Stage File Proxy";s:11:"description";s:80:"Proxies files from production server so you don''t have to transfer them manually";s:4:"core";s:3:"7.x";s:9:"configure";s:36:"admin/config/system/stage_file_proxy";s:7:"version";s:7:"7.x-1.7";s:7:"project";s:16:"stage_file_proxy";s:9:"datestamp";s:10:"1428604383";s:5:"mtime";i:1428604383;s:12:"dependencies";a:0:{}s:7:"package";s:5:"Other";s:3:"php";s:5:"5.2.4";s:5:"files";a:0:{}s:9:"bootstrap";i:0;}');

-- Generally make sure stage_file_proxy is enabled.
UPDATE `system` SET `status` = 1 WHERE `name` = 'stage_file_proxy';

-- Set admin password to admin.
UPDATE `users` SET `pass` = '$S$DnyhybQ1LS.tk1SaVb2M67Fo8Hba/2eSYAmXNlTOwMN0I.ionzAq' WHERE `uid` = 1;

-- Set DIBS to run in test mode.
UPDATE `variable` SET `value` = 'a:6:{s:7:"general";a:11:{s:8:"merchant";s:7:"4253387";s:7:"account";s:0:"";s:9:"test_mode";s:1:"1";s:4:"type";s:4:"flex";s:14:"retry_handling";s:12:"new_order_id";s:3:"md5";s:1:"1";s:8:"md5_key1";s:32:"~b*{Ls^ur}^+:w!XXh7VM8XT;viHR{.D";s:8:"md5_key2";s:32:"@ExQo7m;V!_U^M8^orduEhpn$]]%1UzC";s:8:"hmac_key";s:128:"5a3f52624d7c464b765e5b442b7a28786e7231463524264945474d2566537a6b45546a403a5774656d635e3823776d374a317b32583028684b596630517b4c78";s:4:"lang";s:2:"da";s:8:"currency";s:3:"208";}s:13:"paymentwindow";a:1:{s:5:"color";s:4:"sand";}s:10:"flexwindow";a:3:{s:5:"color";s:4:"blue";s:9:"decorator";s:10:"responsive";s:7:"voucher";s:1:"0";}s:12:"mobilewindow";a:1:{s:8:"paytypes";a:6:{s:2:"MC";s:2:"MC";s:4:"VISA";s:4:"VISA";s:4:"ELEC";s:4:"ELEC";s:4:"AMEX";s:4:"AMEX";s:2:"DK";s:2:"DK";s:4:"V-DK";s:4:"V-DK";}}s:8:"advanced";a:3:{s:7:"calcfee";s:1:"0";s:10:"capturenow";s:1:"1";s:15:"unqiue_order_id";s:1:"1";}s:9:"callbacks";a:3:{s:9:"accepturl";s:19:"payment/dibs/accept";s:9:"cancelurl";s:19:"payment/dibs/cancel";s:10:"callbackok";s:23:"payment/dibs/callbackok";}}' WHERE `name` = 'dibs_settings_landing_page_donation_landing_page_donation';
UPDATE `variable` SET `value` = 'a:6:{s:7:"general";a:11:{s:8:"merchant";s:7:"4253387";s:7:"account";s:0:"";s:9:"test_mode";s:1:"1";s:4:"type";s:4:"flex";s:14:"retry_handling";s:12:"new_order_id";s:3:"md5";s:1:"1";s:8:"md5_key1";s:32:"~b*{Ls^ur}^+:w!XXh7VM8XT;viHR{.D";s:8:"md5_key2";s:32:"@ExQo7m;V!_U^M8^orduEhpn$]]%1UzC";s:8:"hmac_key";s:128:"5a3f52624d7c464b765e5b442b7a28786e7231463524264945474d2566537a6b45546a403a5774656d635e3823776d374a317b32583028684b596630517b4c78";s:4:"lang";s:2:"da";s:8:"currency";s:3:"208";}s:13:"paymentwindow";a:1:{s:5:"color";s:4:"sand";}s:10:"flexwindow";a:3:{s:5:"color";s:4:"sand";s:9:"decorator";s:6:"custom";s:7:"voucher";s:1:"0";}s:12:"mobilewindow";a:1:{s:8:"paytypes";a:6:{s:2:"MC";s:2:"MC";s:4:"VISA";s:4:"VISA";s:4:"ELEC";s:4:"ELEC";s:4:"AMEX";s:4:"AMEX";s:2:"DK";s:2:"DK";s:4:"V-DK";s:4:"V-DK";}}s:8:"advanced";a:3:{s:7:"calcfee";s:1:"0";s:10:"capturenow";s:1:"1";s:15:"unqiue_order_id";s:1:"1";}s:9:"callbacks";a:3:{s:9:"accepturl";s:19:"payment/dibs/accept";s:9:"cancelurl";s:19:"payment/dibs/cancel";s:10:"callbackok";s:23:"payment/dibs/callbackok";}}' WHERE `name` = 'dibs_settings_msf_donation_msf_donation';

-- Disable secure pages to be able to login without HTTPS.
UPDATE `variable` SET `value` ='i:0;' WHERE `name` = 'securepages_enable';

-- Clear cache bootstrap to get (among others) variable cache cleared.
DELETE FROM `cache_bootstrap`;
