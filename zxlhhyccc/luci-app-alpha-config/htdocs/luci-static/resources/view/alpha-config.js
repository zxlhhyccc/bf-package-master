/* This is free software, licensed under the Apache License, Version 2.0
 *
 * Copyright (C) 2024 Hilman Maulana <hilman0.0maulana@gmail.com>
 */

'use strict';
'require view';
'require form';
'require fs';
'require ui';

return view.extend({
	render: function () {
		var m, s, o;
		m = new form.Map('alpha' , _('Alpha theme configuration'), _('Here you can set background login and dashboard themes. Chrome is recommended.'));

		s = m.section(form.TypedSection, null , _('Theme configuration'));
		s.anonymous = true;

		o = s.option(form.Value, 'color', _('Primary Color'), _('A HEX color (default: #2222359a).'))
		o.rmempty = false;
		o.validate = function(section_id, value) {
			if (section_id)
				return /^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8}|[0-9a-fA-F]{3}|[0-9a-fA-F]{4})$/i.test(value) ||
					_('Expecting: %s').format(_('valid HEX color value'));
			return true;
		}

		o = s.option(form.ListValue, 'blur', _('Transparency level'), _('Transparent level for menu'));
		o.value('0', _('0'));
		o.value('10', _('1'));
		o.value('20', _('2'));
		o.value('30', _('3'));
		o.value('40', _('4'));
		o.value('50', _('5'));
		o.rmempty = false;

		s = m.section(form.TypedSection, null , _('Navigation bar configuration'));
		s.anonymous = true;

		o = s.option(form.ListValue, 'nav_01', _('Navigation line 01'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'nav_02', _('Navigation line 02'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'nav_03', _('Navigation line 03'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'nav_04', _('Navigation line 04'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'nav_05', _('Navigation line 05'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'nav_06', _('Navigation line 06'));
		o.value('/cgi-bin/luci/admin/modem/main', _('Modem'));
		o.value('/cgi-bin/luci/admin/services/neko', _('Neko'));
		o.value('/cgi-bin/luci/admin/network/network', _('Network'));
		o.value('/cgi-bin/luci/admin/services/openclash', _('Open Clash'));
		o.value('/cgi-bin/luci/admin/status/overview', _('Overview'));
		o.value('/cgi-bin/luci/admin/services/ttyd', _('Terminal'));
		o.value('/cgi-bin/luci/admin/nas/tinyfm', _('Tiny File Manager'));
		o.value('none', _('None'));
		o.rmempty = false;

		var bg_path = '/www/luci-static/alpha/background/';
		s = m.section(form.TypedSection, null , _('Background configuration'), _('You can upload files such as jpg or png files, and files will be uploaded to <code>%s</code>.').format(bg_path));
		s.anonymous = true;

		o = s.option(form.Button, 'login', _('Login'), _('Upload file for login background'));
		o.inputstyle = 'action';
		o.inputtitle = _('Upload');
		o.onclick = function(ev, section_id) {
			var file = bg_path + 'login.png';
			return ui.uploadFile(file, ev.target).then(function(res) {
				return fs.exec('/bin/chmod', ['0644', file]).then(function() {
					ui.addNotification(null, E('p', _('Login picture successfully uploaded.')));
				});
			})
			.catch(function(e) { ui.addNotification(null, E('p', e.message)); });
		};
		o.modalonly = true;

		o = s.option(form.Button, 'dashboard', _('Dashboard'), _('Upload file for dashboard background'));
		o.inputstyle = 'action';
		o.inputtitle = _('Upload');
		o.onclick = function(ev, section_id) {
			var file = bg_path + 'dashboard.png';
			return ui.uploadFile(file, ev.target).then(function(res) {
				return fs.exec('/bin/chmod', ['0644', file]).then(function() {
					ui.addNotification(null, E('p', _('Dashboard picture successfully uploaded.')));
				});
			})
			.catch(function(e) { ui.addNotification(null, E('p', e.message)); });
		};
		o.modalonly = true;

		return m.render();
	},
});
