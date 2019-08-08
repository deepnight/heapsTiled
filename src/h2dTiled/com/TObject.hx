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
	public var ellipse = false;

	public var centerX(get,never) : Int; inline function get_centerX() return Std.int(x+wid*0.5);
	public var centerY(get,never) : Int; inline function get_centerY() return Std.int(y+hei*0.5);

	public var cx(get,never) : Int; inline function get_cx() return Std.int(x/tmap.tileWid);
	public var cy(get,never) : Int; inline function get_cy() return Std.int(y/tmap.tileHei);

	public var xr(get,never) : Float; inline function get_xr() return (x-cx*tmap.tileWid) / tmap.tileWid;
	public var yr(get,never) : Float; inline function get_yr() return (y-cy*tmap.tileHei) / tmap.tileHei;

	public var tileId : Null<Int>;
	var props : Map<String,String> = new Map();

	public function new(m:TiledMap, x:Int, y:Int, ?w=0, ?h=0) {
		tmap = m;
		this.x = x;
		this.y = y;
		wid = w;
		hei = h;
	}

	public function toString() {
		return 'Obj:$name($type)@$cx,$cy' + (wid>0 ? ' / $wid x $hei' : "");
	}

	public inline function isPoint() return !isTile() && wid<=0 && hei<=0;
	public inline function isRect() return !isTile() && wid>0 && hei>0 && !ellipse;
	public inline function isEllipse() return !isTile() && wid>0 && hei>0 && ellipse;
	public inline function isTile() return tileId!=null;

	public inline function rectContains(xx:Float, yy:Float) {
		return isRect() && xx>=x && xx<x+wid && yy>=y && yy<y+hei;
	}

	public function getLocalTileId() {
		var l = tmap.getTileSet(tileId);
		if( l!=null )
			return tileId-l.baseId;
		else
			return tileId;
	}

	public function getTile() : Null<h2d.Tile> {
		if( !isTile() )
			return null;
		var l = tmap.getTileSet(tileId);
		if( l==null )
			return null;
		return l.getTile(tileId);
	}



	public function setProp(name, v) {
		props.set(name, v);
	}

	public inline function hasProp(name) {
		return props.exists(name);
	}

	public function getPropStr(name) : Null<String> {
		return props.get(name);
	}

	public function getPropInt(name) : Int {
		var v = getPropStr(name);
		return v==null ? 0 : Std.parseInt(v);
	}

	public function getPropBool(name) : Bool {
		var v = getPropStr(name);
		return v=="true";
	}
}
