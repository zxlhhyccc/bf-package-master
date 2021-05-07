'use strict';
'require fs';
'require form';
'require rpc';
'require tools.widgets as widgets';
'require uci';

var splitter_html='<p style="font-size:20px;font-weight:bold;color: DodgerBlue">%s</p>';

var callServiceList=rpc.declare({
	object:'service',
	method:'list',
	params:['name'],
	expect:{'':{}},
	filter:function(data,args,extArgs){
		var i,res=data[args.name]||{};
		for(i=0;(i<extArgs.length)&&(Object.keys(res).length>0);i++)
			res=res[extArgs[i]]||{};
		return res;
	}
});

var callUciGet=rpc.declare({
	object:'uci',
	method:'get',
	params:['config','section','option'],
	expect:{'value':''}
});

var CBIQBitStatus=form.DummyValue.extend({
	renderWidget:function(){
		var extAgrs=['instances','qbittorrent.main'];
		var label=E('div',{},E('em',{},_('Collecting data...')));
		var btn=E('button',{'class':'cbi-button cbi-button-apply'},_('Start qBittorrent'));
		var node=E('div',{},[label,btn]);
		L.Poll.add(function(){
			callServiceList('qbittorrent',extAgrs).then(function(res){
				if(res.running){
					L.dom.content(label,E('em',{},_('The qBittorrent daemon is running. Click the button below to startup the WebUI.')));
					btn.textContent='PID: %s'.format(res.pid);
					btn.onclick=onclick_action.bind(this,'webui');
				}else{
					L.dom.content(label,E('em',{},_('The qBittorrent daemon is not running. Click the button below to startup the daemon.')));
					btn.textContent=_('Start qBittorrent');
					btn.onclick=onclick_action.bind(this,'qbt');
				}
			});
		});
		return node;
	}
});

var CBIRandomPort=form.Value.extend({
	renderWidget:function(section_id,option_index,cfgvalue){
		var node=this.super('renderWidget',[section_id,option_index,cfgvalue]);
		node.appendChild(E('div',{'class':'control-group'},[
			node.firstElementChild,
			E('button',{
				'class':'cbi-button cbi-button-neutral',
				'click':function(){
					this.previousElementSibling.value=randomPort();
				}
			},_('Generate Randomly'))
			]));
		return node;
	}
});

function encryptPassword(pwd,flag){
	if(flag){
		var salt,key,res;
		salt=new Uint8Array(16);
		asmCrypto.getRandomValues(salt);
		key=asmCrypto.Pbkdf2HmacSha512(asmCrypto.string_to_bytes(pwd),salt,100000,64);
		res=asmCrypto.bytes_to_base64(salt)+':'+asmCrypto.bytes_to_base64(key);
	}else{
		res=CryptoJS.enc.Hex.stringify(CryptoJS.MD5(pwd))
	}
	return res;
};

function onclick_action(target){
	if(target=="webui"){
		Promise.all([
			callUciGet('qbittorrent','main','HTTPS__Enabled'),
			callUciGet('qbittorrent','main','Port')
			]).then(function(val){
				var protocol=val[0]?'https:':'http:';
				var host=window.location.host;var port=val[1]||'8080';
				window.open(protocol+'//'+host+':'+port,'_blank');
			});
		}else{
			fs.exec('/etc/init.d/qbittorrent',['start']);
			L.Poll.queue[0].fn();
		}
	};

function randomPort(){
	return Math.floor(Math.random()*(65535-1024))+1024;
};

