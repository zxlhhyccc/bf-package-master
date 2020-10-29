'use strict';
'require fs';
'require form';
'require rpc';
'require tools.widgets as widgets';
'require uci';

var splitter_html = '<p style="font-size:20px;font-weight:bold;color: DodgerBlue">%s</p>';
var css = '						\
	.cbi-value[data-widget="CBI.HiddenValue"] {	\
		margin-bottom: 0px !important;		\
		padding: 0px !important;		\
	}						\
';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: [ 'name' ],
	expect: { '': {} },
	filter: function (data, args, extArgs) {
		var i, res = data[args.name] || {};
		for (i = 0; (i < extArgs.length) && (Object.keys(res).length > 0); i++)
			res = res[extArgs[i]] || {};
		return res;
	}
});

var callUciGet = rpc.declare({
	object: 'uci',
	method: 'get',
	params: [ 'config', 'section', 'option' ],
	expect: { 'value': '' }
});

var callGetLanIPAddr = rpc.declare({
	object: 'network.interface.lan',
	method: 'status',
	expect: { 'ipv4-address': [] },
	filter: function (data) {
		return data[0]['address'];
	}
});

var CBIQBitStatus = form.DummyValue.extend({
	renderWidget: function() {
		var extAgrs = ['instances', 'qbittorrent.main'];
		var label = E('div', {}, E('em', {}, _('Collecting data...')));
		var btn = E('button', { 'class': 'cbi-button cbi-button-apply' });
		var node = E('div', {}, [label, btn]);
		L.Poll.add(function() {
			callServiceList('qbittorrent', extAgrs).then(function(res) {
				if (res.running) {
					L.dom.content(label, E('em', {}, _('The qBittorrent daemon is running. Click the button below to startup the WebUI.')));
					btn.textContent = 'PID: %s'.format(res.pid);
					btn.onclick = onclick_action.bind(this, 'webgui');
				} else {
					L.dom.content(label, E('em', {}, _('The qBittorrent daemon is not running. Click the button below to startup the daemon.')));
					btn.textContent = _('Start qBittorrent');
					btn.onclick = onclick_action.bind(this, 'qbt');
				}
			});
		});
		return node;
	}
});

var CBIRandomPort = form.Value.extend({
	renderWidget: function(section_id, option_index, cfgvalue) {
		var node = this.super('renderWidget', [section_id, option_index, cfgvalue]);
		node.appendChild(E('div', { 'class': 'control-group' }, [
			node.firstElementChild,
			E('button', {
				'class': 'cbi-button cbi-button-neutral',
				'click': function() {
					this.previousElementSibling.value = randomPort();
				}
			}, _('Generate Randomly'))
		]));
		return node;
	}
});

function encryptPassword (pwd) {
	var salt, key;
	sjcl.misc.hmac512 = function(key) {
		sjcl.misc.hmac.call(this, key, sjcl.hash.sha512);
	};
	sjcl.misc.hmac512.prototype = new sjcl.misc.hmac('');
	sjcl.misc.hmac512.prototype.constructor = sjcl.misc.hmac512;

	salt = sjcl.random.randomWords(4);
	key = sjcl.misc.pbkdf2(pwd, salt, 100000, 64 * 8, sjcl.misc.hmac512);

	return sjcl.codec.base64.fromBits(salt) + ':' + sjcl.codec.base64.fromBits(key);
};

function onclick_action(target) {
	if ( target == "webgui" ) {
		Promise.all([
			callGetLanIPAddr(),
			callUciGet('qbittorrent', 'main', 'Port')
		]).then(function(data) {
			var ip = data[0], port = data[1] || '8080';
			window.open('http://' + ip + ':' + port, '_blank');
		});
	}
	else {
		fs.exec('/etc/init.d/qbittorrent', ['start']);
		L.Poll.queue[0].fn();
	}
};

function randomPort() {
	return Math.floor( Math.random() * (65535 - 1024)) + 1024;
};

