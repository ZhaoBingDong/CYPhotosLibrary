
Pod::Spec.new do |s|

s.name                 = "CYPhotosKit"
s.version              = '2.2.0'
s.summary              = '一款不错的相册照片选择器'
s.homepage    	       = 'https://github.com/ZhaoBingDong/CYPhotosLibrary'
s.license              = { :type => 'MIT', :file => 'LICENSE' }
s.author               = { "ZhaoBingDong" => "dongzhaobing@bayekeji.com" }
s.source     	       = { :git => 'https://github.com/ZhaoBingDong/CYPhotosLibrary.git', :tag => "2.2.0" }
s.source_files         = 'CYPhotoKit/**/*{.h,.m,.xib}'
s.ios.deployment_target = '8.0'
s.resources    = 'CYPhotoKit/**/*.{bundle}'

end