return L.view.extend({
	load:function(){
		document.body.append(E('script',{'src':L.resource('view/qbittorrent/asmcrypto.all.es5.min.js')}));
		return fs.exec('/usr/bin/qbittorrent-nox',['-v'],{'HOME':'/var/run/qbittorrent'}).then(function(res){
			fs.exec('/bin/rm',['-rf','/var/run/qbittorrent']);
			return res.stdout?res.stdout.match(/(\d\.)+\d/)[0]:'';
		});
	},
	render:function(ver){
		var m,s,o;

		m=new form.Map('qbittorrent',_('qBittorrent'),'%s %s %s.<br\><b style="color:red">%s</b>'
			.format(_('A BT/PT downloader base on Qt.'),_('Refer to the'),
				'<a href="https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-'+
				'in-qBittorrent" target="_blank">help</a>',_('Current Version: %s.').format(ver)));

		s=m.section(form.TypedSection);
		s.title=_('qBittorrent Status');
		s.anonymous=true;
		s.cfgsections=function(){return['status']};

		o=s.option(CBIQBitStatus);
		s=m.section(form.NamedSection,'main','qbittorrent');
		s.tab('basic',_('Basic Settings'));
		s.tab('logger',_('Log Settings'));
		s.tab('connection',_('Connection Settings'));
		s.tab('downloads',_('Downloads Settings'));
		s.tab('bittorrent',_('Bittorrent Settings'));
		s.tab('webui',_('WebUI Settings'));
		s.tab('advanced',_('Advance Settings'));

		o=s.taboption('basic',form.Flag,'EnableService',_('Enabled'));
		o.default='0';

		o=s.taboption('basic',widgets.UserSelect,'user',_('Run daemon as user'));

		o=s.taboption('basic',form.Value,'MemoryPercent',_('Memory Limit'),_('Percentage.'))
		o.placeholder='50'
		o.datatype='range(1, 99)'

		o=s.taboption('basic',form.Value,'BinaryLocation',_('Customized Location'),_('Specify the binary location of qBittorrent.'));
		o=s.taboption('basic',form.Value,'RootProfilePath',_('Root Path of the Profile'),
			_('Specify the root path of all profiles which is equivalent to the commandline parameter: <b>--profile [PATH]</b>. The default value is /tmp.'));o.default='/tmp';o.placeholder='/tmp';o=s.taboption('basic',form.Value,'ConfigurationName',_('The Suffix of the Profile Root Path'),_('Specify the suffix of the profile root path and a new profile root path will be formated as <b>[ROOT_PROFILE_PATH]_[SUFFIX]</b>. This value is empty by default.'));

		o=s.taboption('basic',form.Value,'Locale',_('Locale Language'),
			_('The supported language codes can be used to customize the setting.'));
		o.value('en',_('English (en)'));
		o.value('zh',_('Chinese (zh)'));
		o.default='en';

		o=s.taboption('basic',form.Flag,'Overwrite',_('Overwrite the settings'),
			_('If this option is enabled, the configuration set in WebUI will be replaced by the one in the LuCI.'));
		o.default=o.disabled;

		o=s.taboption('logger',form.Flag,'Enabled',_('Enable Log'),_('Enable logger to log file.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('logger',form.Value,'Path',_('Log Path'),_('The path for qBittorrent log.'));
		o.depends('Enabled','true');

		o=s.taboption('logger',form.Flag,'Backup',_('Enable Backup'),
			_('Backup log file when oversize the given size.'));
		o.depends('Enabled','true');
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('logger',form.Flag,'DeleteOld',_('Delete Old Backup'),
			_('When enabled, the overdue log files will be deleted after given keep time.'));
		o.depends('Enabled','true');
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('logger',form.Value,'MaxSizeBytes',_('Log Max Size'),
			_('The max size for qBittorrent log (Unit: Bytes).'));
		o.depends('Enabled','true');
		o.placeholder='66560';

		o=s.taboption('logger',form.Value,'SaveTime',_('Log Keep Time'),_('Give the '+
			'time for keeping the old log, refer the setting \'Delete Old Backup\', eg. 1d'+
			' for one day, 1m for one month and 1y for one year.'));
		o.depends('Enabled','true');
		o.datatype='string';

		o=s.taboption('connection',form.Flag,'UPnP',_('Use UPnP for Connections'),'%s %s %s.'
			.format(_('Use UPnP/ NAT-PMP port forwarding from the router.'),_('Refer to the'),
				'<a href="https://en.wikipedia.org/wiki/Port_forwarding" target="_blank">wiki</a>'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('connection',form.Flag,'UseRandomPort',_('Use Random Port'),
			_('Assign a different port randomly every time when qBittorrent starts up,'+
				' which will invalidate the customized options.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('connection',CBIRandomPort,'PortRangeMin',_('Connection Port'));
		o.depends('UseRandomPort','false');
		o.datatype='range(1024,65535)';
		o.default=randomPort();
		o.rmempty=false;

		o=s.taboption('connection',form.Value,'GlobalDLLimit',_('Global Download Speed'),
			'%s %s'.format(_('Global Download Speed Limit(KiB/s).'),_('0 means has no limit.')));
		o.datatype='float';
		o.placeholder='0';

		o=s.taboption('connection',form.Value,'GlobalUPLimit',_('Global Upload Speed'),
			'%s %s'.format(_('Global Upload Speed Limit(KiB/s).'),_('0 means has no limit.')));
		o.datatype='float';
		o.placeholder='0';

		o=s.taboption('connection',form.Value,'GlobalDLLimitAlt',_('Alternative Download Speed'),
			'%s %s'.format(_('Alternative Download Speed Limit(KiB/s).'),_('0 means has no limit.')));
		o.datatype='float';
		o.placeholder='10';

		o=s.taboption('connection',form.Value,'GlobalUPLimitAlt',_('Alternative Upload Speed'),
			'%s %s'.format(_('Alternative Upload Speed Limit(KiB/s).'),_('0 means has no limit.')));
		o.datatype='float';
		o.placeholder='10';

		o=s.taboption('connection',form.ListValue,'BTProtocol',_('Protocol Enabled'),
			_('The protocol that was enabled.'));
		o.value('Both',_('TCP and UTP'));
		o.value('TCP',_('TCP'));
		o.value('UTP',_('UTP'));
		o.default='Both';

		o=s.taboption('connection',form.Value,'InetAddress',_('Inet Address'),
			_('The address that respond to the trackers.'));

		o=s.taboption('downloads',form.Flag,'CreateTorrentSubfolder',_('Create Subfolder'),
			_('Create subfolder for torrents with multiple files.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('downloads',form.Flag,'StartInPause',_('Start In Pause'),
			_('Do not start the download automatically.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('downloads',form.Flag,'AutoDeleteAddedTorrentFile',
			_('Auto Delete Torrent File'),_('The .torrent files will be deleted afterwards.'));
		o.enabled='IfAdded';
		o.disabled='Never';
		o.default=o.disabled;

		o=s.taboption('downloads',form.Flag,'PreAllocation',_('Pre Allocation'),
			_('Pre-allocate disk space for all files.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('downloads',form.Flag,'UseIncompleteExtension',_('Use Incomplete Extension'),
			_('The incomplete tasks will be added the extension of !qB.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('downloads',form.Value,'SavePath',_('Save Path'),
			_('Specify the path of the downloaded files.'));
		o.placeholder='/tmp/download';

		o=s.taboption('downloads',form.Flag,'TempPathEnabled',_('Enable Temp Path'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('downloads',form.Value,'TempPath',_('Temp Path'),
			_('The absolute and relative path can be set.'));
		o.depends('TempPathEnabled','true');
		o.placeholder='temp/';

		o=s.taboption('downloads',form.Value,'DiskWriteCacheSize',_('Disk Cache Size'),
			_('By default, this value 64. Besides, -1 is auto and 0 is disable. (Unit: MiB)'));
		o.datatype='integer';
		o.placeholder='64';

		o=s.taboption('downloads',form.Value,'DiskWriteCacheTTL',_('Disk Cache TTL'),
			_('By default, this value is 60. (Unit: s)'));
		o.datatype='integer';
		o.placeholder='60';

		o=s.taboption('downloads',form.DummyValue,'Saving Management',splitter_html.format(_('Saving Management')));
		o.default='';

		o=s.taboption('downloads',form.ListValue,'DisableAutoTMMByDefault',
			_('Default Torrent Management Mode'));
		o.value('true',_('Manual'));
		o.value('false',_('Automaic'));
		o.default='true';

		o=s.taboption('downloads',form.ListValue,'CategoryChanged',_('Torrent Category Changed'),
			_('Choose the action when torrent category changed.'));
		o.value('true',_('Switch torrent to Manual Mode'));
		o.value('false',_('Relocate torrent'));
		o.default='false';

		o=s.taboption('downloads',form.ListValue,'DefaultSavePathChanged',
			_('Default Save Path Changed'),_('Choose the action when default save path changed.'));
		o.value('true',_('Switch affected torrent to Manual Mode'));
		o.value('false',_('Relocate affected torrent'));
		o.default='true'

		;o=s.taboption('downloads',form.ListValue,'CategorySavePathChanged',
			_('Category Save Path Changed'),_('Choose the action when category save path changed.'));
		o.value('true',_('Switch affected torrent to Manual Mode'));
		o.value('false',_('Relocate affected torrent'));
		o.default='true';

		o=s.taboption('downloads',form.Value,'TorrentExportDir',_('Torrent Export Dir'),
			_('The .torrent files will be copied to the target directory.'));

		o=s.taboption('downloads',form.Value,'FinishedTorrentExportDir',_('Finished Torrent Export Dir'),
			_('The .torrent files for finished downloads will be copied to the target directory.'));

		o=s.taboption('bittorrent',form.Flag,'DHT',_('Enable DHT'),
			_('Enable DHT (decentralized network) to find more peers.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('bittorrent',form.Flag,'PeX',_('Enable PeX'),
			_('Enable Peer Exchange (PeX) to find more peers.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('bittorrent',form.Flag,'LSD',_('Enable LSD'),
			_('Enable Local Peer Discovery to find more peers.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('bittorrent',form.Flag,'uTP_rate_limited',_('μTP Rate Limit'),
			_('Apply rate limit to μTP protocol.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('bittorrent',form.ListValue,'Encryption',_('Encryption Mode'));
		o.value('0',_('Prefer Encryption'));
		o.value('1',_('Require Encryption'));
		o.value('2',_('Disable Encryption'));
		o.default='0';

		o=s.taboption('bittorrent',form.Value,'MaxConnecs',_('Max Connections'),
			_('The max number of connections.'));
		o.datatype='integer';
		o.placeholder='500';

		o=s.taboption('bittorrent',form.Value,'MaxConnecsPerTorrent',
			_('Max Connections Per Torrent'),_('The max number of connections per torrent.'));
		o.datatype='integer';
		o.placeholder='100';

		o=s.taboption('bittorrent',form.Value,'MaxUploads',_('Max Uploads'),
			_('The max number of connected peers.'));
		o.datatype='integer';
		o.placeholder='8';

		o=s.taboption('bittorrent',form.Value,'MaxUploadsPerTorrent',_('Max Uploads Per Torrent'),
			_('The max number of connected peers per torrent.'));
		o.datatype='integer';
		o.placeholder='4';

		o=s.taboption('bittorrent',form.Value,'MaxRatio',_('Max Ratio'),
			_('The max ratio for seeding. -1 is not to limit the seeding.'));
		o.datatype='float';
		o.placeholder='-1';

		o=s.taboption('bittorrent',form.ListValue,'MaxRatioAction',_('Max Ratio Action'),
			_('The action when reach the max seeding ratio.'));
		o.value('0',_('Pause them'));
		o.value('1',_('Remove them'));
		o.defaule='0';

		o=s.taboption('bittorrent',form.Value,'GlobalMaxSeedingMinutes',
			_('Max Seeding Minutes'),_('Units: minutes'));
		o.datatype='integer';

		o=s.taboption('bittorrent',form.DummyValue,'Queueing Setting',splitter_html.format(_('Queueing Setting')));
		o.default='';

		o=s.taboption('bittorrent',form.Flag,'QueueingEnabled',_('Enable Torrent Queueing'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('bittorrent',form.Value,'MaxActiveDownloads',_('Maximum Active Downloads'));
		o.datatype='integer';
		o.placeholder='3';

		o=s.taboption('bittorrent',form.Value,'MaxActiveUploads',_('Max Active Uploads'));
		o.datatype='integer';
		o.placeholder='3';

		o=s.taboption('bittorrent',form.Value,'MaxActiveTorrents',_('Max Active Torrents'));
		o.datatype='integer';
		o.placeholder='5';

		o=s.taboption('bittorrent',form.Flag,'IgnoreSlowTorrents',_('Ignore Slow Torrents'),
			_('Do not count slow torrents in these limits.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('bittorrent',form.Value,'SlowTorrentsDownloadRate',
			_('Download rate threshold'),_('Units: KiB/s'));
		o.datatype='integer';
		o.placeholder='2';

		o=s.taboption('bittorrent',form.Value,'SlowTorrentsUploadRate',
			_('Upload rate threshold'),_('Units: KiB/s'));
		o.datatype='integer';
		o.placeholder='2';

		o=s.taboption('bittorrent',form.Value,'SlowTorrentsInactivityTimer',
			_('Torrent inactivity timer'),_('Units: s'));
		o.datatype='integer';
		o.placeholder='60';

		o=s.taboption('webui',form.Flag,'UseUPnP',_('Use UPnP for WebUI'),
			_('Using the UPnP / NAT-PMP port of the router for connecting to WebUI.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('webui',form.Value,'Username',_('Username'),_('The login name for WebUI.'));
		o.placeholder='admin';

		o=s.taboption('webui',form.Value,'Password',_('Password'),_('The login password for WebUI.'));
		o.password=true;

		o.formvalue=function(section_id){
			var elem=this.getUIElement(section_id);
			var node=this.map.findElement('id',this.cbid(section_id));
			var flag=ver.split('.').map(function(res){return parseInt(res)})>=[4,2,0];

			if(node&&node.getAttribute('data-changed')=='true')
				return elem?encryptPassword(elem.getValue(),flag):null;
		else
				return elem?elem.getValue():null;
		};

		o=s.taboption('webui',form.Value,'Address',_('Listening Address'),_('The listening IP address for WebUI.'));
		o.datatype='ipaddr';
		o.placeholder='0.0.0.0';

		o=s.taboption('webui',form.Value,'Port',_('Listening Port'),_('The listening port for WebUI.'));
		o.datatype='port';
		o.placeholder='8080';

		o=s.taboption('webui',form.Flag,'HTTPS__Enabled',_('Enable HTTPS'),
			_('Encrypt the connections with qbittorrent by SSL/TLS. The web clients must use https'
+' scheme to access the WebUI.'));
		o.enabled='true';
		o.disabled='false';

		o=s.taboption('webui',form.Value,'HTTPS__CertificatePath',_('Path to the Certificate'));
		o.depends('HTTPS__Enabled','true');

		o=s.taboption('webui',form.Value,'HTTPS__KeyPath',_('Path to the Key'));
		o.depends('HTTPS__Enabled','true');

		o=s.taboption('webui',form.Flag,'ClickjackingProtection',_('Clickjacking Protection'),
			_('Enable clickjacking protection.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('webui',form.Flag,'CSRFProtection',_('CSRF Protection'),
			_('Enable Cross-Site Request Forgery (CSRF) protection.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('webui',form.Flag,'SecureCookie',_('Cookie Secure flag'),
			_('Enable cookie secure flag (require HTTPS).'));
		o.depends('HTTPS__Enabled','true');
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('webui',form.Flag,'HostHeaderValidation',_('Host Header Validation'),
			_('Validate the host header.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('webui',form.Value,'ServerDomains',_('Server Domains'));
		o.placeholder='*';
		o.depends('HostHeaderValidation','true');

		o=s.taboption('webui',form.Flag,'LocalHostAuth',_('Bypass Local Host Authentication'),
			_('Bypass authentication for clients on localhost.'));
		o.enabled='false';
		o.disabled='true';
		o.default=o.disabled;

		o=s.taboption('webui',form.Flag,'AuthSubnetWhitelistEnabled',
			_('Bypass authentication for clients in Whitelisted IP Subnets.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('webui',form.DynamicList,'AuthSubnetWhitelist',_('Subnet Whitelist'));
		o.depends('AuthSubnetWhitelistEnabled','true');

		o=s.taboption('webui',form.Flag,'CustomHTTPHeadersEnabled',_('Add Custom HTTP Headers'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('webui',form.TextValue,'CustomHTTPHeaders',_('Custom HTTP Headers'));
		o.depends('CustomHTTPHeadersEnabled','true');
		o.placeholder=_('Header: value pairs, one per line');

		o=s.taboption('advanced',form.Flag,'AnonymousMode',_('Anonymous Mode'),'%s %s %s.'.format(
			_('When enabled, qBittorrent will take certain measures to try to mask its identity.'),
			_('Refer to the'),'<a href="https://github.com/qbittorrent/qBittorrent/wiki/'+
			'Anonymous-Mode" target="_blank">wiki</a>'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('advanced',form.Flag,'IncludeOverhead',_('Limit Overhead Usage'),
			_('The overhead usage is been limitted.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('advanced',form.Flag,'IgnoreLimitsLAN',_('Ignore LAN Limit'),
			_('Ignore the speed limit to LAN.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('advanced',form.Flag,'osCache',_('Use os Cache'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;

		o=s.taboption('advanced',form.Value,'OutgoingPortsMax',_('Max Outgoing Port'),
			_('The max outgoing port.'));
		o.datatype='port';

		o=s.taboption('advanced',form.Value,'OutgoingPortsMin',_('Min Outgoing Port'),
			_('The min outgoing port.'));
		o.datatype='port';

		o=s.taboption('advanced',form.ListValue,'SeedChokingAlgorithm',_('Choking Algorithm'),
			_('The strategy of choking algorithm.'));
		o.value('RoundRobin',_('Round Robin'));
		o.value('FastestUpload',_('Fastest Upload'));
		o.value('AntiLeech',_('Anti-Leech'));
		o.default='FastestUpload';

		o=s.taboption('advanced',form.Flag,'AnnounceToAllTrackers',_('Announce To All Trackers'),
			_('Announce To all trackers of per tier.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.disabled;

		o=s.taboption('advanced',form.Flag,'AnnounceToAllTiers',_('Announce To All Tiers'),
			_('The first tier (0 tier) is announced by default.'));
		o.enabled='true';
		o.disabled='false';
		o.default=o.enabled;
		return m.render();
	}
});