#--
#     ___    ____  __    ___   _________
#    /   |  / _  |/ /   / / | / /__  __/           Source Code Static Analyzer
#   / /| | / / / / /   / /  |/ /  / /                   AdLint - Advanced Lint
#  / __  |/ /_/ / /___/ / /|  /  / /
# /_/  |_|_____/_____/_/_/ |_/  /_/   Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
#
# This file is part of AdLint.
#
# AdLint is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# AdLint is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# AdLint.  If not, see <http://www.gnu.org/licenses/>.
#
#++

require "rubygems/package_task"
require "rdoc/task"
require "rspec/core/rake_task"
require "cucumber/rake/task"

$: << File.expand_path("lib", File.dirname(__FILE__))
require "adlint/version"

task :default => [:gem]
task :gem => [:parser, :doc]
task :package => [:parser, :doc]

gemspec = Gem::Specification.new do |s|
  s.name        = "adlint"
  s.version     = AdLint::SHORT_VERSION
  s.date        = AdLint::RELEASE_DATE
  s.homepage    = "http://adlint.sourceforge.net/"
  s.licenses    = ["GPLv3+: GNU General Public License version 3 or later"]
  s.author      = "Yutaka Yanoh"
  s.email       = "yanoh@users.sourceforge.net"
  s.summary     = <<EOS
AdLint :: Advanced Lint - An open source and free source code static analyzer
EOS
  s.description = <<EOS
AdLint is a source code static analyzer.
It can point out unreliable or nonportable code fragments, and can measure various quality metrics of the source code.
It (currently) can analyze source code compliant with ANSI C89 / ISO C90 and partly ISO C99.
EOS

  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  s.executables   = %w(adlint adlint_sma adlint_cma adlint_chk adlintize)
  s.require_paths = %w(lib)
  manifest_fpath  = File.expand_path("MANIFEST", File.dirname(__FILE__))
  s.files         = File.readlines(manifest_fpath).map { |str| str.chomp }

  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README)
  s.rdoc_options     = ["--main", "README", "--charset", "utf-8"]

  s.post_install_message = <<EOS
-------------------------------------------------------------------------------
     ___    ____  __    ___   _________
    /   |  / _  |/ /   / / | / /__  __/            Source Code Static Analyzer
   / /| | / / / / /   / /  |/ /  / /                    AdLint - Advanced Lint
  / __  |/ /_/ / /___/ / /|  /  / /
 /_/  |_|_____/_____/_/_/ |_/  /_/    Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.

                         Thanks for installing AdLint!
     Please visit our project homepage at <http://adlint.sourceforge.net/>.

-------------------------------------------------------------------------------
EOS
end

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar_bz2 = true
end

desc "Generate all parsers"
task :parser do
  chdir "lib/adlint/cpp" do
    racc Dir["*.y"]
  end
  chdir "lib/adlint/cc1" do
    racc Dir["*.y"]
  end
end

desc "Build Texinfo HTML files"
task :doc do
  chdir "share/doc" do
    make "all"
  end
end

RDoc::Task.new(:rdoc) do |rd|
  rd.rdoc_dir = "rdoc"
  rd.title = "AdLint #{AdLint::SHORT_VERSION} Documentation"
  rd.main = "README"
  rd.rdoc_files.include("README")
  rd.rdoc_files.include("bin/*")
  rd.rdoc_files.include("lib/**/*.{rb,y}")
  rd.rdoc_files.exclude("lib/adlint/cpp/constexpr.rb")
  rd.rdoc_files.exclude("lib/adlint/cc1/parser.rb")
  rd.options << "--charset=utf-8" << "--all"
end

desc "Generate tags file"
task :tags do
  ctags *Dir["bin/*", "lib/**/*.rb"]
end

desc "Remove all temporary products"
task :clean do
  chdir "lib/adlint/cpp" do
    rm_f Dir["*.output"]
  end
  chdir "lib/adlint/cc1" do
    rm_f Dir["*.output"]
  end
end

desc "Remove all generated products"
task :clobber => :clean do
  chdir "lib/adlint/cpp" do
    rm_f Dir["*.y"].map { |f| "#{File.basename(f, '.y')}.rb" }
  end
  chdir "lib/adlint/cc1" do
    rm_f Dir["*.y"].map { |f| "#{File.basename(f, '.y')}.rb" }
  end
  rm_f Dir["share/doc/*.html"]
  rm_rf ["rdoc", "pkg"]
  rm_f "tags"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w(-w)
  t.rspec_opts = %w(-f html -o spec.html)
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w(--strict --quiet -f html -o features.html)
end

def racc(files)
  files.each do |file|
    sh "racc #{file} -o #{File.basename(file, ".y")}.rb"
    racced_src = File.open("#{File.basename(file, ".y")}.rb") { |io| io.read }
    File.open("#{File.basename(file, ".y")}.rb", "w") do |io|
      beautify_racced_source(racced_src).each { |line| io.puts(line) }
    end
  end
end

def beautify_racced_source(src)
  end_count = 0
  src.each_line.reverse_each.map { |line|
    line.chomp!
    if end_count < 3 && line =~ /\A\s*(end\b.*)\z/
      line = "  " * end_count + $1
      end_count += 1
    end
    line
  }.reverse
end

def make(*targets)
  sh "make " + targets.join(" ")
end

def ctags(*files)
  sh "ctags " + files.join(" ")
end
