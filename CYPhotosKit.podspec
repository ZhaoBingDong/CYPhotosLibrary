
Pod::Spec.new do |s|
s.name                = "CYPhotosKit"
s.version             = '1.0.1'
s.summary             = '一款不错的相册照片选择器'
s.homepage    	      = 'https://github.com/ZhaoBingDong/CYPhotosLibrary'
s.license              = { :type => 'MIT', :file => 'LICENSE' }
s.author               = { "ZhaoBingDong" => "dongzhaobing@bayekeji.com" }
s.source     	      = { :git => 'https://github.com/ZhaoBingDong/CYPhotosLibrary.git', :tag => "1.0.1" }
s.source_files        = 'CYPhotoKit/**/*.{h,m}'
s.requires_arc.       = true
s.resources          = 'CYPhotoKit/**/*.{bundle,xib}'

end
