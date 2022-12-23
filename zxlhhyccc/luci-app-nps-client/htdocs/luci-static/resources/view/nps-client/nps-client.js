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

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('nps-client'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['nps-client']['instances']['instance1']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var renderHTML = "";
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';

	if (isRunning) {
		renderHTML += String.format(spanTemp, 'green', _('Nps Client'),  _("RUNNING"));
	} else {
		renderHTML += String.format(spanTemp, 'red', _('Nps Client'), _("NOT RUNNING"));
	}

	return renderHTML;
}

return view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('nps-client', _('Nps Client'));
		m.description = _("Nps is a fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet.");

		s = m.section(form.NamedSection, '_status');
		s.anonymous = true;
		s.render = function () {
			Poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function(res) {
					var view = document.getElementById("service_status");
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

		s = m.section(form.TypedSection, 'nps-client', _('Settings'));
		s.tab('settings', _('Basic Settings'));
		s.anonymous = true;

		o = s.taboption('settings', form.Flag, 'enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'server_addr', _('Server'));
		o.datatype = 'host';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'server_port', _('Port'));
		o.datatype = 'port';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('settings', form.ListValue, 'protocol', _('Protocol Type'));
		o.default = 'tcp';
		o.value('tcp', _('TCP Protocol'));
		o.value('kcp', _('KCP Protocol'));

		o = s.taboption('settings', form.ListValue, 'auto_reconnection', _('Auto Reconnection'),
			_('Auto reconnect to the server when the connection is down.'));
		o.default = 'true';
		o.value('true', _('True'));
		o.value('false', _('False'));

		o = s.taboption('settings', form.Value, 'vkey', _('vkey'));
		o.optional = false;
		o.password = true;
		o.rmempty = false;

		o = s.taboption('settings', form.Flag, 'compress', _('Enable Compression'), _('The contents will be compressed to speed up the traffic forwarding speed, but this will consume some additional cpu resources.'));
		o.default = '1';
		o.rmempty = false;

		o = s.taboption('settings', form.Flag, 'crypt', _('Enable Encryption'), _('Encrypted the communication between Npc and Nps, will effectively prevent the traffic intercepted.'));
		o.default = '1';
		o.rmempty = false;

		o = s.taboption('settings', form.ListValue, 'log_level', _('Log Level'));
		o.value('0', _('Emergency'));
		o.value('1', _('Alert'));
		o.value('2', _('Critical'));
		o.value('3', _('Error'));
		o.value('4', _('Warning'));
		o.value('5', _('Notice'));
		o.value('6', _('Info'));
		o.value('7', _('Debug'));
		o.default = '3';

		return m.render();
	}
});
