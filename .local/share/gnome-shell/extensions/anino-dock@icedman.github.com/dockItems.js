'use strict';

const { St, Shell, GObject, Gio, GLib, Gtk, Meta, Clutter } = imports.gi;
const Main = imports.ui.main;
const Dash = imports.ui.dash.Dash;
const Point = imports.gi.Graphene.Point;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const DrawOverlay = Me.imports.apps.overlay.DrawOverlay;
const Drawing = Me.imports.drawing.Drawing;

const Dot = Me.imports.decor.Dot;

const DOT_CANVAS_SIZE = 96;

var DockIcon = GObject.registerClass(
  {},
  class AninoDockIcon extends St.Widget {
    _init() {
      super._init({ name: 'DockIcon', reactive: false });

      let pivot = new Point();
      pivot.x = 0.5;
      pivot.y = 0.5;
      this.pivot_point = pivot;
    }

    update(params) {
      let should_hide = false;
      let gicon = null;
      let icon_gfx = params.icon?.icon_name;
      if (params.icon?.gicon) {
        let name = params.icon.gicon.name;
        if (!name && params.icon.gicon.names) {
          name = params.icon.gicon.names[0];
        }
        if (!name) {
          // hijack
          gicon = params.icon.gicon;
          icon_gfx = params.app;
        }
        if (name) {
          icon_gfx = name;
        }
      }

      // log(`--${icon_gfx}`);

      if (this._icon && this._gfx != icon_gfx) {
        this._gfx = icon_gfx;
        this.remove_child(this._icon);
        this._icon = null;
      }
      if (!this._icon && icon_gfx) {
        if (!gicon) {
          gicon = new Gio.ThemedIcon({ name: icon_gfx });
        }
        this._icon = new St.Icon({
          gicon,
        });

        // remove overlay added by services
        if (this.first_child) {
          this.remove_child(this.first_child);
        }

        this.add_child(this._icon);
      }
      this.visible = true;
      if (this.last_child) {
        should_hide = this.last_child._hide;
      }
      this._icon.opacity = should_hide ? 0 : 255;
    }
  }
);

var IconsContainer = GObject.registerClass(
  {},
  class AninoIconsContainer extends St.Widget {
    _init(params) {
      super._init({
        name: 'IconsContainer',
        ...(params || {}),
      });
      this._icons = [];
    }

    _precreate_icons(length) {
      while (this._icons.length < length) {
        let icon = new DockIcon();
        this._icons.push(icon);
        this.add_child(icon);
      }
      this._icons.forEach((icon) => {
        icon.visible = false;
      });

      return this._icons;
    }

    clear() {
      this._icons.forEach((i) => {
        this.remove_child(i);
      });
      this._icons = [];
    }

    update(params) {
      let { icons, pivot, iconSize, quality, scaleFactor } = params;
      if (!icons) {
        icons = [];
      }
      this._precreate_icons(icons.length);
      let idx = 0;

      icons.forEach((container) => {
        const { _appwell, _bin, _label, _showApps } = container;

        let _icon = this._icons[idx++];
        _icon.update({
          icon: container._icon,
          app: _appwell?.app?.get_id(),
        });

        // this is the graphics, used by maybeBounce
        container._renderedIcon = _icon;

        _icon._appwell = _appwell;
        _icon._showApps = _showApps;
        _icon._bin = _bin;
        _icon._label = _label;
        _icon._img = _icon._icon;
        _icon._container = container;

        if (_icon._img) {
          _icon._img.set_size(iconSize * quality, iconSize * quality);
          _icon._img.set_scale(1 / quality, 1 / quality);
        }

        _icon.set_size(iconSize, iconSize);
        _icon.pivot_point = pivot;
      });
    }

    // move animation here!
    animate() {}
  }
);

