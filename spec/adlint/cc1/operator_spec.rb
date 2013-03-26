# Unit specification of operator of controlling expressions.
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

  describe Operator do
    context "Operator" do
      subject { Operator }

      it "=== Operator::EQ should be true" do
        (subject === Operator::EQ).should be_true
      end

      it "=== Operator::NE should be true" do
        (subject === Operator::NE).should be_true
      end

      it "=== Operator::LT should be true" do
        (subject === Operator::LT).should be_true
      end

      it "=== Operator::GT should be true" do
        (subject === Operator::GT).should be_true
      end

      it "=== Operator::LE should be true" do
        (subject === Operator::LE).should be_true
      end

      it "=== Operator::GE should be true" do
        (subject === Operator::GE).should be_true
      end
    end

    context "Operator::EQ" do
      subject { Operator::EQ }

      it "=== `==' should be true" do
        (subject === ComparisonOperator.new(:==)).should be_true
      end

      it "=== `!=' should not be true" do
        (subject === ComparisonOperator.new(:!=)).should_not be_true
      end

      it "=== `<' should not be true" do
        (subject === ComparisonOperator.new(:<)).should_not be_true
      end

      it "=== `>' should not be true" do
        (subject === ComparisonOperator.new(:>)).should_not be_true
      end

      it "=== `<=' should not be true" do
        (subject === ComparisonOperator.new(:<=)).should_not be_true
      end

      it "=== `>=' should not be true" do
        (subject === ComparisonOperator.new(:>=)).should_not be_true
      end
    end

    context "Operator::NE" do
      subject { Operator::NE }

      it "=== `==' should not be true" do
        (subject === ComparisonOperator.new(:==)).should_not be_true
      end

      it "=== `!=' should be true" do
        (subject === ComparisonOperator.new(:!=)).should be_true
      end

      it "=== `<' should not be true" do
        (subject === ComparisonOperator.new(:<)).should_not be_true
      end

      it "=== `>' should not be true" do
        (subject === ComparisonOperator.new(:>)).should_not be_true
      end

      it "=== `<=' should not be true" do
        (subject === ComparisonOperator.new(:<=)).should_not be_true
      end

      it "=== `>=' should not be true" do
        (subject === ComparisonOperator.new(:>=)).should_not be_true
      end
    end

    context "Operator::LT" do
      subject { Operator::LT }

      it "=== `==' should not be true" do
        (subject === ComparisonOperator.new(:==)).should_not be_true
      end

      it "=== `!=' should not be true" do
        (subject === ComparisonOperator.new(:!=)).should_not be_true
      end

      it "=== `<' should be true" do
        (subject === ComparisonOperator.new(:<)).should be_true
      end

      it "=== `>' should not be true" do
        (subject === ComparisonOperator.new(:>)).should_not be_true
      end

      it "=== `<=' should not be true" do
        (subject === ComparisonOperator.new(:<=)).should_not be_true
      end

      it "=== `>=' should not be true" do
        (subject === ComparisonOperator.new(:>=)).should_not be_true
      end
    end

    context "Operator::GT" do
      subject { Operator::GT }

      it "=== `==' should not be true" do
        (subject === ComparisonOperator.new(:==)).should_not be_true
      end

      it "=== `!=' should not be true" do
        (subject === ComparisonOperator.new(:!=)).should_not be_true
      end

      it "=== `<' should not be true" do
        (subject === ComparisonOperator.new(:<)).should_not be_true
      end

      it "=== `>' should be true" do
        (subject === ComparisonOperator.new(:>)).should be_true
      end

      it "=== `<=' should not be true" do
        (subject === ComparisonOperator.new(:<=)).should_not be_true
      end

      it "=== `>=' should not be true" do
        (subject === ComparisonOperator.new(:>=)).should_not be_true
      end
    end

    context "Operator::LE" do
      subject { Operator::LE }

      it "=== `==' should not be true" do
        (subject === ComparisonOperator.new(:==)).should_not be_true
      end

      it "=== `!=' should not be true" do
        (subject === ComparisonOperator.new(:!=)).should_not be_true
      end

      it "=== `<' should not be true" do
        (subject === ComparisonOperator.new(:<)).should_not be_true
      end

      it "=== `>' should not be true" do
        (subject === ComparisonOperator.new(:>)).should_not be_true
      end

      it "=== `<=' should be true" do
        (subject === ComparisonOperator.new(:<=)).should be_true
      end

      it "=== `>=' should not be true" do
        (subject === ComparisonOperator.new(:>=)).should_not be_true
      end
    end

    context "Operator::GE" do
      subject { Operator::GE }

      it "=== `==' should not be true" do
        (subject === ComparisonOperator.new(:==)).should_not be_true
      end

      it "=== `!=' should not be true" do
        (subject === ComparisonOperator.new(:!=)).should_not be_true
      end

      it "=== `<' should not be true" do
        (subject === ComparisonOperator.new(:<)).should_not be_true
      end

      it "=== `>' should not be true" do
        (subject === ComparisonOperator.new(:>)).should_not be_true
      end

      it "=== `<=' should not be true" do
        (subject === ComparisonOperator.new(:<=)).should_not be_true
      end

      it "=== `>=' should be true" do
        (subject === ComparisonOperator.new(:>=)).should be_true
      end
    end

    describe ComparisonOperator do
      context "`=='" do
        subject { ComparisonOperator.new(:==) }

        it "=== Operator::EQ should be true" do
          (subject === Operator::EQ).should be_true
        end

        it "=== Operator::NE should not be true" do
          (subject === Operator::NE).should_not be_true
        end

        it "=== Operator::LT should not be true" do
          (subject === Operator::LT).should_not be_true
        end

        it "=== Operator::GT should not be true" do
          (subject === Operator::GT).should_not be_true
        end

        it "=== Operator::LE should not be true" do
          (subject === Operator::LE).should_not be_true
        end

        it "=== Operator::GE should not be true" do
          (subject === Operator::GE).should_not be_true
        end
      end

      context "`!='" do
        subject { ComparisonOperator.new(:!=) }

        it "=== Operator::EQ should not be true" do
          (subject === Operator::EQ).should_not be_true
        end

        it "=== Operator::NE should be true" do
          (subject === Operator::NE).should be_true
        end

        it "=== Operator::LT should not be true" do
          (subject === Operator::LT).should_not be_true
        end

        it "=== Operator::GT should not be true" do
          (subject === Operator::GT).should_not be_true
        end

        it "=== Operator::LE should not be true" do
          (subject === Operator::LE).should_not be_true
        end

        it "=== Operator::GE should not be true" do
          (subject === Operator::GE).should_not be_true
        end
      end

      context "`<'" do
        subject { ComparisonOperator.new(:<) }

        it "=== Operator::EQ should not be true" do
          (subject === Operator::EQ).should_not be_true
        end

        it "=== Operator::NE should not be true" do
          (subject === Operator::NE).should_not be_true
        end

        it "=== Operator::LT should be true" do
          (subject === Operator::LT).should be_true
        end

        it "=== Operator::GT should not be true" do
          (subject === Operator::GT).should_not be_true
        end

        it "=== Operator::LE should not be true" do
          (subject === Operator::LE).should_not be_true
        end

        it "=== Operator::GE should not be true" do
          (subject === Operator::GE).should_not be_true
        end
      end

      context "`>'" do
        subject { ComparisonOperator.new(:>) }

        it "=== Operator::EQ should not be true" do
          (subject === Operator::EQ).should_not be_true
        end

        it "=== Operator::NE should not be true" do
          (subject === Operator::NE).should_not be_true
        end

        it "=== Operator::LT should not be true" do
          (subject === Operator::LT).should_not be_true
        end

        it "=== Operator::GT should be true" do
          (subject === Operator::GT).should be_true
        end

        it "=== Operator::LE should not be true" do
          (subject === Operator::LE).should_not be_true
        end

        it "=== Operator::GE should not be true" do
          (subject === Operator::GE).should_not be_true
        end
      end

      context "`<='" do
        subject { ComparisonOperator.new(:<=) }

        it "=== Operator::EQ should not be true" do
          (subject === Operator::EQ).should_not be_true
        end

        it "=== Operator::NE should not be true" do
          (subject === Operator::NE).should_not be_true
        end

        it "=== Operator::LT should not be true" do
          (subject === Operator::LT).should_not be_true
        end

        it "=== Operator::GT should not be true" do
          (subject === Operator::GT).should_not be_true
        end

        it "=== Operator::LE should be true" do
          (subject === Operator::LE).should be_true
        end

        it "=== Operator::GE should not be true" do
          (subject === Operator::GE).should_not be_true
        end
      end

      context "`>='" do
        subject { ComparisonOperator.new(:>=) }

        it "=== Operator::EQ should not be true" do
          (subject === Operator::EQ).should_not be_true
        end

        it "=== Operator::NE should not be true" do
          (subject === Operator::NE).should_not be_true
        end

        it "=== Operator::LT should not be true" do
          (subject === Operator::LT).should_not be_true
        end

        it "=== Operator::GT should not be true" do
          (subject === Operator::GT).should_not be_true
        end

        it "=== Operator::LE should not be true" do
          (subject === Operator::LE).should_not be_true
        end

        it "=== Operator::GE should be true" do
          (subject === Operator::GE).should be_true
        end
      end
    end
  end

end
end
