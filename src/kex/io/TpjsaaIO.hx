package kex.io;

import format.tpjsaa.Atlas in AtlasData;
import haxe.io.Path;

using tink.CoreApi;

class TpjsaaIO extends GenericIO<TextureAtlas> {
	var data: TpjsaaDataIO;
    var images: ImageIO;

	public function new( blobs: BlobIO, images: ImageIO ) {
		super('tpjsaa-atlas');
		this.data = new TpjsaaDataIO(blobs);
        this.images = images;
	}

	override function onResolve( url: String, ?opts: { ?scope: String } ) : Promise<TextureAtlas> {
		return data.get(url, opts)
			.next(function( data ) {
				// var url = CoreIOUtils.genUrl(path, file);
				var imageUrl = Path.join([Path.directory(url), data.meta.image]);
				unloaders.set(url, function() { images.unloadImage(CoreIOUtils.field(opts, 'scope', '*'), imageUrl); });
				return data && images.get(imageUrl, opts);
			})
			.next(createAtlas);
	}

	function createAtlas( d: Pair<AtlasData, kha.Image> ) : TextureAtlas {
		var data = d.a;
		var img = d.b;

		final mappings = [
			for (frame in data.frames)
				frame.filename => ({
					image: img,
					sx: frame.frame.x,
					sy: frame.frame.y,
					sw: frame.frame.w,
					sh: frame.frame.h,
					fx: frame.spriteSourceSize.x,
					fy: frame.spriteSourceSize.y,
					fw: frame.spriteSourceSize.w,
					fh: frame.spriteSourceSize.h,
				} : SubTexture)
		];

		return mappings;
	}
}
