source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

abstract_target 'UitzendingGemistAbstract' do
    pod 'CocoaLumberjack/Swift'
    pod 'UIColor_Hex_Swift'

    target 'UitzendingGemist' do
        platform :tvos, '10.0'

        pod 'NPOKit', :path => 'NPOKit'
    end

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
