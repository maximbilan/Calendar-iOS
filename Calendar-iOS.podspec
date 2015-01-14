Pod::Spec.new do |s|
  s.name         = "Calendar-iOS"
  s.version      = "0.6"
  s.summary      = "iOS calendar component"
  s.description  = "iOS calendar component. It's lightweight and simple control."
  s.homepage     = "https://github.com/maximbilan/ios_calendar"
  s.license      = { :type => "MIT" }
  s.author             = { "Maxim Bilan" => "maximb.mail@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/maximbilan/ios_calendar.git", :tag => "0.6" }
  s.source_files  = "Classes", "ios_calendar/Sources/**/*.{h,m}"
  s.requires_arc = true
end