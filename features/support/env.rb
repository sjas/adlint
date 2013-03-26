NOARCH_TRAITS = <<EOF
version: "3.0.0"

exam_packages:
  - "c_builtin"

project_traits:
  project_name: "features"
  project_root: "."
  target_files:
    inclusion_paths:
      - "."
    exclusion_paths:
  initial_header: "empty_pinit.h"
  file_search_paths:
  coding_style:
    indent_style: "K&R"
    tab_width: 8
    indent_width: 4
  file_encoding:

compiler_traits:
  initial_header: "empty_cinit.h"
  file_search_paths:
    - "."
  standard_types:
    char_size: 8
    char_alignment: 8
    short_size: 16
    short_alignment: 16
    int_size: 32
    int_alignment: 32
    long_size: 32
    long_alignment: 32
    long_long_size: 64
    long_long_alignment: 64
    float_size: 32
    float_alignment: 32
    double_size: 64
    double_alignment: 64
    long_double_size: 96
    long_double_alignment: 96
    code_ptr_size: 32
    code_ptr_alignment: 32
    data_ptr_size: 32
    data_ptr_alignment: 32
    char_as_unsigned_char: true
  arithmetic:
    logical_right_shift: true
  identifier_max: 128
  extension_substitutions:
    "pascal": ""
    "__pascal": ""
    "fortran": ""
    "__fortran": ""
    "cdecl": ""
    "__cdecl": ""
    "near": ""
    "__near": ""
    "far": ""
    "__far": ""
    "huge": ""
    "__huge": ""
    "__extension__": ""
    "__attribute__(__adlint__any)": ""
  arbitrary_substitutions:
    "typeof": "__typeof__"
    "__typeof": "__typeof__"
    "alignof": "__alignof__"
    "__alignof": "__alignof__"

linker_traits:
  identifier_max: 128
  identifier_ignore_case: false

message_traits:
  language: "ja_JP"
  individual_suppression: true
  exclusion:
  inclusion:
  change_list:
EOF

DUMMY_STDIO_H = <<EOF
#if !defined(DUMMY_STDIO_H)
#define DUMMY_STDIO_H

extern int printf(const char *, ...);
extern int scanf(const char *, ...);

typedef int FILE;
extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;

extern int fprintf(FILE *, const char *, ...);
extern int fscanf(FILE *, const char *, ...);

#endif
EOF

DUMMY_MATH_H = <<EOF
#if !defined(DUMMY_MATH_H)
#define DUMMY_MATH_H
#endif
EOF

DUMMY_ASSERT_H = <<EOF
#if !defined(DUMMY_ASSERT_H)
#define DUMMY_ASSERT_H

#define assert(expr) (0)

#endif
EOF

DUMMY_STDDEF_H = <<EOF
#if !defined(DUMMY_STDDEF_H)
#define DUMMY_STDDEF_H

typedef unsigned long size_t;

#endif
EOF

if ENV["ADLINT_COV"] =~ /1|on|true/
  require "simplecov"
  require "simplecov-html"
  SimpleCov.start
end

$bindir = File.expand_path("../../bin", File.dirname(__FILE__))
$tmpdir = File.expand_path("../../cucumber-tmp", File.dirname(__FILE__))

module Kernel
  def exit(status)
    # NOTE: To avoid terminating cucumber process.
  end
end

EXCL_FILES = /_pinit\.h|_cinit\.h|stdio\.h|math\.h|assert\.h|stddef\.h/

def run_adlint(cmd, *args)
  create_adlint_files
  cd_to_tmpdir do
    $all_output = exec(cmd, *args).each_line.map { |line|
      if line =~ /#{EXCL_FILES}.*:warning/
        nil
      else
        line.chomp
      end
    }.compact.join("\n")
  end
end

def cd_to_tmpdir(&block)
  orig_wd = Dir.getwd
  Dir.mkdir($tmpdir) unless Dir.exist?($tmpdir)
  Dir.chdir($tmpdir)
  yield
ensure
  Dir.chdir(orig_wd)
end

def exec(cmd, *args)
  ARGV.replace(args)
  orig_stdout = $stdout.dup
  orig_stderr = $stderr.dup
  File.open("all_output", "w") do |io|
    $stdout.reopen(io)
    $stderr.reopen(io)
    load "#{$bindir}/#{cmd}"
    $stdout.flush
    $stderr.flush
  end
  $stdout.reopen(orig_stdout)
  $stderr.reopen(orig_stderr)
  File.read("all_output")
end

def create_src_file(fpath, content)
  cd_to_tmpdir { create_file(fpath, content) }
end

def create_adlint_files
  cd_to_tmpdir do
    create_file("noarch_traits.yml", NOARCH_TRAITS)
    create_file("empty_pinit.h")
    create_file("empty_cinit.h")
    create_file("stdio.h", DUMMY_STDIO_H)
    create_file("math.h", DUMMY_MATH_H)
    create_file("assert.h", DUMMY_ASSERT_H)
    create_file("stddef.h", DUMMY_STDDEF_H)
  end
end

def create_file(fname, content = "")
  File.open(fname, "wb") { |io| io.puts content }
end
