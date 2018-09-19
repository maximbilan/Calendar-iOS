Pod::Spec.new do |s|
  s.name         = "Calendar-iOS"
  s.version      = "0.13"
  s.summary      = "A calendar view"
  s.description  = "A lightweight and simple iOS calendar component."
  s.homepage     = "https://github.com/maximbilan/Calendar-iOS"
  s.license      = { :type => "MIT" }
  s.author       = { "Maxim Bilan" => "maximb.mail@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/maximbilan/Calendar-iOS.git", :tag => s.version.to_s }
  s.source_files = "Classes", "ios_calendar/Sources/**/*.{h,m}"
  s.requires_arc = true
end
