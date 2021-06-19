<?php
if(!function_exists('fnmatch')) {

    function fnmatch($pattern, $string) {
        return preg_match("#^".strtr(preg_quote($pattern, '#'), array('\*' => '.*', '\?' => '.'))."$#i", $string);
    } // end

} // end if

$config['app']['ui']['custom_js_url'] = '/customizables/custom.js';
$config['app']['ui']['enable_favicon_ico'] = true;
$config['app']['ui']['ReadMeFileName'] = "README";
