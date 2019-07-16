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
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
	}
}

