'use strict';
'require form';
'require fs';
'require poll';
'require rpc';
'require uci';
'require view';
'require dom';

return view.extend({
    render: function() {
        // CSS 样式设置，控制日志文本框的高度和滚动条
		var css = `
			#log_textarea {
				margin-top: 10px;
			}
			#log_textarea pre {
				color: #333;
				padding: 10px;
				border: 1px solid #ccc;
				border-radius: 4px;
				font-family: Consolas, Menlo, Monaco, monospace;
				font-size: 14px;
				line-height: 1.5;
				white-space: pre-wrap;
				word-wrap: break-word;
				overflow-y: auto;
				max-height: 200px;
				background-color: #f7f7f7;
			}
			#.description {
				background-color: #33ccff;
			}`;

        // 日志显示区域
        var log_textarea = E('div', { 'id': 'log_textarea' },
            E('img', {
                'src': L.resource('icons/loading.gif'),
                'alt': _('Loading...')
            }, _('Collecting data...'))
        );

        // 缓存上次读取的内容
        var lastContent = '';

        // 读取日志的函数
        function updateLog() {
            fs.read_direct('/var/log/vlmcsd.log', 'text')
                .then(function(res) {
                    var content = res.trim();
                    var log = E('pre', { 'wrap': 'pre' }, [
                        content || _('Log is empty.')  // 如果内容为空，显示默认消息
                    ]);
                    dom.content(log_textarea, log);
                })
                .catch(function(err) {
                    var log;
                    if (err.toString().includes('NotFoundError')) {
                        // 如果日志文件不存在，显示占位符并保持固定高度
                        log = E('pre', { 'wrap': 'pre' }, [
                            _('Log file does not exist.')
                        ]);
                    } else {
                        log = E('pre', { 'wrap': 'pre' }, [
                            _('Unknown error: %s').format(err)
                        ]);
                    }
                    dom.content(log_textarea, log);
                });
        }

        // 页面加载时直接显示日志内容
        updateLog();

        // 启动轮询，定期更新日志
        var pollLog = L.bind(function() {
            return fs.stat('/var/log/vlmcsd.log')
                .then(function(stats) {
                    // 检查文件是否存在并更新日志
                    updateLog();
                })
                .catch(function(err) {
                    var log;
                    if (err.toString().includes('NotFoundError')) {
                        log = E('pre', { 'wrap': 'pre' }, [
                            _('Log file does not exist.')
                        ]);
                    } else {
                        log = E('pre', { 'wrap': 'pre' }, [
                            _('Unknown error: %s').format(err)
                        ]);
                    }
                    dom.content(log_textarea, log);
                });
        });

        // 启动轮询
        poll.add(pollLog);

        // 返回页面内容
        return E([
            E('style', [ css ]),  // 引入 CSS 样式
            E('div', { 'class': 'cbi-map' }, [
                E('div', { 'class': 'cbi-section' }, [
                    log_textarea,
                    E('div', { 'style': 'text-align:right' },
                        E('small', {}, _('Refresh every %s seconds.').format(L.env.pollinterval))
                    )
                ])
            ])
        ]);
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});
