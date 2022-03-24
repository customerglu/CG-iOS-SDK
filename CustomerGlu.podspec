#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint testsdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'CustomerGlu'
  s.version          = '1.0.7'
  s.summary          = 'CustomerGlu'
  s.description      = <<-DESC
A new CustomerGlu.
                       DESC
  s.homepage         = 'https://github.com/customerglu/CG-iOS-SDK'
  s.license          = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.author           = { 'CustomerGlu' => 'code@customerglu.net' }
  s.source           = { :git => 'https://github.com/customerglu/CG-iOS-SDK.git', :tag => 'v1.0.7'}
  s.source_files = 'Sources/**/*.*'
  s.exclude_files = 'Tests/**/*.*'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
end