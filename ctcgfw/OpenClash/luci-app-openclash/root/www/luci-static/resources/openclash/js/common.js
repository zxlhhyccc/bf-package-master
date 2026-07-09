// OpenClash shared utilities

function isDarkBackground(element) {
	var cachedTheme = localStorage.getItem('oc-theme');
	if (cachedTheme === 'dark') {
		return true;
	} else if (cachedTheme === 'light') {
		return false;
	}

	if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
		return true;
	}

	var style = window.getComputedStyle(element);
	var bgColor = style.backgroundColor;
	var r, g, b;
	if (/rgb\(/.test(bgColor)) {
		var rgb = bgColor.match(/\d+/g);
		r = parseInt(rgb[0]);
		g = parseInt(rgb[1]);
		b = parseInt(rgb[2]);
	} else if (/#/.test(bgColor)) {
		if (bgColor.length === 4) {
			r = parseInt(bgColor[1] + bgColor[1], 16);
			g = parseInt(bgColor[2] + bgColor[2], 16);
			b = parseInt(bgColor[3] + bgColor[3], 16);
		} else {
			r = parseInt(bgColor.slice(1, 3), 16);
			g = parseInt(bgColor.slice(3, 5), 16);
			b = parseInt(bgColor.slice(5, 7), 16);
		}
	} else {
		return false;
	}
	var luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
	return luminance < 128;
}

function winOpen(url) {
	var win = window.open(url);
	if (win == null) {
		window.location.href = url;
	}
	return false;
}

// ── Editor state ────────────────────────────────────────────────

window._ocFullscreenActive = false;
window._ocMergeShowDifferences = true;
window._ocEditorHotkeysBound = false;
window._ocFullscreenPatch = null;

window._ocZoomLevels = [75, 90, 100, 110, 125, 150, 200];
window._ocCurrentZoom = 100;

// ── Fullscreen helpers ──────────────────────────────────────────
// Walk ancestors and patch stacking contexts so position:fixed can
// break out. backdrop-filter traps fixed children (creates a
// containing block); positioned+z-index creates a stacking context.
// We fix the closest backdrop-filter and the outermost z-index.

// Handles both EditorView (.dom) and MergeView (.a.dom, .b.dom)
function ocGetEditorDom(instance) {
	if (!instance) return null;
	if (instance.dom) return instance.dom;
	if (instance.a && instance.a.dom) return instance.a.dom;
	return null;
}

function _ocEnterFullscreen(dom) {
	_ocExitFullscreen();
	var patch = window._ocFullscreenPatch = {};
	var el = dom.parentNode;
	while (el && el !== document.body && el !== document.documentElement) {
		var cs = window.getComputedStyle(el);
		if (!patch.bfEl) {
			var bf = cs.backdropFilter || cs.webkitBackdropFilter;
			if (bf && bf !== 'none') {
				patch.bfEl = el;
				patch.bfOld = el.style.backdropFilter;
				el.style.backdropFilter = 'none';
			}
		}
		var pos = cs.position;
		var zi = cs.zIndex;
		if ((pos === 'relative' || pos === 'absolute' || pos === 'fixed' || pos === 'sticky') && zi !== 'auto') {
			patch.zEl = el;
			patch.zOld = el.style.zIndex;
		}
		el = el.parentNode;
	}
	if (patch.zEl) {
		patch.zEl.style.setProperty('z-index', '999999', 'important');
	}
}

function _ocExitFullscreen() {
	var p = window._ocFullscreenPatch;
	if (!p) return;
	if (p.zEl) {
		if (p.zOld !== undefined && p.zOld !== '') {
			p.zEl.style.zIndex = p.zOld;
		} else {
			p.zEl.style.removeProperty('z-index');
		}
	}
	if (p.bfEl) {
		if (p.bfOld !== undefined && p.bfOld !== '') {
			p.bfEl.style.backdropFilter = p.bfOld;
		} else {
			p.bfEl.style.removeProperty('backdrop-filter');
		}
	}
	window._ocFullscreenPatch = null;
}

// ── Active editor lookup ────────────────────────────────────────
// Priority: merge editor state > ConfigEditor modal > CM6.getActiveEditor()

