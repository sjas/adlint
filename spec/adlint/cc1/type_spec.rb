# Unit specification of C type models.
#
# Author::    Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>

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

require "spec_helper"

module AdLint
module Cc1

  describe Type do
    before(:all) { @adlint = AdLint.new($default_traits) }

    before(:each) do
      @monitor = ProgressMonitor.new(nil, nil, false)
      @logger  = Logger.new(File.open(File::NULL, "w"))
    end

    let(:type_table) { TypeTable.new(@adlint.traits, @monitor, @logger) }

    let(:int_ptr_t) {
      pointer_type(int_t)
    }

    let(:const_int_ptr_t) {
      pointer_type(qualified_type(int_t, :const))
    }

    let(:const_int_t) {
      qualified_type(int_t, :const)
    }

    let(:volatile_int_t) {
      qualified_type(int_t, :volatile)
    }

    let(:const_volatile_int_t) {
      qualified_type(int_t, :const, :volatile)
    }

    let(:const_char_t) {
      qualified_type(char_t, :const)
    }

    let(:const_unsigned_char_t) {
      qualified_type(unsigned_char_t, :const)
    }

    let(:char_ptr_t) {
      pointer_type(char_t)
    }

    let(:const_char_ptr_t) {
      pointer_type(qualified_type(char_t, :const))
    }

    let(:const_unsigned_char_ptr_t) {
      pointer_type(qualified_type(unsigned_char_t, :const))
    }

    describe ArrayType do
      context "`int[3]'" do
        subject { array_type(int_t, 3) }

        it "should be convertible to `const int *'" do
          should be_convertible(const_int_ptr_t)
        end

        it "should be convertible to `int *'" do
          should be_convertible(int_ptr_t)
        end
      end

      context "`int[]'" do
        subject { array_type(int_t) }

        it "should be convertible to `const int *'" do
          should be_convertible(const_int_ptr_t)
        end

        it "should be convertible to `int *'" do
          should be_convertible(int_ptr_t)
        end
      end
    end

    describe PointerType do
      context "`const int *'" do
        subject { const_int_ptr_t }

        it "should not be convertible to `int[]'" do
          should_not be_convertible(array_type(int_t))
        end
      end

      context "`int *'" do
        subject { int_ptr_t }

        it "should be convertible to `int[]'" do
          should be_convertible(array_type(int_t))
        end
      end

      context "`const int'" do
        subject { const_int_t }

        it "should be more cv-qualified than `int'" do
          should be_more_cv_qualified(int_t)
        end

        it "should not be more cv-qualified than `const int'" do
          should_not be_more_cv_qualified(const_int_t)
        end

        it "should not be more cv-qualified than `volatile int'" do
          should_not be_more_cv_qualified(volatile_int_t)
        end
      end

      context "`volatile int'" do
        subject { volatile_int_t }

        it "should be more cv-qualified than `int'" do
          should be_more_cv_qualified(int_t)
        end
      end

      context "`const volatile int'" do
        subject { const_volatile_int_t }

        it "should be more cv-qualified than `int'" do
          should be_more_cv_qualified(int_t)
        end

        it "should be more cv-qualified than `const int'" do
          should be_more_cv_qualified(const_int_t)
        end

        it "should be more cv-qualified than `volatile int'" do
          should be_more_cv_qualified(volatile_int_t)
        end
      end
    end

    describe QualifiedType do
      context "`const char'" do
        subject { const_char_t }

        it "should be equal to `const unsigned char'" do
          should == const_unsigned_char_t
        end

        it "should be convertible to `char'" do
          should be_convertible(char_t)
        end

        it "should be convertible to `const unsigned char'" do
          should be_convertible(const_unsigned_char_t)
        end
      end

      context "`char'" do
        subject { char_t }

        it "should be convertible to `const char'" do
          should be_convertible(const_char_t)
        end
      end

      context "`const char *'" do
        subject { const_char_ptr_t }

        it "should be convertible to `const unsigned char *'" do
          should be_convertible(const_unsigned_char_ptr_t)
        end

        it "should not be convertible to `char *'" do
          should_not be_convertible(char_ptr_t)
        end
      end
    end

    describe CharType do
      context "`char'" do
        subject { char_t }

        it "should be equal to `unsigned char'" do
          should == unsigned_char_t
        end

        it "should not be equal to `signed char'" do
          should_not == signed_char_t
        end
      end
    end

    include TypeTableMediator
  end

end
end
