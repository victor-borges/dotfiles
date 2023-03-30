// adapted from gnome-shell-cairo clock extension

const { Clutter, GObject, GLib, PangoCairo, Pango } = imports.gi;
const Cairo = imports.cairo;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Drawing = Me.imports.drawing.Drawing;

let size = 400;

function _drawFrame(ctx, size, settings) {
  if (!settings.frame) {
    return;
  }
  let { background, border, borderWidth } = settings.frame;
  let radius = 18;

  ctx.save();
  let bgSize = size * settings.frame.size;
  // frame background
  Drawing.draw_rounded_rect(
    ctx,
    background,
    -bgSize / 2,
    -bgSize / 2,
    bgSize,
    bgSize,
    0,
    radius
  );
  // frame border
  if (borderWidth) {
    Drawing.draw_rounded_rect(
      ctx,
      border,
      -bgSize / 2,
      -bgSize / 2,
      bgSize,
      bgSize,
      borderWidth,
      radius
    );
  }
  ctx.restore();
}

function _drawDial(ctx, size, settings) {
  if (!settings.dial) {
    return;
  }
  let { background, border, borderWidth } = settings.dial;

  ctx.save();
  let bgSize = size * settings.dial.size;
  // dial background
  Drawing.draw_circle(ctx, background, 0, 0, bgSize);
  // dial border
  if (borderWidth) {
    Drawing.draw_circle(ctx, border, 0, 0, bgSize, borderWidth);
  }
  ctx.restore();
}

function _drawMarks(ctx, size, settings) {
  if (!settings.marks) {
    return;
  }
  let { color, width } = settings.marks;

  ctx.save();
  for (let i = 0; i < 12; i++) {
    let a = (360 / 12) * i;
    let mark = size * 0.75;
    Drawing.draw_rotated_line(
      ctx,
      color,
      width,
      // size / 33,
      a * (Math.PI / 180),
      -Math.floor((size * 0.9) / 2.7),
      -Math.floor(mark / 2.7)
    );
  }
  ctx.restore();
}

function _drawHands(ctx, size, date, settings) {
  const { hour, minute, second } = settings.hands;
  const d0 = date;
  let h0 = d0.getHours();
  const m0 = d0.getMinutes();

  // hands
  Drawing.draw_rotated_line(
    ctx,
    minute,
    size / 20,
    (h0 * 30 + (m0 * 30) / 60) * (Math.PI / 180),
    -Math.floor(size / 3.7)
  );
  Drawing.draw_circle(ctx, minute, 0, 0, size / 12);
  Drawing.draw_rotated_line(
    ctx,
    hour,
    size / 33,
    m0 * 6 * (Math.PI / 180),
    -Math.floor(size / 2.7)
  );
}

function _drawClock(ctx, date, x, y, size, settings) {
  ctx.save();
  ctx.translate(x, y);
  ctx.moveTo(0, 0);

  _drawFrame(ctx, size, settings);
  _drawDial(ctx, size, settings);
  _drawMarks(ctx, size, settings);
  _drawHands(ctx, size, date, settings);

  ctx.restore();
}

var Clock = GObject.registerClass(
  {},
  // todo St.DrawingArea
  class AninoClock extends Clutter.Actor {
    _init(x) {
      super._init();

      if (x) size = x;

      this.settings = {
        dark_color: [0.2, 0.2, 0.2, 1.0],
        light_color: [1.0, 1.0, 1.0, 1.0],
        accent_color: [1.0, 0.0, 0.0, 1.0],
      };

      this._canvas = new Clutter.Canvas();
      this._canvas.connect('draw', this.on_draw.bind(this));
      this._canvas.invalidate();
      this._canvas.set_size(size, size);
      this.set_size(size, size);
      this.set_content(this._canvas);
      this.reactive = false;
    }

    redraw() {
      this._canvas.invalidate();
    }

    on_draw(canvas, ctx, width, height) {
      ctx.setOperator(Cairo.Operator.CLEAR);
      ctx.paint();

      ctx.translate(size / 2, size / 2);
      ctx.setLineWidth(1);
      ctx.setLineCap(Cairo.LineCap.ROUND);
      ctx.setOperator(Cairo.Operator.SOURCE);

      const {
        dark_color,
        light_color,
        accent_color,
        dark_foreground,
        light_foreground,
      } = this.settings;

      this._hide = false;

      // do not change ... affects styles 0, 1
      let style = {
        hands: {
          hour: accent_color,
          minute: light_color,
        },
        marks: {
          color: [0.5, 0.5, 0.5, 1],
          width: 0,
        },
        dial: {
          size: 0.84,
          background: dark_color,
          border: [0.85, 0.85, 0.85, 1],
          borderWidth: 0,
        },
        frame: {
          size: 0.9,
          background: [0.5, 0.5, 0.5, 1],
          border: [0.25, 0.25, 0.25, 1],
          borderWidth: 0,
        },
      };

      switch (this.settings.clock_style) {
        // framed clocks
        case 9: {
          style.dial.size = 0.92;
          style.dial.background = light_color;
          style.hands.minute = dark_color;
          style.frame.background = light_foreground;
          style.marks.color = light_foreground;
          style.marks.width = 2;
          break;
        }
        case 8: {
          style.dial.size = 0.92;
          style.frame.background = dark_foreground;
          style.marks.color = dark_foreground;
          style.marks.width = 2;
          break;
        }
        case 7: {
          style.dial.size = 0.92;
          style.dial.background = light_color;
          style.hands.minute = dark_color;
          style.frame.background = light_foreground;
          style = {
            ...style,
            marks: null,
          };
          break;
        }
        case 6: {
          style.dial.size = 0.92;
          style.frame.background = dark_foreground;
          style.marks.color = dark_foreground;
          style.marks.width = 2;
          style = {
            ...style,
            marks: null,
          };
          break;
        }

        // round clocks
        case 5: {
          style.dial.size = 0.95;
          style.dial.border = dark_color;
          style.dial.borderWidth = 3;
          style.dial.background = light_color;
          style.hands.minute = dark_color;
          style.marks.color = light_foreground;
          style.marks.width = 2;
          style = {
            ...style,
            frame: null,
          };
          this._hide = true;
          break;
        }
        case 4: {
          style.dial.size = 0.95;
          style.dial.border = light_color;
          style.dial.borderWidth = 3;
          style.dial.background = dark_color;
          style.marks.color = dark_foreground;
          style.marks.width = 2;
          style = {
            ...style,
            frame: null,
          };
          this._hide = true;
          break;
        }

        case 3: {
          style.dial.size = 0.95;
          style.dial.border = dark_color;
          style.dial.borderWidth = 3;
          style.dial.background = light_color;
          style.hands.minute = dark_color;
          style = {
            ...style,
            marks: null,
            frame: null,
          };
          if (_icon) {
            _icon._hide = true;
          }
          break;
        }
        case 2: {
          style.dial.size = 0.95;
          style.dial.border = light_color;
          style.dial.borderWidth = 3;
          style.dial.background = dark_color;
          style = {
            ...style,
            marks: null,
            frame: null,
          };
          if (_icon) {
            _icon._hide = true;
          }
          break;
        }

        // basic clocks
        case 1: {
          style.dial.background = light_color;
          style.hands.minute = dark_color;
          style = {
            ...style,
            marks: null,
            frame: null,
          };
          break;
        }
        default:
        case 0:
          style = {
            ...style,
            marks: null,
            frame: null,
          };
          break;
      }

      _drawClock(ctx, new Date(), 0, 0, size, style);

      ctx.$dispose();
    }

    destroy() {}
  }
);