function ocGetActiveEditorInstance() {
	if (window._mergeEditorState && window._mergeEditorState.instance) {
		return window._mergeEditorState.instance;
	}
	if (window.ConfigEditor && window.ConfigEditor.editorInstance) {
		return window.ConfigEditor.editorInstance;
	}
	if (typeof CM6 !== 'undefined' && CM6.getActiveEditor) {
		return CM6.getActiveEditor();
	}
	return null;
}

// ── Zoom ────────────────────────────────────────────────────────
// Applies zoom-{level} CSS class to .cm-editor elements.
// For MergeView, applies to BOTH side panels so the .oc .cm-editor.zoom-XX rules match.

function ocApplyZoom(instance, zoomLevel) {
	var doms = [];
	if (instance) {
		if (instance.a && instance.a.dom && instance.b && instance.b.dom) {
			doms = [instance.a.dom, instance.b.dom];
		} else if (instance.dom) {
			doms = [instance.dom];
		} else if (instance.classList && instance.classList.contains('cm-editor')) {
			doms = [instance];
		}
	}

	if (!doms.length) {
		var activeEl = document.activeElement;
		if (activeEl) {
			var ed = activeEl.closest('.cm-editor');
			if (ed) doms = [ed];
		}
	}
	if (!doms.length) return;

	doms.forEach(function(dom) {
		window._ocZoomLevels.forEach(function(level) {
			dom.classList.remove('zoom-' + level);
		});
		if (zoomLevel !== 100) {
			dom.classList.add('zoom-' + zoomLevel);
		}
	});
	window._ocCurrentZoom = zoomLevel;
}

// Returns new zoom level without applying it
function ocZoomIn(currentZoom) {
	var cur = typeof currentZoom === 'number' ? currentZoom : window._ocCurrentZoom;
	var idx = window._ocZoomLevels.indexOf(cur);
	if (idx < window._ocZoomLevels.length - 1) {
		return window._ocZoomLevels[idx + 1];
	}
	return cur;
}

function ocZoomOut(currentZoom) {
	var cur = typeof currentZoom === 'number' ? currentZoom : window._ocCurrentZoom;
	var idx = window._ocZoomLevels.indexOf(cur);
	if (idx > 0) {
		return window._ocZoomLevels[idx - 1];
	}
	return cur;
}

function ocResetZoom() {
	return 100;
}

// Passthrough for CM5-era _cmWhenReady compatibility
window._cmWhenReady = function(cb) { cb(); };

// ── Theme ───────────────────────────────────────────────────────

// Idempotent — second call only re-applies dark mode
function ocInitTheme() {
	if (window._ocThemeInited) {
		ocUpdateTheme();
		return;
	}
	window._ocThemeInited = true;

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', function() {
			ocUpdateTheme();
			ocHideEmptyCbiElements();
			ocCenterCbiActions();
		});
	} else {
		ocUpdateTheme();
		ocHideEmptyCbiElements();
		ocCenterCbiActions();
	}
}

function ocUpdateTheme() {
	var isDark = isDarkBackground(document.body);
	var ocEls = document.querySelectorAll('.oc');
	for (var i = 0; i < ocEls.length; i++) {
		if (isDark) {
			ocEls[i].setAttribute('data-darkmode', 'true');
		} else {
			ocEls[i].removeAttribute('data-darkmode');
		}
	}
	// Apply CM6 editor themes
	if (typeof CM6 !== 'undefined' && CM6.dispatchTheme) {
		var editors = document.querySelectorAll('.cm-editor');
		for (var j = 0; j < editors.length; j++) {
			var view = editors[j].cmView && editors[j].cmView.view;
			if (view) {
				try { CM6.dispatchTheme(view, isDark); } catch(e) {}
			}
		}
	}
	if (typeof CM6 !== 'undefined' && CM6.switchHljsTheme) {
		CM6.switchHljsTheme(isDark);
	}
}

function ocHideEmptyCbiElements() {
	var emptyEls = document.querySelectorAll('.cbi-section-table-titles, .cbi-section-table-descr, .cbi-section-descr');
	for (var i = 0; i < emptyEls.length; i++) {
		if (emptyEls[i].textContent.trim() === '') { emptyEls[i].style.display = 'none'; }
	}
}
function ocCenterCbiActions() {
	var ids = ['Commit', 'Apply', 'Create', 'Back', 'Load_Config',
		'Delete_Unused_Servers', 'Delete_Servers', 'Delete_Proxy_Provider', 'Delete_Groups',
		'proxy_mg', 'rule_mg', 'pro_mg'];
	for (var i = 0; i < ids.length; i++) {
		var els = document.querySelectorAll('[id$="-' + ids[i] + '"]');
		for (var j = 0; j < els.length; j++) {
			els[j].style.textAlign = 'center';
		}
	}
}

