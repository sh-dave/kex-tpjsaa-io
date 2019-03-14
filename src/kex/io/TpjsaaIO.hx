package kex.io;

import format.tpjsaa.Atlas in AtlasData;

using tink.CoreApi;

class TpjsaaIO extends GenericIO<TextureAtlas> {
	var data: TpjsaaDataIO;
    var images: ImageIO;

	public function new( blobs: BlobIO, images: ImageIO ) {
		super('tpjsaa-atlas');
		this.data = new TpjsaaDataIO(blobs);
        this.images = images;
	}

	override function onResolve( scope: String, path: String, file: String ) : Promise<TextureAtlas> {
		return data.get(scope, path, file)
			.next(function( data ) {
				var url = CoreIOUtils.genUrl(path, file);
				var imageUrl = CoreIOUtils.genUrl(path, data.meta.image);
				unloaders.set(url, function() { images.unloadImage(scope, imageUrl); });
				return data && images.get(scope, path, data.meta.image);
			})
			.next(createAtlas);
	}

	function createAtlas( d: Pair<AtlasData, kha.Image> ) : TextureAtlas {
		var atlas = new TextureAtlas();
		var data = d.a;
		var img = d.b;

		for (frame in data.frames) {
			atlas.set(frame.filename, {
				image: img,
				sx: frame.frame.x,
				sy: frame.frame.y,
				sw: frame.frame.w,
				sh: frame.frame.h,
				fx: frame.spriteSourceSize.x,
				fy: frame.spriteSourceSize.y,
				fw: frame.spriteSourceSize.w,
				fh: frame.spriteSourceSize.h,
			});
		}

		return atlas;
	}
}
