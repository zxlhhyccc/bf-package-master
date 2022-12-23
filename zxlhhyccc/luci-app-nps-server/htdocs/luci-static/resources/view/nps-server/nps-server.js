/* SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2022 ImmortalWrt.org
 */

'use strict';
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
	return L.resolveDefault(callServiceList('nps-server'), {}).then(function(res) {
		var isRunning = false;
		try {
			isRunning = res['nps-server']['instances']['instance1']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning, port) {
	var renderHTML = "";
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';

	if (isRunning) {
		var button = String.format('&#160; <a class="btn cbi-button" href="%s:%s" target="_blank" rel="noreferrer noopener">%s</a>',
			window.location.origin, port, _('Open Web Interface'));
		renderHTML += String.format(spanTemp, 'green', _('Nps Server Setting'),  _("RUNNING")) + button;
	} else {
		renderHTML += String.format(spanTemp, 'red', _('Nps Server Setting'), _("NOT RUNNING"));
	}

	return renderHTML;
}

return view.extend({
		load: function() {
		return Promise.all([
			uci.load('nps-server')
		]);
	},

	render: function(data) {
		var m, s, o;
		var webport = (uci.get(data[0], 'config', 'web_port'));

		m = new form.Map('nps-server', _('Nps Server Setting'));
		m.description = _("Nps is a fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet.");

		s = m.section(form.NamedSection, '_status');
		s.anonymous = true;
		s.render = function () {
			Poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function(res) {
					var view = document.getElementById("service_status");
					view.innerHTML = renderStatus(res, webport);
				});
			});

			return E('div', { class: 'cbi-map' },
				E('fieldset', { class: 'cbi-section'}, [
					E('p', { id: 'service_status' },
						_('Collecting data ...'))
				])
			);
		}

		s = m.section(form.NamedSection, 'config', 'nps-server', _('Settings'));
		s.anonymous = true;

		s.tab('setting', _('Basic Setting'));
		s.tab('web', _('Web Setting'));
		s.tab('proxy', _('NpsProxy'));
		s.tab('bridge', _('Bridge'));
		s.tab('key', _('Auth Key'));

		o = s.taboption('setting', form.Flag, 'enabled', _('Enabled'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.taboption('setting', form.ListValue, 'log_level', _('Log Level'));
		o.value('0', _('Emergency'));
		o.value('1', _('Alert'));
		o.value('2', _('Critical'));
		o.value('3', _('Error'));
		o.value('4', _('Warning'));
		o.value('5', _('Notice'));
		o.value('6', _('Info'));
		o.value('7', _('Debug'));
		o.default = '3';

		o = s.taboption('setting', form.Value, 'log_path', _('Log Path'));
		o.datatype = 'string';
		o.default = 'nps-server.log';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('setting', form.ListValue, 'runmode', _('Boot mode'));
		o.default = 'dev';
		o.value('dev', _('Dev'));
		o.value('pro', _('Pro'));

		o = s.taboption('setting', form.ListValue, 'ip_limit', _('ip_limit'), _('ip limit switch'));
		o.default = 'true';
		o.value('true', _('True'));
		o.value('false', _('False'));

		o = s.taboption('web', form.Value, 'web_host', _('Server'), _('Server Domain/IP'));
		o.default = 'x.y.com';
		o.datatype = 'host';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('web', form.Value, 'web_ip', _('Web access address'));
		o.default = '0.0.0.0';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('web', form.Value, 'web_username', _('Web Username'));
		o.datatype = 'string';
		o.default = 'admin';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('web', form.Value, 'web_password', _('Web Password'));
		o.datatype = 'string';
		o.default = '123';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('web', form.Value, 'web_port', _('Web Port'));
		o.datatype = 'port';
		o.default = '8080';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('proxy', form.Value, 'http_proxy_ip', _('http_proxy_ip'));
		o.datatype = 'ipaddr';
		o.default = '0.0.0.0';
		o.optional = true;
		o.rmempty = true;

		o = s.taboption('proxy', form.Value, 'http_proxy_port', _('http_proxy_port'));
		o.datatype = 'port';
		o.default = '62080';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('proxy', form.Value, 'https_proxy_port', _('https_proxy_port'));
		o.datatype = 'port';
		o.default = '62443';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('bridge', form.Value, 'bridge_ip', _('bridge_ip'));
		o.datatype = 'ipaddr';
		o.default = '0.0.0.0';
		o.optional = true;
		o.rmempty = true;

		o = s.taboption('bridge', form.Value, 'bridge_port', _('bridge_port'));
		o.datatype = 'port';
		o.default = '8024';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('key', form.Value, 'public_vkey', _('public_vkey'), _('Public password, which clients can use to connect to the server'));
		o.datatype = 'string';
		o.default = '123';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('key', form.Value, 'auth_key', _('auth_key'), _('Web API unauthenticated IP address(the len of auth_crypt_key must be 16)'));
		o.datatype = 'string';
		o.default = 'test';
		o.optional = false;
		o.rmempty = false;

		o = s.taboption('key', form.Value, 'auth_crypt_key', _('auth_crypt_key'), _('Web API unauthenticated IP address(the len of auth_crypt_key must be 16)'));
		o.datatype = 'string';
		o.default = '1234567812345678';
		o.optional = false;
		o.rmempty = false;

		return m.render();
	}
});
