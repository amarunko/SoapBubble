Pod::Spec.new do |s|
    s.name         = 'SoapBubble'
    s.version      = '0.1.5'
    s.summary      = 'Let your cell slip like a soap'
    s.homepage     = 'https://github.com/ChaselAn/SwipableCell'
    s.license      = 'MIT'
    s.authors      = {'ChaselAn' => '865770853@qq.com'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'git@github.com:amarunko/SoapBubble.git', :tag => s.version}
    s.source_files = 'SoapBubble/*.swift'
    s.requires_arc = true
    s.dependency 'Texture'
end
