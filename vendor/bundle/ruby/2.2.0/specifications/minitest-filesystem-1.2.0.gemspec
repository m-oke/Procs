# -*- encoding: utf-8 -*-
# stub: minitest-filesystem 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-filesystem"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Stefano Zanella"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDQDCCAiigAwIBAgIBADANBgkqhkiG9w0BAQUFADBGMRgwFgYDVQQDDA96YW5l\nbGxhLnN0ZWZhbm8xFTATBgoJkiaJk/IsZAEZFgVnbWFpbDETMBEGCgmSJomT8ixk\nARkWA2NvbTAeFw0xMzA4MDcxOTA2MDZaFw0xNDA4MDcxOTA2MDZaMEYxGDAWBgNV\nBAMMD3phbmVsbGEuc3RlZmFubzEVMBMGCgmSJomT8ixkARkWBWdtYWlsMRMwEQYK\nCZImiZPyLGQBGRYDY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA\n2JCnJCnjjs62MR/Tw/4WgSG42ruiCEqXV1ECMsXymHPE8xyHkYAwLXvBRzOkZ/IA\npuJ1XhScduMRcUuE0ZPA5N2HBZI0WsmyyNTYBjOob8m0SNInoRZfIMloj3D8QzB7\n/6G5HLMWNx60JEpIDgfXvIuSRKNKQ0/0+/G/H4COgj72pd3F4dYltvx+mSwPRq7Q\nMdZsK3T5Q3d4eLBY1VSlJpq0wkwdEWTXAhR0Mfmbn1D8m9IhJfubgXuXVBY4OPO8\nKAF/wWqTkzA6guVQlSKdZR4vwms7OpeFkotnivBKa6JwUQSXO8AZEyy53V8cSYDu\ndbaFi53YbEwOWSMQnW8/kQIDAQABozkwNzAdBgNVHQ4EFgQUcBKkmJAvSTKfDf7z\nLEu1wE+Rk+swCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwDQYJKoZIhvcNAQEFBQAD\nggEBAMeqfk1l4Y0iZ8jNiu0afcQ60DVqBkRtrT/rsZEqGsdOw11bntOE4yWpo4Kd\nY0C/kYrVQ/mIN7IGKbCSjES3aYdQftV9SRW77FA25m2KXRbnEYtJDUX35gAqSdRY\n9IiYivsMq2dr70eKPNFrFOwWvmwhcGyEG8EDvYoXWllke7RGz1Dn/AZx6jPnShO+\n0ru4OXsM9++md3sGXIugEFNygvo2/1yQoTe6+XiBocS+pWsJd6JZBfkxPRT4Dz4H\nRigBD0E3/t/ABjCXkmqwp5gnAZmP8JiVUkn8rp5E0FXvC8T7nsPs2TW/TAmUV6rN\nhK25FX8YWgT9fD9y3PpWjiYcrCo=\n-----END CERTIFICATE-----\n"]
  s.date = "2014-03-28"
  s.description = "Minitest exstension to check filesystem contents"
  s.email = ["zanella.stefano@gmail.com"]
  s.homepage = "https://github.com/stefanozanella/minitest-filesystem"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Adds assertions and expectations to check the content of a filesystem tree with minitest"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
      s.add_development_dependency(%q<flog>, [">= 0"])
      s.add_development_dependency(%q<flay>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<coveralls>, [">= 0"])
      s.add_dependency(%q<flog>, [">= 0"])
      s.add_dependency(%q<flay>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<coveralls>, [">= 0"])
    s.add_dependency(%q<flog>, [">= 0"])
    s.add_dependency(%q<flay>, [">= 0"])
  end
end
