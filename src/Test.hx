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

		var map = new h2dTiled.TiledMap( hxd.Res.map );

		var e = new h2d.Object(s2d);
		for(l in map.layers)
			map.renderLayerBitmap(l, e);

		var g = new h2d.Graphics(s2d);
		var c = 0xffc200;
		for(o in map.getObjects("markers")) {
			if( o.isRect() ) {
				g.lineStyle(1, c, 1);
				g.beginFill(c, 0.3);
				g.drawRect(o.x, o.y, o.wid, o.hei);
			}
			else {
				g.lineStyle(1, c, 1);
				g.beginFill(c, 0.3);
				g.drawCircle(o.x, o.y, 6);
			}
		}
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
	}
}

