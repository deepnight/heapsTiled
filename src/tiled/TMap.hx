package tiled;

import tiled.com.*;

@:allow(tiled.com.TObject)
@:allow(tiled.com.TLayer)
class TiledMap {
	public var wid : Int;
	public var hei : Int;
	public var tileWid : Int;
	public var tileHei : Int;

	public var tilesets : Array<TTileset> = [];
	public var layers : Array<TLayer> = [];
	public var objects : Map<String, Array<TObject>> = new Map();
	var props : Map<String,String> = new Map();

	public var bgColor : Null<UInt>;

	private function htmlHexToInt(s:String) : Null<UInt> {
		if( s.indexOf("#") == 0 )
			return Std.parseInt("0x" + s.substring(1));

		return null;
	}

	public function new(tmxRes:hxd.res.Resource) {
		var folder = tmxRes.entry.directory;
		var xml = new haxe.xml.Access( Xml.parse(tmxRes.entry.getText()) );
		xml = xml.node.map;

		wid = Std.parseInt( xml.att.width );
		hei = Std.parseInt( xml.att.height );
		tileWid = Std.parseInt( xml.att.tilewidth );
		tileHei = Std.parseInt( xml.att.tileheight );
		bgColor = xml.has.backgroundcolor ? htmlHexToInt(xml.att.backgroundcolor) : null;

		// Parse tilesets
		for(t in xml.nodes.tileset) {
			var set = readTileset(folder, t.att.source, Std.parseInt( t.att.firstgid ));
			tilesets.push(set);
		}

		// Parse layers
		for(l in xml.nodes.layer) {
			var layer = new TLayer( this, Std.string(l.att.name), Std.parseInt(l.att.id), Std.parseInt(l.att.width), Std.parseInt(l.att.height) );
			layers.push(layer);

			// Properties
			if( l.hasNode.properties )
				for(p in l.node.properties.nodes.property)
					layer.setProp(p.att.name, p.att.value);

			// Tile IDs
			var data = l.node.data;
			switch( data.att.encoding ) {
				case "csv" :
					layer.setIds( data.innerHTML.split(",").map( function(id:String) : UInt {
						var f = Std.parseFloat(id);
						if( f > 2147483648. ) // dirty fix for Float>UInt casting issue when "bit #32" is set
							return ( cast (f-2147483648.) : UInt ) | (1<<31);
						else
							return ( cast f : UInt );
					}) );

				case _ : throw "Unsupported layer encoding "+data.att.encoding+" in "+tmxRes.entry.path;
			}
		}

		// Parse objects
		for(ol in xml.nodes.objectgroup) {
			objects.set(ol.att.name, []);
			for(o in ol.nodes.object) {
				var e = new TObject(this, Std.parseInt(o.att.x), Std.parseInt(o.att.y));
				if( o.has.width ) e.wid = Std.parseInt( o.att.width );
				if( o.has.height ) e.hei = Std.parseInt( o.att.height );
				if( o.has.name ) e.name = o.att.name;
				if( o.has.type ) e.type = o.att.type;
				if( o.has.gid ) {
					e.tileId = Std.parseInt( o.att.gid );
					e.y-=e.hei; // fix stupid bottom-left based coordinate
				}
				else if( o.hasNode.ellipse ) {
					e.ellipse = true;
					if( e.wid==0 ) {
						// Fix 0-sized ellipses
						e.x-=tileWid>>1;
						e.y-=tileHei>>1;
						e.wid = tileWid;
						e.hei = tileHei;
					}
				}

				// Properties
				if( o.hasNode.properties )
					for(p in o.node.properties.nodes.property)
						e.setProp(p.att.name, p.att.value);
				objects.get(ol.att.name).push(e);
			}
		}

		// Parse map properties
		if (xml.hasNode.properties) {
			for (p in xml.node.properties.nodes.property)
				setProp(p.att.name, p.att.value);
		}
	}

	public function getLayer(name:String) : Null<TLayer> {
		for (l in layers)
			if (l.name == name)
				return l;

		return null;
	}

	public function getObject(layer:String, name:String) : Null<TObject> {
		if( !objects.exists(layer) )
			return null;

		for(o in objects.get(layer))
			if( o.name==name )
				return o;

		return null;
	}


	public function getObjects(layer:String, ?type:String) : Array<TObject> {
		if( !objects.exists(layer) )
			return [];

		return type==null ? objects.get(layer) : objects.get(layer).filter( function(o) return o.type==type );
	}

	public function getPointObjects(layer:String, ?type:String) : Array<TObject> {
		if( !objects.exists(layer) )
			return [];

		return objects.get(layer).filter( function(o) return o.isPoint() && ( type==null || o.type==type ) );
	}

	public function getRectObjects(layer:String, ?type:String) : Array<TObject> {
		if( !objects.exists(layer) )
			return [];

		return objects.get(layer).filter( function(o) return o.isRect() && ( type==null || o.type==type ) );
	}


	public function renderLayerBitmap(l:TLayer, ?p) : h2d.Object {
		var wrapper = new h2d.Object(p);
		var cx = 0;
		var cy = 0;
		for(id in l.getIds()) {
			if( id!=0 ) {
				var b = new h2d.Bitmap(getTile(id), wrapper);
				b.setPosition(cx*tileWid, cy*tileHei);
				if( l.isXFlipped(cx,cy) ) {
					b.scaleX = -1;
					b.x+=tileWid;
				}
				if( l.isYFlipped(cx,cy) ) {
					b.scaleY = -1;
					b.y+=tileHei;
				}
			}

			cx++;
			if( cx>=wid ) {
				cx = 0;
				cy++;
			}
		}
		return wrapper;
	}


	public function getTiles(l:TLayer) : Array<{ t:h2d.Tile, x:Int, y:Int }> {
		var out = [];
		var cx = 0;
		var cy = 0;
		for(id in l.getIds()) {
			if( id!=0 )
				out.push({
					t : getTile(id),
					x : cx*tileWid,
					y : cy*tileHei,
				});

			cx++;
			if( cx>=wid ) {
				cx = 0;
				cy++;
			}
		}
		return out;
	}

	function getTileSet(tileId:Int) : Null<TTileset> {
		for(set in tilesets)
			if( tileId>=set.baseId && tileId<=set.lastId )
				return set;
		return null;
	}

	inline function getTile(tileId:Int) : Null<h2d.Tile> {
		var s = getTileSet(tileId);
		return s!=null ? s.getTile(tileId) : null;
	}

	function readTileset(folder:String, file:String, baseIdx:Int) : TTileset {
		if( folder.length>0 )
			folder+="/";
		var raw = try hxd.Res.load(folder+file).entry.getText()
			catch(e:Dynamic) throw "File not found "+file;

		var xml = new haxe.xml.Access( Xml.parse(raw) ).node.tileset;
		var tile = hxd.Res.load(folder+xml.node.image.att.source).toTile();

		var e = new TTileset(xml.att.name, tile, Std.parseInt(xml.att.tilewidth), Std.parseInt(xml.att.tileheight), baseIdx);
		return e;
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
