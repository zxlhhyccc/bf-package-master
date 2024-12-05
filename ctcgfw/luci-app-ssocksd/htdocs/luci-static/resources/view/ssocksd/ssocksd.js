/* SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2022 ImmortalWrt.org
 */

'use strict';
'require fs';
'require form';
'require view';
'require poll';
'require rpc';
'require ui';
'require uci';

const callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('ssocksd'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['ssocksd']['instances']['ssocksd']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var renderHTML = "";
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';

	if (isRunning) {
		renderHTML += String.format(spanTemp, 'green', _('sSocksd Server'),  _("RUNNING"));
	} else {
		renderHTML += String.format(spanTemp, 'red', _('sSocksd Server'), _("NOT RUNNING"));
	}

	return renderHTML;
}

return view.extend({
	render: function() {
		let m, s, o;

		m = new form.Map('ssocksd', _('sSocksd Server'));
		m.description = _("sSocksd Server is a simple, small, and easy-to-use Socks5 server program, but supports TCP on IPv4 only.");

		s = m.section(form.NamedSection, '_status');
		s.anonymous = true;
		s.render = function () {
			Poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function(res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res);
				});
			});

			return E('div', { class: 'cbi-map' },
				E('fieldset', { class: 'cbi-section'}, [
					E('p', { id: 'service_status' },
						_('Collecting data ...'))
				])
			);
		}

		s = m.section(form.TypedSection, 'ssocksd', _('Settings'));
		s.tab('settings', _('Basic Settings'));
		s.anonymous = true;
		s.addremove = false

		o = s.taboption('settings', form.Flag, 'enable', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.taboption('settings', form.ListValue, 'bind_addr', _('Bind Address'),
			_('The address that sSocksd Server binded.'));
		o.default = 'wan';
		o.value('lan', _('LAN'));
		o.value('wan', _('WAN'));
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'listen_port', _('Listen Port'),
			_("The port that sSocksd Server listened at, don't reuse the port with other program."));
		o.placeholder = '10080';
		o.default = '10080';
		o.datatype = 'port';
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'username', _('Username'),
			_('The authorization username, leave blank to deauthorize.'));
		o.placeholder = 'Username';
		o.default = 'ctcgfw';
		o.datatype = 'string';

		o = s.taboption('settings', form.Value, 'password', _('Password'),
			_('The authorization password, leave blank to deauthorize.'));
		o.placeholder = 'Password';
		o.default = 'password';
		o.datatype = 'string';
		o.password = true;

		return m.render();
	}
});
