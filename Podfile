source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

abstract_target 'UitzendingGemistAbstract' do
    pod 'CocoaLumberjack/Swift', :git => 'https://github.com/ffried/CocoaLumberjack.git', :branch => 'swift3.0'
    pod 'UIColor_Hex_Swift', :git => 'https://github.com/yeahdongcn/UIColor-Hex-Swift', :branch => 'Swift-3.0'

    target 'UitzendingGemist' do
        platform :tvos, '10.0'

        pod 'NPOKit', :path => 'NPOKit'
    end
end
