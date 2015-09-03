#
# Be sure to run `pod lib lint DropdownMenu.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DropdownMenu"
  s.version          = "0.1.0"
  s.summary          = "Dropdown Menu"
  s.homepage         = "https://github.com/efremidze/DropdownMenu"
  s.license          = 'MIT'
  s.author           = { "Lasha Efremidze" => "efremidzel@hotmail.com" }
  s.source           = { :git => "https://github.com/efremidze/DropdownMenu.git", :tag => s.version.to_s }
  s.social_media_url = 'http://linkedin.com/in/efremidze'
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'DropdownMenu/*.swift'
end
