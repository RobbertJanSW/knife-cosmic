Gem::Specification.new do |s|
  s.name = %q{knife-cosmic}
  s.version = "0.2.0"
  s.date = %q{2018-09-27}
  s.authors = ['Robbert-Jan Sperna Weiland']
  s.email = ['rspernaweiland@schubergphilis.com']
  s.summary = %q{A knife plugin for the cosmic API}
  s.homepage = %q{https://github.com/cosmic-extras/knife-cosmic}
  s.description = %q{A Knife plugin to create, list and manage cosmic servers}

  s.has_rdoc = false
  s.extra_rdoc_files = ["README.rdoc", "CHANGES.rdoc", "LICENSE" ]

  s.add_dependency "chef", ">= 11.0.0"
  s.add_dependency "knife-windows", ">= 0"
  s.require_path = 'lib'
  s.files = ["CHANGES.rdoc","README.rdoc", "LICENSE"] + Dir.glob("lib/**/*")
end