var DotsContainer = GObject.registerClass(
  {},
  class AninoDotsContainer extends St.Widget {
    _init(params) {
      super._init({
        name: 'DotsContainer',
        ...(params || {}),
      });
      this._dots = [];
    }

    _precreate_dots(params) {
      const { count, show } = params;
      if (show) {
        for (let i = 0; i < count - this._dots.length; i++) {
          let dot = new Dot(DOT_CANVAS_SIZE);
          let pdot = new St.Widget();
          pdot.add_child(dot);
          this._dots.push(dot);
          this.add_child(pdot);
          dot.set_position(0, 0);
        }
      }
      this._dots.forEach((d) => {
        d.get_parent().width = 1;
        d.get_parent().height = 1;
        d.set_scale(1, 1);
        d.visible = false;
      });
      return this._dots;
    }

    update(params) {
      let {
        icons,
        iconSize,
        vertical,
        position,
        scaleFactor,
        pivot,
        dotsCount,
        running_indicator_color,
        running_indicator_style_options,
        running_indicator_style,
        appNotices,
        notification_badge_color,
        notification_badge_style_options,
        notification_badge_style,
        separators,
      } = params;

      this._precreate_dots({
        count: dotsCount + icons.length + separators.length,
        show: true, // showDots || showBadges,
      });

      let dotIndex = 0;
      icons.forEach((icon) => {
        icon._container.style = '';

        let pos = [...icon._pos];
        let scale = icon._scale;

        if (isNaN(pos[0]) || isNaN(pos[1])) {
          return;
        }

        // update the notification badge
        // todo ... move dots and badges to service?

        let has_badge = false;
        if (
          icon._appwell &&
          icon._appwell.app &&
          appNotices &&
          appNotices[icon._appwell.app.get_id()] &&
          appNotices[icon._appwell.app.get_id()].count > 0
        ) {
          // log(icon._appwell?.app.get_id());

          icon._badge = this._dots[dotIndex++];
          let count = appNotices[icon._appwell.app.get_id()].count;

          let badgeParent = icon._badge.get_parent();
          badgeParent.set_position(
            pos[0] + 4 * scaleFactor,
            pos[1] - 4 * scaleFactor
          );
          badgeParent.width = iconSize;
          badgeParent.height = iconSize;
          badgeParent.pivot_point = pivot;
          badgeParent.set_scale(scale, scale);

          let style =
            notification_badge_style_options[notification_badge_style];

          icon._badge.visible = true;
          icon._badge.set_state({
            count: count,
            color: notification_badge_color || [1, 1, 1, 1],
            rotate: 180,
            translate: [0.4, 0],
            style: style || 'default',
          });

          icon._badge.set_scale(
            (iconSize * scaleFactor) / DOT_CANVAS_SIZE,
            (iconSize * scaleFactor) / DOT_CANVAS_SIZE
          );
          has_badge = true;
        }

        if (icon._badge && !has_badge) {
          icon._badge.visible = false;
        }

        // update the dot
        if (icon._appwell && icon._appwell.app.get_n_windows() > 0) {
          let dot = this._dots[dotIndex++];
          icon._dot = dot;
          if (dot) {
            let dotParent = dot.get_parent();
            dot.visible = true;
            dotParent.width = iconSize;
            dotParent.height = iconSize;
            dotParent.set_scale(1, 1);

            if (vertical) {
              if (position == 'right') {
                dotParent.set_position(pos[0] + 8 * scaleFactor, pos[1]);
              } else {
                dotParent.set_position(pos[0] - 8 * scaleFactor, pos[1]);
              }
            } else {
              dotParent.set_position(pos[0], pos[1] + 8 * scaleFactor);
            }
            dot.set_scale(
              (iconSize * scaleFactor) / DOT_CANVAS_SIZE,
              (iconSize * scaleFactor) / DOT_CANVAS_SIZE
            );

            let style =
              running_indicator_style_options[running_indicator_style];

            dot.set_state({
              count: icon._appwell.app.get_n_windows(),
              color: running_indicator_color || [1, 1, 1, 1],
              style: style || 'default',
              rotate: vertical ? (position == 'right' ? -90 : 90) : 0,
            });
          }
        }
      });

      let separator_pad = 8;
      separators.forEach((s) => {
        let icon = icons[s.index];
        if (!icon) return;
        let pos = [...icon._pos];
        let dot = this._dots[dotIndex++];
        if (dot) {
          let dotParent = dot.get_parent();
          dot.visible = true;
          dotParent.width = iconSize;
          dotParent.height = iconSize;
          dotParent.set_scale(1, 1);

          if (vertical) {
            dotParent.set_position(
              pos[0],
              pos[1] -
                (separator_pad + icon._container.height / 2) * scaleFactor
            );
          } else {
            dotParent.set_position(
              pos[0] -
                (separator_pad + icon._container.width / 2) * scaleFactor,
              pos[1]
            );
          }

          icon._container.style = `margin-left: ${separator_pad * 2}px;`;

          dot.set_scale(
            (iconSize * scaleFactor) / DOT_CANVAS_SIZE,
            (iconSize * scaleFactor) / DOT_CANVAS_SIZE
          );

          // let style = running_indicator_style_options[running_indicator_style];

          dot.set_state({
            count: 1,
            color: [1, 1, 1, 0.2],
            style: 'separator',
            rotate: vertical ? (position == 'right' ? -90 : 90) : 0,
          });
        }
      });
    }
  }
);