// ── Hotkeys ─────────────────────────────────────────────────────
// F11 fullscreen, F10 diff toggle, Esc exit, Ctrl+/-/0 zoom, Ctrl+Wheel zoom.
// Registered once globally (capture phase so it beats CM6's own key handling).

function ocRegisterEditorHotkeys() {
	if (window._ocEditorHotkeysBound) return;
	window._ocEditorHotkeysBound = true;

	document.addEventListener('keydown', function(e) {
		if ((e.ctrlKey || e.metaKey) && (e.key === '=' || e.key === '+')) {
			var inst = ocGetActiveEditorInstance();
			if (inst) {
				e.preventDefault();
				var newZoom = ocZoomIn();
				ocApplyZoom(inst, newZoom);
			}
			return;
		}

		if ((e.ctrlKey || e.metaKey) && e.key === '-') {
			var inst = ocGetActiveEditorInstance();
			if (inst) {
				e.preventDefault();
				var newZoom = ocZoomOut();
				ocApplyZoom(inst, newZoom);
			}
			return;
		}

		if ((e.ctrlKey || e.metaKey) && e.key === '0') {
			var inst = ocGetActiveEditorInstance();
			if (inst) {
				e.preventDefault();
				var newZoom = ocResetZoom();
				ocApplyZoom(inst, newZoom);
			}
			return;
		}

		if (e.key === 'F11') {
			e.preventDefault();
			if (window._ocFullscreenActive) {
				var fsEl = document.getElementById('oc-fullscreen-active');
				if (fsEl && typeof CM6 !== 'undefined' && CM6.toggleFullscreen) {
					CM6.toggleFullscreen(fsEl);
				}
				_ocExitFullscreen();
				window._ocFullscreenActive = false;
				if (window.ConfigEditor) window.ConfigEditor.isFullscreen = false;
			} else {
				if (typeof CM6 !== 'undefined' && CM6.getActiveEditor && CM6.toggleFullscreen) {
					var target = CM6.getActiveEditor();
					if (target) {
						_ocEnterFullscreen(target);
						window._ocFullscreenActive = !!CM6.toggleFullscreen(target);
						if (window.ConfigEditor) window.ConfigEditor.isFullscreen = window._ocFullscreenActive;
					}
				}
			}
			ocUpdateTheme();
			return;
		}

		if (e.key === 'F10' && window._mergeViewInstance && window._mergeViewInstance.reconfigure) {
			e.preventDefault();
			window._ocMergeShowDifferences = !window._ocMergeShowDifferences;
			window._mergeViewInstance.reconfigure({
				highlightChanges: window._ocMergeShowDifferences,
				gutter: window._ocMergeShowDifferences
			});
			if (window._mergeViewInstance.dom) {
				window._mergeViewInstance.dom.classList.toggle('oc-diff-hidden', !window._ocMergeShowDifferences);
			}
			return;
		}

		if (e.key === 'Escape' && window._ocFullscreenActive) {
			e.preventDefault();
			e.stopPropagation();
			var fsEl = document.getElementById('oc-fullscreen-active');
			if (fsEl && typeof CM6 !== 'undefined' && CM6.toggleFullscreen) {
				CM6.toggleFullscreen(fsEl);
			}
			_ocExitFullscreen();
			window._ocFullscreenActive = false;
			if (window.ConfigEditor) window.ConfigEditor.isFullscreen = false;
			ocUpdateTheme();
		}
	}, true);

	// Separate listener — wheel needs {passive:false} for preventDefault
	document.addEventListener('wheel', function(e) {
		if (e.ctrlKey || e.metaKey) {
			if (e.target.closest && e.target.closest('#config-editor-overlay')) return;
			var inst = ocGetActiveEditorInstance();
			if (inst) {
				e.preventDefault();
				var newZoom = e.deltaY < 0 ? ocZoomIn() : ocZoomOut();
				ocApplyZoom(inst, newZoom);
			}
		}
	}, { passive: false });
}

ocInitTheme();