return L.view.extend({
	load: function() {
		return fs.exec('/usr/bin/qbittorrent-nox', ['-v'], {'HOME': '/var/run/qbittorrent'}).then(function(res) {
			fs.exec('/bin/rm', ['-rf', '/var/run/qbittorrent']);
			return res.stdout.match(/(\d\.)+\d/)[0] || '';
		});
	},

	render: function(v) {
		var m, s, o;

		m = new form.Map('qbittorrent', _('qBittorrent'), '%s %s %s.<br\><b style="color:red">%s</b>'
			.format(_('A BT/PT downloader base on Qt.'), _('Refer to the'),
			'<a href="https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-' +
			'in-qBittorrent" target="_blank">help</a>', _('Current Version: %s.').format(v)));

		s = m.section(form.TypedSection);
		s.title = _('qBittorrent Status');
		s.anonymous = true;
		s.cfgsections = function() { return [ 'status' ] };

		o = s.option(CBIQBitStatus);

		s = m.section(form.NamedSection, 'main', 'qbittorrent');

		s.tab('basic', _('Basic Settings'));
		s.tab('logger', _('Log Settings'));
		s.tab('connection', _('Connection Settings'));
		s.tab('downloads', _('Downloads Settings'));
		s.tab('bittorrent', _('Bittorrent Settings'));
		s.tab('webgui', _('WebUI Settings'));
		s.tab('advanced', _('Advance Settings'));

		o = s.taboption('basic', form.Flag, 'enabled', _('Enabled'));
		o.default = '0';

		o = s.taboption('basic', widgets.UserSelect, 'user', _('Run daemon as user'));

		o = s.taboption('basic', form.Value, 'MemoryPercent', _('Memory Limit'), _('Percentage.'))
		o.placeholder = '50'
		o.datatype = 'range(1, 99)'

		o = s.taboption('basic', form.Value, 'BinaryPath', _('Customized path'), _('Specify the binary file path for qBittorrent.'));

		o = s.taboption('basic', form.Value, 'profile', _('Parent Path for Profile Folder'),
			_('Specify the profile path and it is is equivalent to the commandline parameter: <b>--profile [PATH]</b>. The default is /tmp.'));
		o.default = '/tmp';
		o.placeholder = '/tmp';

		o = s.taboption('basic', form.Value, 'configuration', _('Profile Folder Suffix'),
			_('Suffix for profile folder, for example, <b>qBittorrent_[NAME]</b>.'));

		o = s.taboption('basic', form.Value, 'Locale', _('Locale Language'),
			_('The supported language codes can be used to customize the setting.'));
		o.value('en', _('English (en)'));
		o.value('zh', _('Chinese (zh)'));
		o.default = 'en';

		o = s.taboption('basic', form.Flag, 'overwrite', _('Overwrite the settings'),
			_('If this option is enabled, the configuration set in WebUI will be replaced by the one in the LuCI.'));
		o.default = o.disabled;

		o = s.taboption('logger', form.Flag, 'Enabled', _('Enable Log'), _('Enable logger to log file.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('logger', form.Value, 'Path', _('Log Path'), _('The path for qBittorrent log.'));
		o.depends('Enabled', 'true');

		o = s.taboption('logger', form.Flag, 'Backup', _('Enable Backup'),
			_('Backup log file when oversize the given size.'));
		o.depends('Enabled', 'true');
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('logger', form.Flag, 'DeleteOld', _('Delete Old Backup'),
			_('When enabled, the overdue log files will be deleted after given keep time.'));
		o.depends('Enabled', 'true');
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('logger', form.Value, 'MaxSizeBytes', _('Log Max Size'),
			_('The max size for qBittorrent log (Unit: Bytes).'));
		o.depends('Enabled', 'true');
		o.placeholder = '66560';

		o = s.taboption('logger', form.Value, 'SaveTime', _('Log Keep Time'), _('Give the ' +
			'time for keeping the old log, refer the setting \'Delete Old Backup\', eg. 1d' +
			' for one day, 1m for one month and 1y for one year.'));
		o.depends('Enabled', 'true');
		o.datatype = 'string';

		o = s.taboption('connection', form.Flag, 'UPnP', _('Use UPnP for Connections'), '%s %s %s.'
			.format(_('Use UPnP/ NAT-PMP port forwarding from the router.'), _('Refer to the'),
			'<a href="https://en.wikipedia.org/wiki/Port_forwarding" target="_blank">wiki</a>'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('connection', form.Flag, 'UseRandomPort', _('Use Random Port'),
			_('Assign a different port randomly every time when qBittorrent starts up,' +
			' which will voids the self-defined option.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('connection', CBIRandomPort, 'PortRangeMin', _('Connection Port'));
		o.depends('UseRandomPort', 'false');
		o.datatype = 'range(1024,65535)';
		o.default = randomPort();
		o.rmempty = false;

		o = s.taboption('connection', form.Value, 'GlobalDLLimit', _('Global Download Speed'),
			'%s %s'.format(_('Global Download Speed Limit(KiB/s).'), _('0 means has no limit.')));
		o.datatype = 'float';
		o.placeholder = '0';

		o = s.taboption('connection', form.Value, 'GlobalUPLimit', _('Global Upload Speed'),
			'%s %s'.format(_('Global Upload Speed Limit(KiB/s).'), _('0 means has no limit.')));
		o.datatype = 'float';
		o.placeholder = '0';

		o = s.taboption('connection', form.Value, 'GlobalDLLimitAlt', _('Alternative Download Speed'),
			'%s %s'.format(_('Alternative Download Speed Limit(KiB/s).'), _('0 means has no limit.')));
		o.datatype = 'float';
		o.placeholder = '10';

		o = s.taboption('connection', form.Value, 'GlobalUPLimitAlt', _('Alternative Upload Speed'),
			'%s %s'.format(_('Alternative Upload Speed Limit(KiB/s).'), _('0 means has no limit.')));
		o.datatype = 'float';
		o.placeholder = '10';

		o = s.taboption('connection', form.ListValue, 'BTProtocol', _('Protocol Enabled'),
			_('The protocol that was enabled.'));
		o.value('Both', _('TCP and UTP'));
		o.value('TCP', _('TCP'));
		o.value('UTP', _('UTP'));
		o.default = 'Both';

		o = s.taboption('connection', form.Value, 'InetAddress', _('Inet Address'),
			_('The address that respond to the trackers.'));

		o = s.taboption('downloads', form.Flag, 'CreateTorrentSubfolder', _('Create Subfolder'),
			_('Create subfolder for torrents with multiple files.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('downloads', form.Flag, 'StartInPause', _('Start In Pause'),
			_('Do not start the download automatically.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('downloads', form.Flag, 'AutoDeleteAddedTorrentFile',
			_('Auto Delete Torrent File'), _('The .torrent files will be deleted afterwards.'));
		o.enabled = 'IfAdded';
		o.disabled = 'Never';
		o.default = o.disabled;

		o = s.taboption('downloads', form.Flag, 'PreAllocation', _('Pre Allocation'),
			_('Pre-allocate disk space for all files.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('downloads', form.Flag, 'UseIncompleteExtension', _('Use Incomplete Extension'),
			_('The incomplete tasks will be added the extension of !qB.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('downloads', form.Value, 'SavePath', _('Save Path'));
		o.placeholder = '/tmp/download';

		o = s.taboption('downloads', form.Flag, 'TempPathEnabled', _('Enable Temp Path'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('downloads', form.Value, 'TempPath', _('Temp Path'),
		_('The absolute and relative path can be set.'));
		o.depends('TempPathEnabled', 'true');
		o.placeholder = 'temp/';

		o = s.taboption('downloads', form.Value, 'DiskWriteCacheSize', _('Disk Cache Size'),
			_('By default, this value 64. Besides, -1 is auto and 0 is disable. (Unit: MiB)'));
		o.datatype = 'integer';
		o.placeholder = '64';

		o = s.taboption('downloads', form.Value, 'DiskWriteCacheTTL', _('Disk Cache TTL'),
			_('By default, this value is 60. (Unit: s)'));
		o.datatype = 'integer';
		o.placeholder = '60';

		o = s.taboption('downloads', form.DummyValue, 'Saving Management', splitter_html.format(_('Saving Management')));
		o.default = '';

		o = s.taboption('downloads', form.ListValue, 'DisableAutoTMMByDefault',
			_('Default Torrent Management Mode'));
		o.value('true', _('Manual'));
		o.value('false', _('Automaic'));
		o.default = 'true';

		o = s.taboption('downloads', form.ListValue, 'CategoryChanged', _('Torrent Category Changed'),
			_('Choose the action when torrent category changed.'));
		o.value('true', _('Switch torrent to Manual Mode'));
		o.value('false', _('Relocate torrent'));
		o.default = 'false';

		o = s.taboption('downloads', form.ListValue, 'DefaultSavePathChanged',
			_('Default Save Path Changed'), _('Choose the action when default save path changed.'));
		o.value('true', _('Switch affected torrent to Manual Mode'));
		o.value('false', _('Relocate affected torrent'));
		o.default = 'true';

		o = s.taboption('downloads', form.ListValue, 'CategorySavePathChanged',
			_('Category Save Path Changed'), _('Choose the action when category save path changed.'));
		o.value('true', _('Switch affected torrent to Manual Mode'));
		o.value('false', _('Relocate affected torrent'));
		o.default = 'true';

		o = s.taboption('downloads', form.Value, 'TorrentExportDir', _('Torrent Export Dir'),
			_('The .torrent files will be copied to the target directory.'));

		o = s.taboption('downloads', form.Value, 'FinishedTorrentExportDir', _('Finished Torrent Export Dir'),
			_('The .torrent files for finished downloads will be copied to the target directory.'));

		o = s.taboption('bittorrent', form.Flag, 'DHT', _('Enable DHT'),
			_('Enable DHT (decentralized network) to find more peers.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('bittorrent', form.Flag, 'PeX', _('Enable PeX'),
			_('Enable Peer Exchange (PeX) to find more peers.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('bittorrent', form.Flag, 'LSD', _('Enable LSD'),
			_('Enable Local Peer Discovery to find more peers.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('bittorrent', form.Flag, 'uTP_rate_limited', _('μTP Rate Limit'),
			_('Apply rate limit to μTP protocol.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('bittorrent', form.ListValue, 'Encryption', _('Encryption Mode'));
		o.value('0', _('Prefer Encryption'));
		o.value('1', _('Require Encryption'));
		o.value('2', _('Disable Encryption'));
		o.default = '0';

		o = s.taboption('bittorrent', form.Value, 'MaxConnecs', _('Max Connections'),
		_('The max number of connections.'));
		o.datatype = 'integer';
		o.placeholder = '500';

		o = s.taboption('bittorrent', form.Value, 'MaxConnecsPerTorrent',
			_('Max Connections Per Torrent'), _('The max number of connections per torrent.'));
		o.datatype = 'integer';
		o.placeholder = '100';

		o = s.taboption('bittorrent', form.Value, 'MaxUploads', _('Max Uploads'),
			_('The max number of connected peers.'));
		o.datatype = 'integer';
		o.placeholder = '8';

		o = s.taboption('bittorrent', form.Value, 'MaxUploadsPerTorrent', _('Max Uploads Per Torrent'),
			_('The max number of connected peers per torrent.'));
		o.datatype = 'integer';
		o.placeholder = '4';

		o = s.taboption('bittorrent', form.Value, 'MaxRatio', _('Max Ratio'),
			_('The max ratio for seeding. -1 is not to limit the seeding.'));
		o.datatype = 'float';
		o.placeholder = '-1';

		o = s.taboption('bittorrent', form.ListValue, 'MaxRatioAction', _('Max Ratio Action'),
			_('The action when reach the max seeding ratio.'));
		o.value('0', _('Pause them'));
		o.value('1', _('Remove them'));
		o.defaule = '0';

		o = s.taboption('bittorrent', form.Value, 'GlobalMaxSeedingMinutes',
			_('Max Seeding Minutes'), _('Units: minutes'));
		o.datatype = 'integer';

		o = s.taboption('bittorrent', form.DummyValue, 'Queueing Setting', splitter_html.format(_('Queueing Setting')));
		o.default = '';

		o = s.taboption('bittorrent', form.Flag, 'QueueingEnabled', _('Enable Torrent Queueing'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('bittorrent', form.Value, 'MaxActiveDownloads', _('Maximum Active Downloads'));
		o.datatype = 'integer';
		o.placeholder = '3';

		o = s.taboption('bittorrent', form.Value, 'MaxActiveUploads', _('Max Active Uploads'));
		o.datatype = 'integer';
		o.placeholder = '3';

		o = s.taboption('bittorrent', form.Value, 'MaxActiveTorrents', _('Max Active Torrents'));
		o.datatype = 'integer';
		o.placeholder = '5';

		o = s.taboption('bittorrent', form.Flag, 'IgnoreSlowTorrents', _('Ignore Slow Torrents'),
			_('Do not count slow torrents in these limits.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('bittorrent', form.Value, 'SlowTorrentsDownloadRate',
			_('Download rate threshold'), _('Units: KiB/s'));
		o.datatype = 'integer';
		o.placeholder = '2';

		o = s.taboption('bittorrent', form.Value, 'SlowTorrentsUploadRate',
			_('Upload rate threshold'), _('Units: KiB/s'));
		o.datatype = 'integer';
		o.placeholder = '2';

		o = s.taboption('bittorrent', form.Value, 'SlowTorrentsInactivityTimer',
			_('Torrent inactivity timer'), _('Units: s'));
		o.datatype = 'integer';
		o.placeholder = '60';

		o = s.taboption('webgui', form.Flag, 'UseUPnP', _('Use UPnP for WebUI'),
			_('Using the UPnP / NAT-PMP port of the router for connecting to WebUI.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('webgui', form.Value, 'Username', _('Username'), _('The login name for WebUI.'));
		o.placeholder = 'admin';

		o = s.taboption('webgui', form.Value, 'Password', _('Password'), _('The login password for WebUI.'));
		o.password = true;

		if (v && v.split('.')[0] >= 4 && v.split('.')[1] > 1) o = s.taboption('webgui', form.HiddenValue, 'Password_PBKDF2');

		o = s.taboption('webgui', form.Value, 'Address', _('Listening Address'), _('The listening IP address for WebUI.'));
		o.datatype = 'ipaddr';

		o = s.taboption('webgui', form.Value, 'Port', _('Listening Port'), _('The listening port for WebUI.'));
		o.datatype = 'port';
		o.placeholder = '8080';

		o = s.taboption('webgui', form.Flag, 'CSRFProtection', _('CSRF Protection'),
			_('Enable Cross-Site Request Forgery (CSRF) protection.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('webgui', form.Flag, 'ClickjackingProtection', _('Clickjacking Protection'),
			_('Enable clickjacking protection.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('webgui', form.Flag, 'HostHeaderValidation', _('Host Header Validation'),
			_('Validate the host header.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('webgui', form.Flag, 'LocalHostAuth', _('Local Host Authentication'),
			_('Force authentication for clients on localhost.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('webgui', form.Flag, 'AuthSubnetWhitelistEnabled', _('Enable Subnet Whitelist'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('webgui', form.DynamicList, 'AuthSubnetWhitelist', _('Subnet Whitelist'));
		o.depends('AuthSubnetWhitelistEnabled', 'true');

		o = s.taboption('advanced', form.Flag, 'AnonymousMode', _('Anonymous Mode'), '%s %s %s.'.format(
			_('When enabled, qBittorrent will take certain measures to try to mask its identity.'),
			_('Refer to the'), '<a href="https://github.com/qbittorrent/qBittorrent/wiki/' +
			'Anonymous-Mode" target="_blank">wiki</a>'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('advanced', form.Flag, 'IncludeOverhead', _('Limit Overhead Usage'),
			_('The overhead usage is been limitted.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('advanced', form.Flag, 'IgnoreLimitsLAN', _('Ignore LAN Limit'),
			_('Ignore the speed limit to LAN.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('advanced', form.Flag, 'osCache', _('Use os Cache'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		o = s.taboption('advanced', form.Value, 'OutgoingPortsMax', _('Max Outgoing Port'),
			_('The max outgoing port.'));
		o.datatype = 'port';

		o = s.taboption('advanced', form.Value, 'OutgoingPortsMin', _('Min Outgoing Port'),
			_('The min outgoing port.'));
		o.datatype = 'port';

		o = s.taboption('advanced', form.ListValue, 'SeedChokingAlgorithm', _('Choking Algorithm'),
			_('The strategy of choking algorithm.'));
		o.value('RoundRobin', _('Round Robin'));
		o.value('FastestUpload', _('Fastest Upload'));
		o.value('AntiLeech', _('Anti-Leech'));
		o.default = 'FastestUpload';

		o = s.taboption('advanced', form.Flag, 'AnnounceToAllTrackers', _('Announce To All Trackers'),
			_('Announce To all trackers of per tier.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.disabled;

		o = s.taboption('advanced', form.Flag, 'AnnounceToAllTiers', _('Announce To All Tiers'),
			_('The first tier (0 tier) is announced by default.'));
		o.enabled = 'true';
		o.disabled = 'false';
		o.default = o.enabled;

		return m.render().then(function(node) {
			node.appendChild(E('script', { 'src': L.resource('view/qbittorrent/sjcl.js') }));
			node.appendChild(E('style', { 'type': 'text/css' }, [ css ]));
			return node;
		});
	},

	handleSave: function(ev) {
		var changed, e, pwd;
		changed = document.getElementById('cbid.qbittorrent.main.Password').getAttribute('data-changed');
		if (changed) {
			pwd = document.getElementById('widget.cbid.qbittorrent.main.Password').value;
			e = document.getElementById('cbid.qbittorrent.main.Password_PBKDF2');

			if (e) e.value = encryptPassword(pwd);
		}
		return this.super('handleSave', ev);
	}
});
