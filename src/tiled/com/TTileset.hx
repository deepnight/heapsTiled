package tiled.com;

class TTileset {
	public var name : String;
	public var tile : h2d.Tile;
	public var baseId : Int = 0;
	public var lastId(get,never) : Int; inline function get_lastId() return baseId + cwid*chei - 1;
	public var tileWid : Int;
	public var tileHei : Int;

	public var cwid(get,never) : Int; inline function get_cwid() return Std.int( tile.width / tileWid );
	public var chei(get,never) : Int; inline function get_chei() return Std.int( tile.height / tileHei );

	public function new(n:Null<String>, t:h2d.Tile, tw,th, base) {
		tile = t;
		name = n==null ? "Unnamed" : n;
		baseId = base;
		tileWid = tw;
		tileHei = th;
	}

	public function toString() {
		return 'TTileSet($cwid x $chei):$baseId>$lastId';
	}

	public function getTile(id:Int) : h2d.Tile {
		id-=baseId;
		var cy = Std.int( id/cwid );
		var cx = Std.int( id - cy*cwid );
		return tile.sub(
			cx*tileWid, cy*tileHei,
			tileWid, tileHei
		);
	}
}

