Pod::Spec.new do |s|

  s.name          = "iDroidLayout2"
  s.version       = "0.2.0"
  s.summary       = "iDroid-Layout2 is a port of Androids layout system and its drawable and resources framework to iOS."

  s.description   = <<-DESC
The main reason for this project is to learn more about the Android layout system and how it works.
Another reason is the lack of a advanced layout system in iOS ( **Update:** this is not true anymore for iOS >= 6 because of the introduction of auto layout). Currently it is a pain to build maintainable UI code in iOS. You have the choice between doing your layout in interface builder which is great for static, but not powerful enough for dynamic content, or doing all in code which is difficult to maintain.
In Android layouts can be defined in XML. Views automatically adjust their size while taking into account their content requirements and their parents' size restrictions.
                   DESC

  s.homepage      = "https://github.com/liraz/iDroidLayout2"
  s.screenshots   = "https://raw.githubusercontent.com/liraz/iDroidLayout2/master/Documentation/layout_example.png"
  s.license       = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author        = { "Liraz Shilkrot" => "lirazshilk@gmail.com" }

  s.platform      = :ios, "6.0"
  s.source        = { :git => "https://github.com/liraz/iDroidLayout2.git", :tag => "#{s.version}" }
  s.source_files  = 'iDroidLayout2', 'iDroidLayout2/**/*.{h,m}'
  s.framework     = 'QuartzCore', 'UIKit', 'CoreGraphics'
  s.requires_arc  = true

  s.dependency 'TBXML', '~> 1.5'
end
