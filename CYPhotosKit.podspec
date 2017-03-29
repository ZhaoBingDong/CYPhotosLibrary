
Pod::Spec.new do |s|
s.name                = "CYPhotosKit"
s.version             = "1.5"
s.summary             = "一款不错的相册照片选择器"
s.homepage    	      = "https://github.com/ZhaoBingDong/CYPhotosLibrary"
s.license = { :type => 'MIT', :text => <<-LICENSE
Copyright 2012
Permission is granted to...
LICENSE
}
s.author              = { "ZhaoBingDong" => "dongzhaobing@bayekeji.com" }
s.platform            = :ios, "8.0"
s.source     	      = { :git => 'https://github.com/ZhaoBingDong/CYPhotosLibrary.git', :tag => '1.5' }
s.source_files        = 'CYPhotoKit/**/*.{h,m}'
s.requires_arc.       = true
#s.resources          = 'CYPhotoKit/**/*.{bundle,xib}'

end
