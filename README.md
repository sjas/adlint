# AdLint - Advanced Lint

**AdLint** is a source code static analyzer.

It can point out unreliable or nonportable code fragments, and can measure various quality metrics of the source code.
It (currently) can analyze source code compliant with ANSI C89 / ISO C90 and partly ISO C99.

For more details, visit our project homepage at <http://adlint.sourceforge.net/>.

## How to Install

### Requirement

* Ruby 1.9.3-p0 or later for normal use (*mandatory*)
* GNU Make 3 or later to use adlintized Makefile (optional but recommended)
* Racc 1.4.7 for development (optional)

### Installation

Setup your Ruby interpreter.
Then, you can install AdLint by following instruction.

    % gem install adlint
or

    % sudo gem install adlint

### Evaluation

Tiny sample C language projects are bundled with AdLint gem.
You can evaluate AdLint by the following instructions.

First, copy `intro_demo` project into your workspace.
`adlint --prefix` command prints the prefix pathname of the AdLint installation directory.

    % cp -r `adlint --prefix`/share/demo/intro_demo .

Second, generate configuration files for AdLint.

    % cd intro_demo
    % adlintize

Following files will be generated.

File                   | Description
-----------------------|--------------------------------------------------------
`GNUmakefile`          | Automatic analysis makefile for GNU Make
`adlint_traits.yml`    | AdLint configuration file
`adlint_pinit.h`       | Project specific initial header file
`adlint_cinit.h`       | Compiler specific initial header file
`adlint_all.sh`        | Automatic analysis shell script
`adlint_all.bat`       | Automatic analysis mswin bat file
`adlint_files.txt`     | List file for sh script and bat file

Finally, do analysis.

    % make verbose-all
    adlint --verbose -t adlint_traits.yml -o . intro_demo.c
                      intro_demo.c [fin] |============================| 0.401s
                        intro_demo [fin] |============================| 0.029s
      1.125s user, 0.765s system, 00:00:01.89 total

Following files will be generated.

File                   | Description
-----------------------|--------------------------------------------------------
`intro_demo.i`         | Preprocessed source of `intro_demo.c`
`intro_demo.c.met.csv` | Single module code structure and metric information
`intro_demo.c.msg.csv` | Single module warning messages
`intro_demo.met.csv`   | Cross module metric information
`intro_demo.msg.csv`   | Cross module warning messages

`intro_demo.c.msg.csv` will tell you that the control will never reach to some
statements and that division-by-zero will occur in `intro_demo.c`.

## License

Copyright (C) 2010-2013, [OGIS-RI](http://www.ogis-ri.co.jp/) Co.,Ltd.

AdLint is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

AdLint is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
AdLint.  If not, see <http://www.gnu.org/licenses/>.

## Further Reading

* [User's Guide (in Japanese)](http://adlint.sourceforge.net/pmwiki/upload.d/Main/users_guide_ja.html)
* [User's Guide (in English)](http://adlint.sourceforge.net/pmwiki/upload.d/Main/users_guide_en.html)
* [Developer's Guide (in Japanese)](http://adlint.sourceforge.net/pmwiki/upload.d/Main/developers_guide_ja.html)

## TODO

* Support many more preset build environments
* Implement automatic traits files generator
* Improve accuracy of code checks

Any contributions are welcome!