var DockExtension = GObject.registerClass(
  {},
  class AninoDockExtension extends St.Widget {
    _init(params) {
      super._init({
        reactive: true,
        ...params,
      });

      this.listeners = [];
      this.connectObject(
        'button-press-event',
        this._onButtonEvent.bind(this),
        'motion-event',
        this._onMotionEvent.bind(this),
        'leave-event',
        this._onLeaveEvent.bind(this),
        this
      );
    }

    vfunc_scroll_event(scrollEvent) {
      this._onScrollEvent({}, scrollEvent);
      return Clutter.EVENT_PROPAGATE;
    }

    _onScrollEvent(obj, evt) {
      this.listeners
        .filter((l) => {
          return l._enabled;
        })
        .forEach((l) => {
          if (l._onScrollEvent) l._onScrollEvent(obj, evt);
        });
    }

    _onButtonEvent(obj, evt) {
      this.listeners
        .filter((l) => {
          return l._enabled;
        })
        .forEach((l) => {
          if (l._onButtonEvent) l._onButtonEvent(obj, evt);
        });
    }

    _onMotionEvent() {
      this.listeners
        .filter((l) => {
          return l._enabled;
        })
        .forEach((l) => {
          if (l._onMotionEvent) l._onMotionEvent();
        });
    }

    _onLeaveEvent() {
      this.listeners
        .filter((l) => {
          return l._enabled;
        })
        .forEach((l) => {
          if (l._onLeaveEvent) l._onLeaveEvent();
        });
    }
  }
);

var DockOverlay = GObject.registerClass(
  {},
  class AninoDockOverlay extends St.Widget {
    _init(params) {
      super._init({
        name: 'DockOverlay',
        ...(params || {}),
      });
    }

    update(params) {
      let {
        background,
        left,
        right,
        center,
        panel_mode,
        vertical,
        dashContainer,
        combine_top_bar,
      } = params;

      if (!combine_top_bar || !panel_mode || vertical) {
        if (this.visible) {
          dashContainer.restorePanel();
        }
        this.visible = false;
        return;
      }

      this.visible = true;
      dashContainer.panel.visible = false;

      // this.style = 'border: 2px solid red;';
      this.x = background.x;
      this.y = background.y;
      this.width = background.width;
      this.height = background.height;

      let margin = 20;

      // left
      if (left.get_parent() != this) {
        left.get_parent().remove_child(left);
        this.add_child(left);
      }
      left.x = margin;
      left.y = this.height / 2 - left.height / 2;

      // center
      if (center.get_parent() != this) {
        center.get_parent().remove_child(center);
        this.add_child(center);
      }
      center.x = this.width - margin / 2 - center.width;
      center.y = this.height / 2 - center.height / 2;

      // right
      if (right.get_parent() != this) {
        right.get_parent().remove_child(right);
        this.add_child(right);
      }
      right.height = center.height;
      right.x = this.width - margin - right.width;
      right.y = this.height / 2 - right.height / 2;

      // align
      if (center.height * 3 < this.height) {
        right.y -= right.height / 1.5;
        center.y += center.height / 1.5;
      } else {
        right.x -= center.width;
      }
    }
  }
);
