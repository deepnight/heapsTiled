import h2dTiled.TiledMap;
import h2dTiled.com.*;

class Test extends hxd.App {
	// Boot
	static function main() {
		new Test();
	}

	// Engine ready
	override function init() {
		hxd.Res.initEmbed();
		h3d.Engine.getCurrent().backgroundColor = 0x21263f;
		var wrapper = new h2d.Object(s2d);
		wrapper.setScale(2);

		var map = new h2dTiled.TiledMap( hxd.Res.map );

		// Render map
		for(l in map.layers)
			map.renderLayerBitmap(l, wrapper);

		// Render objects
		var g = new h2d.Graphics(wrapper);
		var rc = 0x00ffcc;
		var ec = 0xff00ff;
		var pc = 0xffc200;
		for(o in map.getObjects("markers")) {
			if( o.isRect() ) {
				g.lineStyle(1, rc, 1);
				g.beginFill(rc, 0.3);
				g.drawRect(o.x, o.y, o.wid, o.hei);
			}
			else if( o.isEllipse() ) {
				g.lineStyle(1, ec, 1);
				g.beginFill(ec, 0.3);
				g.drawEllipse(o.centerX, o.centerY, o.wid*0.5, o.hei*0.5);
			}
			else {
				g.lineStyle(1, pc, 1);
				g.beginFill(pc, 0.3);
				g.drawCircle(o.x, o.y, 6);
			}
		}
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
	}
}

