'use strict';
'require form';
'require fs';
'require poll';
'require rpc';
'require uci';
'require view';

const callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('vlmcsd'), {}).then(function (res) {
		console.log(res);
		var isRunning = false;
		try {
			isRunning = res['vlmcsd']['instances']['vlmcsd']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function getVersion() {
    return fs.exec("/usr/bin/vlmcsd", ["-V"])
        .then(function (result) {
            if (result.code === 0) {
                return result.stdout.trim().split(/\s+/)[1]; // 提取版本号
            }
            return _("Unknown");
        });
}

function renderStatus(isRunning) {
	var renderHTML = "";
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';

	if (isRunning) {
		renderHTML += String.format(spanTemp, 'green', _("KMS Server"), _("RUNNING"));
	} else {
		renderHTML += String.format(spanTemp, 'red', _("KMS Server"), _("NOT RUNNING"));
	}

	return renderHTML;
}

return view.extend({
    load: function() {
        return Promise.all([
            uci.load('vlmcsd'),
        ]);
    },

	render: function () {
		let m, s, o;

		m = new form.Map('vlmcsd', _('KMS Server Settings'));
		L.resolveDefault(getVersion()).then(function(version) {
			m.description = _("SA KMS Server Emulator to activate your Windows or Office<br/>Current Version")
				+ ": <b><font style=\"color:green\">" + version + "</font></b>";
		});

		s = m.section(form.NamedSection, '_status');
		s.anonymous = true;
		s.render = function (section_id) {
			L.Poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function(res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res);
				});
			});

			return E('div', { class: 'cbi-section', id: 'status_bar' }, [
					E('p', { id: 'service_status' }, _('Collecting data...'))
			]);
		}

		s = m.section(form.NamedSection, 'config', 'vlmcsd');
		s.anonymous = true;
		
		s.tab('base', _('Base Setting'));
		s.tab('config_file', _('Configuration File'), _('Edit the content of the /etc/vlmcsd.ini file.'));
		s.tab('logview', _('Log'));

		o = s.taboption('base', form.Flag, 'enabled', _('Enable'));
		o.rmempty = false;
		o.default = o.disabled;

		o = s.taboption('base', form.Flag, 'auto_activate', _('Allow automatic activation'));
		o.rmempty = false;

		o = s.taboption('base', form.Flag, 'internet_access', _('Allow connection from Internet'));
		o.rmempty = false;

		o = s.taboption('base', form.Flag, 'conf', _('Use Config File'));
		o.rmempty = false;

		o = s.taboption('base', form.ListValue, 'log', _('Empty Log File'));
		o.default = 7;
		const days = {7: "disable",0: "Sun",1: "Mon",2: "Tue",3: "Wed",4: "Thu",5: "Fri",6: "Sat"};
		for (const [i, v] of Object.entries(days)) {
			if (v !== "disable") {
				o.value(i, _("Every") + _(v));
			} else {
				o.value(i, _(v));
			}
		}

		o = s.taboption('base', form.Value, 'port', _('Local Port'));
		o.datatype = 'port';
		o.placeholder = '1688';

		o = s.taboption('config_file', form.TextValue, '_tmpl',
			null,
			_("This is the content of the file '/etc/vlmcsd.ini', you can edit it here, usually no modification is needed."));
		o.rows = 20;
		o.monospace = true;
		o.load = () => fs.trimmed('/etc/vlmcsd.ini');
		o.write = (_, value) => fs.write('/etc/vlmcsd.ini', value.trim().replace(/\r\n/g, '\n') + '\n');

		// **日志部分，改为加载 `log.js`**
		o = s.taboption('logview', form.TextValue, '_logview');
		o.monospace = true;
		o.render = function() {
			return L.require("view.log").then(log => log.render());
		};

		return m.render();
	}
});