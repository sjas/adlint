# Unit specification of operator of controlling expressions.
#
# Author::    Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2014, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>

#--
#     ___    ____  __    ___   _________
#    /   |  / _  |/ /   / / | / /__  __/           Source Code Static Analyzer
#   / /| | / / / / /   / /  |/ /  / /                   AdLint - Advanced Lint
#  / __  |/ /_/ / /___/ / /|  /  / /
# /_/  |_|_____/_____/_/_/ |_/  /_/   Copyright (C) 2010-2014, OGIS-RI Co.,Ltd.
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
        expect(subject === Operator::EQ).to be true
      end

      it "=== Operator::NE should be true" do
        expect(subject === Operator::NE).to be true
      end

      it "=== Operator::LT should be true" do
        expect(subject === Operator::LT).to be true
      end

      it "=== Operator::GT should be true" do
        expect(subject === Operator::GT).to be true
      end

      it "=== Operator::LE should be true" do
        expect(subject === Operator::LE).to be true
      end

      it "=== Operator::GE should be true" do
        expect(subject === Operator::GE).to be true
      end
    end

    context "Operator::EQ" do
      subject { Operator::EQ }

      it "=== `==' should be true" do
        expect(subject === ComparisonOperator.new(:==)).to be true
      end

      it "=== `!=' should be false" do
        expect(subject === ComparisonOperator.new(:!=)).to be false
      end

      it "=== `<' should be false" do
        expect(subject === ComparisonOperator.new(:<)).to be false
      end

      it "=== `>' should be false" do
        expect(subject === ComparisonOperator.new(:>)).to be false
      end

      it "=== `<=' should be false" do
        expect(subject === ComparisonOperator.new(:<=)).to be false
      end

      it "=== `>=' should be false" do
        expect(subject === ComparisonOperator.new(:>=)).to be false
      end
    end

    context "Operator::NE" do
      subject { Operator::NE }

      it "=== `==' should be false" do
        expect(subject === ComparisonOperator.new(:==)).to be false
      end

      it "=== `!=' should be true" do
        expect(subject === ComparisonOperator.new(:!=)).to be true
      end

      it "=== `<' should be false" do
        expect(subject === ComparisonOperator.new(:<)).to be false
      end

      it "=== `>' should be false" do
        expect(subject === ComparisonOperator.new(:>)).to be false
      end

      it "=== `<=' should be false" do
        expect(subject === ComparisonOperator.new(:<=)).to be false
      end

      it "=== `>=' should be false" do
        expect(subject === ComparisonOperator.new(:>=)).to be false
      end
    end

    context "Operator::LT" do
      subject { Operator::LT }

      it "=== `==' should be false" do
        expect(subject === ComparisonOperator.new(:==)).to be false
      end

      it "=== `!=' should be false" do
        expect(subject === ComparisonOperator.new(:!=)).to be false
      end

      it "=== `<' should be true" do
        expect(subject === ComparisonOperator.new(:<)).to be true
      end

      it "=== `>' should be false" do
        expect(subject === ComparisonOperator.new(:>)).to be false
      end

      it "=== `<=' should be false" do
        expect(subject === ComparisonOperator.new(:<=)).to be false
      end

      it "=== `>=' should be false" do
        expect(subject === ComparisonOperator.new(:>=)).to be false
      end
    end

    context "Operator::GT" do
      subject { Operator::GT }

      it "=== `==' should be false" do
        expect(subject === ComparisonOperator.new(:==)).to be false
      end

      it "=== `!=' should be false" do
        expect(subject === ComparisonOperator.new(:!=)).to be false
      end

      it "=== `<' should be false" do
        expect(subject === ComparisonOperator.new(:<)).to be false
      end

      it "=== `>' should be true" do
        expect(subject === ComparisonOperator.new(:>)).to be true
      end

      it "=== `<=' should be false" do
        expect(subject === ComparisonOperator.new(:<=)).to be false
      end

      it "=== `>=' should be false" do
        expect(subject === ComparisonOperator.new(:>=)).to be false
      end
    end

    context "Operator::LE" do
      subject { Operator::LE }

      it "=== `==' should be false" do
        expect(subject === ComparisonOperator.new(:==)).to be false
      end

      it "=== `!=' should be false" do
        expect(subject === ComparisonOperator.new(:!=)).to be false
      end

      it "=== `<' should be false" do
        expect(subject === ComparisonOperator.new(:<)).to be false
      end

      it "=== `>' should be false" do
        expect(subject === ComparisonOperator.new(:>)).to be false
      end

      it "=== `<=' should be true" do
        expect(subject === ComparisonOperator.new(:<=)).to be true
      end

      it "=== `>=' should be false" do
        expect(subject === ComparisonOperator.new(:>=)).to be false
      end
    end

    context "Operator::GE" do
      subject { Operator::GE }

      it "=== `==' should be false" do
        expect(subject === ComparisonOperator.new(:==)).to be false
      end

      it "=== `!=' should be false" do
        expect(subject === ComparisonOperator.new(:!=)).to be false
      end

      it "=== `<' should be false" do
        expect(subject === ComparisonOperator.new(:<)).to be false
      end

      it "=== `>' should be false" do
        expect(subject === ComparisonOperator.new(:>)).to be false
      end

      it "=== `<=' should be false" do
        expect(subject === ComparisonOperator.new(:<=)).to be false
      end

      it "=== `>=' should be true" do
        expect(subject === ComparisonOperator.new(:>=)).to be true
      end
    end

    describe ComparisonOperator do
      context "`=='" do
        subject { ComparisonOperator.new(:==) }

        it "=== Operator::EQ should be true" do
          expect(subject === Operator::EQ).to be true
        end

        it "=== Operator::NE should be false" do
          expect(subject === Operator::NE).to be false
        end

        it "=== Operator::LT should be false" do
          expect(subject === Operator::LT).to be false
        end

        it "=== Operator::GT should be false" do
          expect(subject === Operator::GT).to be false
        end

        it "=== Operator::LE should be false" do
          expect(subject === Operator::LE).to be false
        end

        it "=== Operator::GE should be false" do
          expect(subject === Operator::GE).to be false
        end
      end

      context "`!='" do
        subject { ComparisonOperator.new(:!=) }

        it "=== Operator::EQ should be false" do
          expect(subject === Operator::EQ).to be false
        end

        it "=== Operator::NE should be true" do
          expect(subject === Operator::NE).to be true
        end

        it "=== Operator::LT should be false" do
          expect(subject === Operator::LT).to be false
        end

        it "=== Operator::GT should be false" do
          expect(subject === Operator::GT).to be false
        end

        it "=== Operator::LE should be false" do
          expect(subject === Operator::LE).to be false
        end

        it "=== Operator::GE should be false" do
          expect(subject === Operator::GE).to be false
        end
      end

      context "`<'" do
        subject { ComparisonOperator.new(:<) }

        it "=== Operator::EQ should be false" do
          expect(subject === Operator::EQ).to be false
        end

        it "=== Operator::NE should be false" do
          expect(subject === Operator::NE).to be false
        end

        it "=== Operator::LT should be true" do
          expect(subject === Operator::LT).to be true
        end

        it "=== Operator::GT should be false" do
          expect(subject === Operator::GT).to be false
        end

        it "=== Operator::LE should be false" do
          expect(subject === Operator::LE).to be false
        end

        it "=== Operator::GE should be false" do
          expect(subject === Operator::GE).to be false
        end
      end

      context "`>'" do
        subject { ComparisonOperator.new(:>) }

        it "=== Operator::EQ should be false" do
          expect(subject === Operator::EQ).to be false
        end

        it "=== Operator::NE should be false" do
          expect(subject === Operator::NE).to be false
        end

        it "=== Operator::LT should be false" do
          expect(subject === Operator::LT).to be false
        end

        it "=== Operator::GT should be true" do
          expect(subject === Operator::GT).to be true
        end

        it "=== Operator::LE should be false" do
          expect(subject === Operator::LE).to be false
        end

        it "=== Operator::GE should be false" do
          expect(subject === Operator::GE).to be false
        end
      end

      context "`<='" do
        subject { ComparisonOperator.new(:<=) }

        it "=== Operator::EQ should be false" do
          expect(subject === Operator::EQ).to be false
        end

        it "=== Operator::NE should be false" do
          expect(subject === Operator::NE).to be false
        end

        it "=== Operator::LT should be false" do
          expect(subject === Operator::LT).to be false
        end

        it "=== Operator::GT should be false" do
          expect(subject === Operator::GT).to be false
        end

        it "=== Operator::LE should be true" do
          expect(subject === Operator::LE).to be true
        end

        it "=== Operator::GE should be false" do
          expect(subject === Operator::GE).to be false
        end
      end

      context "`>='" do
        subject { ComparisonOperator.new(:>=) }

        it "=== Operator::EQ should be false" do
          expect(subject === Operator::EQ).to be false
        end

        it "=== Operator::NE should be false" do
          expect(subject === Operator::NE).to be false
        end

        it "=== Operator::LT should be false" do
          expect(subject === Operator::LT).to be false
        end

        it "=== Operator::GT should be false" do
          expect(subject === Operator::GT).to be false
        end

        it "=== Operator::LE should be false" do
          expect(subject === Operator::LE).to be false
        end

        it "=== Operator::GE should be true" do
          expect(subject === Operator::GE).to be true
        end
      end
    end
  end

end
end
