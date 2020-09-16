#!/usr/bin/ruby

gem 'rake-builder', '~> 2.0', '>= 2.0.11'

require 'rake-builder'

$argv = {}

RakeBuilder::OptionParser.new { |op|
  op.on('--help') {
    $stdout.puts op
    exit 0
  }

  op.on('--debug', 'adds debug flags') { |v|
    $argv[:debug] = v
  }
}.parse!(ARGV)

namespaces = Dir['rakelib/c8-*.rake'].collect { |x| File.basename(x).chomp('.rake') }

desc 'Builds all libs'
task(default: namespaces.collect { |x| "#{x}:default" })

desc 'Run all tests'
task(test: namespaces.collect { |x| "#{x}:test" })

desc 'Clean all build targets'
task(:clean) {
  Dir['.obj', 'lib', 'bin'].each { |fn|
    if File.directory? fn
      FileUtils.rm_rf fn, verbose: true
    else
      FileUtils.rm fn, verbose: true
    end
  }
}

desc 'Generates template for new library'
task(:new, [:name]) { |t, args|
  name = args[:name]

  unless File.exist?("rakelib/c8-#{name}.rake")
    d = []
    d << "namespace('c8-#{name}') {"
    d << "  flags = ['--std=c++17', '-Wall', '-Werror', '-O3', '-s', '-DNDEBUG']"
    d << ""
    d << "  if $argv[:debug]"
    d << "    flags -= ['-O3', '-s', '-DNDEBUG']"
    d << "    flags += ['-g']"
    d << "  end"
    d << ""
    d << "  install = InstallPkg.new { |t|"
    d << "    t.name = 'pkgs'"
    d << "    t.pkgs << []"
    d << "  }"
    d << ""
    d << "  pkgs = []"
    d << ""
    d << "  generated = ["
    d << "    'src/c8-#{name}/errors.hpp'"
    d << "  ].collect { |fn|"
    d << "    if dir = fn.chomp(File.extname(fn)) and File.directory?(dir)"
    d << "      Generate.includeDirectory(dir)"
    d << "    end"
    d << "  }.compact"
    d << ""
    d << "  library = Library.new { |t|"
    d << "    t.name = 'lib/libc8-#{name}.a'"
    d << "    t.requirements << ['c8-#{name}:pkgs', generated]"
    d << "    t.sources << FileList['src/c8-#{name}/**/*.cpp']"
    d << "    t.includes << ['src']"
    d << "    t.pkgs << pkgs"
    d << "    t.flags << flags"
    d << "  }"
    d << ""
    d << "  ut = Executable.new { |t|"
    d << "    t.name = 'bin/c8-#{name}-ut'"
    d << "    t.requirements << ['c8-#{name}:pkgs', generated]"
    d << "    t.sources << FileList['test/c8-#{name}/**/*.cpp']"
    d << "    t.includes << ['src', 'test']"
    d << "    t.libs << ['-pthread', '-lgtest', '-lgmock', library]"
    d << "    t.pkgs << pkgs"
    d << "    t.flags << flags"
    d << "  }"
    d << ""
    d << "  desc 'Builds c8-#{name}'"
    d << "  C8.multitask(default: Names['generated:default', library])"
    d << ""
    d << "  desc 'Runs c8-#{name} tests'"
    d << "  C8.multitask(test: Names['generated:default', library, ut]) {"
    d << "    sh ut.name"
    d << "  }"
    d << "}"

    IO.write("rakelib/c8-#{name}.rake", d.join("\n"))
  end

  FileUtils.mkdir_p "src/c8-#{name}"
  FileUtils.mkdir_p "test/c8-#{name}"

  unless File.exist?("test/c8-#{name}/main.cpp")
    d = []
    d << "#include <gtest/gtest.h>"
    d << ""
    d << "int main(int argc, char** argv) {"
    d << "  testing::InitGoogleTest(&argc, argv);"
    d << "  return RUN_ALL_TESTS();"
    d << "}"

    IO.write("test/c8-#{name}/main.cpp", d.join("\n"))
  end
}
