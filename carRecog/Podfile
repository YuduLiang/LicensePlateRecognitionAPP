use_frameworks!
platform :ios, '11.0'


target 'carRecog' do
  use_frameworks!
  pod 'TesseractOCRiOS'
  pod "AFNetworking"
  pod 'SwiftyJSON'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'TesseractOCRiOS'
            target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
            header_phase = target.build_phases().select do |phase|
                phase.is_a? Xcodeproj::Project::PBXHeadersBuildPhase
            end.first
            
            duplicated_header_files = header_phase.files.select do |file|
                file.display_name == 'config_auto.h'
            end
            
            duplicated_header_files.each do |file|
                header_phase.remove_build_file file
            end
        end
    end
end
