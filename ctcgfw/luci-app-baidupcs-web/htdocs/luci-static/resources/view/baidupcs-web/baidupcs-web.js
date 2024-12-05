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

const callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('baidupcs-web'), {}).then(function(res) {
		var isRunning = false;
		try {
			isRunning = res['baidupcs-web']['instances']['baidupcs-web']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning, port) {
	var renderHTML = "";
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';

	if (isRunning) {
		var button = String.format('&#160; <a class="btn cbi-button" href="%s:%s" target="_blank" rel="noreferrer noopener">%s</a>',
			window.location.origin, port, _('Open BaiduPCS-Web Interface'));
		renderHTML += String.format(spanTemp, 'green', _('BaiduPCS Web'),  _("RUNNING")) + button;
	} else {
		renderHTML += String.format(spanTemp, 'red', _('BaiduPCS Web'), _("NOT RUNNING"));
	}

	return renderHTML;
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('baidupcs-web')
		]);
	},

	render: function(data) {
		let m, s, o;
		var webport = (uci.get(data[0], 'config', 'port'));

		m = new form.Map('baidupcs-web', _('BaiduPCS-Web'));
		m.description = _("基于BaiduPCS-Go, 可以让你高效的使用百度云。");

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

		s = m.section(form.NamedSection, 'config', 'baidupcs-web', _('Settings'));
		s.tab('settings', _('Basic Settings'));
		s.anonymous = true;
		s.addremove = false

		o = s.taboption('settings', form.Flag, 'enabled', _('启用'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'port', _('监听端口'));
		o.datatype = 'port';
		o.placeholder = '5299';
		o.default = '5299';
		o.rmempty = false
		o.rmempty = false;

		o = s.taboption('settings', form.Value, 'download_dirt', _('下载目录'));
		o.placeholder = '/opt/baidupcsweb-download';
		o.default = '/opt/baidupcsweb-download';
		o.rmempty = false

		o = s.taboption('settings', form.Value, 'max_download_rate', _('最大下载速度'));
		o.placeholder = '0';

		o = s.taboption('settings', form.Value, 'max_upload_rate', _('最大上传速度'),
			_("0代表不限制, 单位为每秒的传输速率, 后缀'/s' 可省略, 如 2MB/s, 2MB, 2m, 2mb 均为一个意思。"));
		o.placeholder = '0';

		o = s.taboption('settings', form.Value, 'max_download_load', _('同时进行下载文件的最大数量'),
			_('不要太贪心, 当心被封号。'));
		o.placeholder = '1';

		o = s.taboption('settings', form.Value, 'max_parallel', _('最大并发连接数'));
		o.placeholder = '8';

		return m.render();
	}
});
