package h2dTiled.com;

class TObject {
	var tmap : TiledMap;
	public var name : Null<String>;
	public var type : Null<String>;
	public var x : Int;
	public var y : Int;
	public var wid = 0;
	public var hei = 0;
	public var cwid(get,never) : Int; inline function get_cwid() return Std.int(wid/tmap.tileWid);
	public var chei(get,never) : Int; inline function get_chei() return Std.int(hei/tmap.tileHei);

	public var cx(get,never) : Int; inline function get_cx() return Std.int(x/tmap.tileWid);
	public var cy(get,never) : Int; inline function get_cy() return Std.int(y/tmap.tileHei);

	public var xr(get,never) : Float; inline function get_xr() return (x-cx*tmap.tileWid) / tmap.tileWid;
	public var yr(get,never) : Float; inline function get_yr() return (y-cy*tmap.tileHei) / tmap.tileHei;

	public function new(m:TiledMap, x:Int, y:Int, ?w=0, ?h=0) {
		tmap = m;
		this.x = x;
		this.y = y;
		wid = w;
		hei = h;
	}

	public function toString() {
		return "TODO";
		// return 'Obj:$name($type)@$cx,$cy' + (wid>0 ? ' / $wid x $hei' : "");
	}

	public inline function isRect() return wid>0 && hei>0;
	public inline function isPoint() return wid<=0 && hei<=0;
}
