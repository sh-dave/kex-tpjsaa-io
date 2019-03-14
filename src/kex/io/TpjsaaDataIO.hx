package kex.io;

import format.tpjsaa.Atlas in AtlasData;

using tink.CoreApi;

class TpjsaaDataIO extends GenericIO<AtlasData> {
	var blobs: BlobIO;

	public function new( blobs: BlobIO ) {
		super('tpjsaa-data');
		this.blobs = blobs;
	}

	override function onResolve( scope: String, path: String, file: String ) : Promise<AtlasData> {
        return blobs.get(scope, path, file)
            .next(function( blob ) {
                var data: AtlasData = tink.Json.parse(blob.toString());
                return data;
            });
	}
}
