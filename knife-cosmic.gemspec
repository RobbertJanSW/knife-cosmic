Gem::Specification.new do |s|
  s.name = %q{knife-cosmic}
  s.version = "0.1.0"
  s.date = %q{2016-03-18}
  s.authors = ['Ryan Holmes', 'KC Braunschweig', 'John E. Vincent', 'Chirag Jog', 'Sander Botman']
  s.email = ['rholmes@edmunds.com', 'kcbraunschweig@gmail.com', 'lusis.org+github.com@gmail.com', 'chirag.jog@me.com', 'sbotman@schubergphilis.com']
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
