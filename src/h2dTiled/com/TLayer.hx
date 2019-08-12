package h2dTiled.com;

class TLayer {
	public var id : Int;
	public var name : String = "";
	public var wid : Int;
	public var hei : Int;
	var props : Map<String,String> = new Map();
	var tmap : TiledMap;

	var ids : Array<Int> = [];
	var xFlip : Map<Int,Bool> = new Map();
	var yFlip : Map<Int,Bool> = new Map();
	var content : Map<Int,Int> = new Map();

	public function new(tmap:TiledMap, id:Int, w, h) {
		this.tmap = tmap;
		this.id = id;
		wid = w;
		hei = h;
	}

	public inline function isXFlipped(cx:Int, cy:Int) return xFlip.get(cx+cy*wid) == true;
	public inline function isYFlipped(cx:Int, cy:Int) return yFlip.get(cx+cy*wid) == true;

	inline function checkBit(v:UInt, bit:Int) : Bool {
		return v&(1<<bit) != 0;
	}

	inline function clearBit(v:UInt, bit:Int) : UInt {
		return v & ( 0xFFFFFFFF - (1<<bit) );
	}

	public function setIds(a:Array<UInt>) {
		// Check for flip bits
		xFlip = new Map();
		yFlip = new Map();
		for(i in 0...a.length) {
			if( checkBit(a[i], 31) ) {
				xFlip.set(i, true);
				a[i] = clearBit(a[i], 31);
			}
			if( checkBit(a[i],30) ) {
				yFlip.set(i,true);
				a[i] = clearBit(a[i], 30);
			}
		}

		// Store IDs
		ids = a;
		content = new Map();
		var i = 0;
		for(id in ids) {
			if( id>0 )
				content.set(i, id);
			i++;
		}
	}

	public inline function getIds() return ids;

	public function hasTile(cx,cy) return content.exists(cx + cy*wid);
	public function getGlobalTileId(cx,cy) {
		return !hasTile(cx,cy) ? -1 : content.get(cx+cy*wid);
	}
	public function getLocalTileId(cx,cy) {
		if( !hasTile(cx,cy) )
			return -1;
		var id = content.get(cx+cy*wid);
		id -= tmap.getTileSet(id).baseId;
		return id;
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

	public function getPropFloat(name) : Float {
		var v = getPropStr(name);
		return v==null ? 0 : Std.parseFloat(v);
	}

	public function getPropBool(name) : Bool {
		var v = getPropStr(name);
		return v=="true";
	}
}
