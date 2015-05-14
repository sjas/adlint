# Unit specification of domain of values bound to variables.
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

  describe ValueDomain do
    include ArithmeticAccessor

    before(:all) { @adlint = AdLint.new($default_traits) }

    describe EqualToValueDomain do
      context "(== -2147483648)" do
        subject { value_domain_equal_to(-2147483648) }

        it "should contain (== -2147483648)" do
          expect(
            subject.contain?(value_domain_equal_to(-2147483648))
          ).to be true
        end

        it "should not contain (== 2147483647)" do
          expect(
            subject.contain?(value_domain_equal_to(2147483647))
          ).to be false
        end
      end

      context "(== 2147483647)" do
        subject { value_domain_equal_to(2147483647) }

        it "should not contain (== -2147483648)" do
          expect(
            subject.contain?(value_domain_equal_to(-2147483648))
          ).to be false
        end
      end

      context "(== 2)" do
        subject { value_domain_equal_to(2) }

        it "* (== 3) should be (== 6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(== 6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (== -6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(== -6)"
        end

        it "* (< 3) should be (< 6)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(< 6)"
        end

        it "* (< 0) should be (< 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (< -3) should be (< -6)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (> 3) should be (> 6)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (> 0) should be (> 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (> -3) should be (> -6)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(> -6)"
        end
      end

      context "(== 0)" do
        subject { value_domain_equal_to(0) }

        it "* (== 3) should be (== 0)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (== 0)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (< 3) should be (== 0)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (< 0) should be (== 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (< -3) should be (== 0)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (> 3) should be (== 0)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (> 0) should be (== 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (> -3) should be (== 0)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end
      end

      context "(== -2)" do
        subject { value_domain_equal_to(-2) }

        it "* (== 3) should be (== -6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(== -6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (== 6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(== 6)"
        end

        it "* (< 3) should be (> -6)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(> -6)"
        end

        it "* (< 0) should be (> 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (< -3) should be (> 6)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (> 3) should be (< -6)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (> 0) should be (< 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (> -3) should be (< 6)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(< 6)"
        end
      end
    end

    describe LessThanValueDomain do
      context "(< 128)" do
        subject { value_domain_less_than(128) }

        it "< (== 127) should be (== Unlimited)" do
          rhs = value_domain_equal_to(127)
          expect((subject < rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(< 2)" do
        subject { value_domain_less_than(2) }

        it "* (== 3) should be (< 6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(< 6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (> -6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(> -6)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (== Unlimited)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< -3) should be (== Unlimited)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> 3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> 0) should be (== Unlimited)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(< 0)" do
        subject { value_domain_less_than(0) }

        it "* (== 3) should be (< 0)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (> 0)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (> 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (< -3) should be (> 0)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (> 3) should be (< 0)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (> 0) should be (< 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(< -2)" do
        subject { value_domain_less_than(-2) }

        it "* (== 3) should be (< -6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (> 6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (> 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (< -3) should be (> 6)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (> 3) should be (< -6)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (> 0) should be (< 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end
    end

    describe GreaterThanValueDomain do
      context "(> -129)" do
        subject { value_domain_greater_than(-129) }

        it "< (== 127) should be (== Unlimited)" do
          rhs = value_domain_equal_to(127)
          expect((subject < rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(> 2)" do
        subject { value_domain_greater_than(2) }

        it "* (== 3) should be (> 6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (< -6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (< 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (< -3) should be (< -6)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(< -6)"
        end

        it "* (> 3) should be (> 6)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(> 6)"
        end

        it "* (> 0) should be (> 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(> 0)" do
        subject { value_domain_greater_than(0) }

        it "* (== 3) should be (> 0)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (< 0)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (< 0)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (< -3) should be (< 0)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(< 0)"
        end

        it "* (> 3) should be (> 0)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (> 0) should be (> 0)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(> 0)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end

      context "(> -2)" do
        subject { value_domain_greater_than(-2) }

        it "* (== 3) should be (> -6)" do
          rhs = value_domain_equal_to(3)
          expect((subject * rhs).to_s).to eq "(> -6)"
        end

        it "* (== 0) should be (== 0)" do
          rhs = value_domain_equal_to(0)
          expect((subject * rhs).to_s).to eq "(== 0)"
        end

        it "* (== -3) should be (< 6)" do
          rhs = value_domain_equal_to(-3)
          expect((subject * rhs).to_s).to eq "(< 6)"
        end

        it "* (< 3) should be (== Unlimited)" do
          rhs = value_domain_less_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< 0) should be (== Unlimited)" do
          rhs = value_domain_less_than(0)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (< -3) should be (== Unlimited)" do
          rhs = value_domain_less_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> 3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> 0) should be (== Unlimited)" do
          rhs = value_domain_greater_than(0)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end

        it "* (> -3) should be (== Unlimited)" do
          rhs = value_domain_greater_than(-3)
          expect((subject * rhs).to_s).to eq "(== Unlimited)"
        end
      end
    end

    describe CompositeValueDomain do
      context "(== (((< 10) || (== 10)) && ((== -10) || (> -10))))" do
        subject do
          tmp = value_domain_greater_than_or_equal_to(-10)
          tmp.intersection(value_domain_less_than_or_equal_to(10))
        end

        it "should contain ((== -5) || (== 5))" do
          rhs = value_domain_equal_to(-5).union(value_domain_equal_to(5))
          expect(subject.contain?(rhs)).to be true
        end
      end

      context "((== -5) || (== 5))" do
        subject { value_domain_equal_to(-5).union(value_domain_equal_to(5)) }

        it "should not contain " +
           "(((< 10) || (== 10)) && ((== -10) || (> -10)))" do
          rhs = value_domain_greater_than_or_equal_to(-10)
          rhs = rhs.intersection(value_domain_less_than_or_equal_to(10))
          expect(subject.contain?(rhs)).to be false
        end

        it "should be contained by " +
           "(((< 10) || (== 10)) && ((== -10) || (> -10)))" do
          lhs = value_domain_greater_than_or_equal_to(-10)
          lhs = lhs.intersection(value_domain_less_than_or_equal_to(10))
          expect(lhs.contain?(subject)).to be true
        end

        it "intersection with (< 0) should be equal to (== -5)" do
          rhs = value_domain_less_than(0)
          expect(subject.intersection(rhs).to_s).to eq "(== -5)"
        end

        it "intersection with (> 0) should be equal to (== 5)" do
          rhs = value_domain_greater_than(0)
          expect(subject.intersection(rhs).to_s).to eq "(== 5)"
        end

        it "intersection with ((== -10) || (> -10)) " +
           "should be equal to the subject domain" do
          rhs = value_domain_greater_than_or_equal_to(-10)
          expect(subject.intersection(rhs)).to eq subject
        end

        it "intersection with ((== 10) || (< 10)) " +
           "should be equal to the subject domain" do
          rhs = value_domain_less_than_or_equal_to(10)
          expect(subject.intersection(rhs)).to eq subject
        end

        it "should not contain (((< 0) && (> -10)) || (== -10))" do
          rhs = value_domain_greater_than_or_equal_to(-10)
          rhs = rhs.intersection(value_domain_less_than_or_equal_to(10))
          rhs = rhs.intersection(value_domain_less_than(0))
          expect(subject.contain?(rhs)).to be false
        end
      end

      context "(((< 0) && (> -10)) || (== -10))" do
        subject do
          tmp = value_domain_greater_than_or_equal_to(-10)
          tmp = tmp.intersection(value_domain_less_than_or_equal_to(10))
          tmp.intersection(value_domain_less_than(0))
        end

        it "should not contain ((== -5) || (== 5))" do
          rhs = value_domain_equal_to(-5).union(value_domain_equal_to(5))
          expect(subject.contain?(rhs)).to be false
        end
      end

      context "(((< 0) && (> -2147483647)) || (== 0))" do
        subject do
          tmp = value_domain_less_than_or_equal_to(0)
          tmp.intersection(value_domain_greater_than_or_equal_to(-2147483647))
        end

        it "union with ((== -2147483647) || (== 0)) should be " +
           "((((< 0) && (> -2147483647)) || (== -2147483647)) || (== 0))" do
          rhs = value_domain_equal_to(-2147483647)
          rhs = rhs.union(value_domain_equal_to(0))
          expect(subject.union(rhs).to_s).to eq \
            "((((< 0) && (> -2147483647)) || (== -2147483647)) || (== 0))"
        end
      end

      context "((== -2147483647) || (== 0))" do
        subject do
          value_domain_equal_to(-2147483647).union(value_domain_equal_to(0))
        end

        it "should contain ((== -2147483647) || (== 0))" do
          rhs = value_domain_equal_to(-2147483647)
          rhs = rhs.union(value_domain_equal_to(0))
          expect(subject.contain?(rhs)).to be true
        end

        it "should contain (== -2147483647)" do
          expect(
            subject.contain?(value_domain_equal_to(-2147483647))
          ).to be true
        end

        it "should contain (== 0)" do
          expect(subject.contain?(value_domain_equal_to(0))).to be true
        end
      end

      context "(((< 2147483647) && (> -2147483648)) || (== 2147483647))" do
        subject do
          tmp = value_domain_greater_than(-2147483648)
          tmp = tmp.intersection(value_domain_less_than(2147483647))
          tmp.union(value_domain_equal_to(2147483647))
        end

        it "cloned should be " +
           "(((< 2147483647) && (> -2147483648)) || (== 2147483647))" do
          expect(subject.dup.to_s).to eq \
            "(((< 2147483647) && (> -2147483648)) || (== 2147483647))"
        end

        it "intersection with its cloned should be " +
           "(((< 2147483647) && (> -2147483648)) || (== 2147483647))" do
          expect(subject.intersection(subject.dup).to_s).to eq \
            "(((< 2147483647) && (> -2147483648)) || (== 2147483647))"
        end

        it "union with its cloned should be " +
           "(((< 2147483647) && (> -2147483648)) || (== 2147483647))" do
          expect(subject.union(subject.dup).to_s).to eq \
            "(((< 2147483647) && (> -2147483648)) || (== 2147483647))"
        end
      end

      context "(((< 2147483647) && (> 1)) || (== 1))" do
        subject do
          tmp = value_domain_greater_than(1)
          tmp = tmp.intersection(value_domain_less_than(2147483647))
          tmp.union(value_domain_equal_to(1))
        end

        it "union with ((== 1) || (== 2147483647)) should be " +
           "(((< 2147483647) && (> 1)) || ((== 1) || (== 2147483647)))" do
          rhs = value_domain_equal_to(1)
          rhs = rhs.union(value_domain_equal_to(2147483647))
          expect(subject.union(rhs).to_s).to eq \
            "(((< 2147483647) && (> 1)) || ((== 1) || (== 2147483647)))"
        end
      end

      context "(((< 429) && (> 0)) || (== 429))" do
        subject do
          tmp = value_domain_greater_than(0)
          tmp = tmp.intersection(value_domain_less_than(429))
          tmp.union(value_domain_equal_to(429))
        end

        it "intersection with (== 0) should be (== Nil)" do
          expect(subject.intersection(value_domain_equal_to(0)).to_s).to eq \
            "(== Nil)"
        end
      end

      context "(((< 10) || (== 10)) && ((== 0) || (> 0)))" do
        subject do
          ValueDomain.of_intersection(
            value_domain_greater_than_or_equal_to(0),
            value_domain_less_than_or_equal_to(10)
          )
        end

        it "+ (((< 10) || (== 10)) && ((== 0) || (> 0))) " +
           "should be ((((< 20) && (> 0)) || (== 0)) || (== 20))" do
          expect((subject + subject.dup).to_s).to eq \
            "((((< 20) && (> 0)) || (== 0)) || (== 20))"
        end
      end

      context "((((< 10) && (> -10)) || (== 10)) || (== -10))" do
        subject do
          tmp = value_domain_greater_than_or_equal_to(-10)
          tmp.intersection(value_domain_less_than_or_equal_to(10))
        end

        it "should intersect with (== 0)" do
          expect(subject.intersect?(value_domain_equal_to(0))).to be true
        end

        it "< (== 0) should be (== Unlimited)" do
          expect((subject < value_domain_equal_to(0)).to_s).to eq \
            "(== Unlimited)"
        end

        it "> (== 0) should be (== Unlimited)" do
          expect((subject > value_domain_equal_to(0)).to_s).to eq \
            "(== Unlimited)"
        end

        it "== (== 0) should be (== Unlimited)" do
          expect((subject == value_domain_equal_to(0)).to_s).to eq \
            "(== Unlimited)"
        end

        it "!= (== 0) should be (== Unlimited)" do
          expect((subject != value_domain_equal_to(0)).to_s).to eq \
            "(== Unlimited)"
        end

        it "< (== 20) should be ((< 0) || (> 0))" do
          expect((subject < value_domain_equal_to(20)).to_s).to eq \
            "((< 0) || (> 0))"
        end

        it "> (== 20) should be (== 0)" do
          expect((subject > value_domain_equal_to(20)).to_s).to eq "(== 0)"
        end
      end

      context "(((< 11) && (> 1)) || (== 11))" do
        subject do
          tmp = value_domain_greater_than(1)
          tmp = tmp.intersection(value_domain_less_than(11))
          tmp.union(value_domain_equal_to(11))
        end

        it "narrowed by == ((((< 10) && (> 0)) || (== 10)) || (== 0)) " +
           "should be (((< 10) && (> 1)) || (== 10))" do
          rhs = value_domain_greater_than(0)
          rhs = rhs.intersection(value_domain_less_than(10))
          rhs = rhs.union(value_domain_equal_to(0))
          rhs = rhs.union(value_domain_equal_to(10))
          expect(subject.narrow(Operator::EQ, rhs).to_s).to eq \
            "(((< 10) && (> 1)) || (== 10))"
        end
      end

      context "((< 128) && (> -129))" do
        subject do
          tmp = value_domain_greater_than(-129)
          tmp.intersection(value_domain_less_than(128))
        end

        it "should intersect with (== -128)" do
          expect(subject.intersect?(value_domain_equal_to(-128))).to be true
        end

        it "should intersect with (== 127)" do
          expect(subject.intersect?(value_domain_equal_to(127))).to be true
        end
      end

      context "((((< 2147483647) && (> -2147483648)) || " +
              "(== 2147483647)) || (== -2147483648))" do
        subject do
          tmp = value_domain_greater_than_or_equal_to(-2147483648)
          tmp.intersection(value_domain_less_than_or_equal_to(2147483647))
        end

        it "narrowed by != (== 1) should be " +
           "(((((< 1) && (> -2147483648)) || ((< 2147483647) && (> 1))) || " +
           "(== 2147483647)) || (== -2147483648))" do
          expect(
            subject.narrow(Operator::NE, value_domain_equal_to(1)).to_s
          ).to eq \
            "(((((< 1) && (> -2147483648)) || ((< 2147483647) && (> 1))) || " +
            "(== 2147483647)) || (== -2147483648))"
        end
      end

      context "(((< 10) && (> 0)) || (== 0))" do
        subject do
          tmp = value_domain_greater_than_or_equal_to(0)
          tmp.intersection(value_domain_less_than(10))
        end

        it "narrowed by != its cloned should be (== Nil)" do
          expect(subject.narrow(Operator::NE, subject.dup).to_s).to eq \
            "(== Nil)"
        end
      end

      context "((< 10) && (> 0))" do
        subject do
          tmp = value_domain_greater_than(0)
          tmp.intersection(value_domain_less_than(10))
        end

        it "+ ((< 10) && (> 0)) should be ((< 10) && (> 0))" do
          rhs = value_domain_greater_than(0)
          rhs = rhs.intersection(value_domain_less_than(10))
          expect((subject + rhs).to_s).to eq "((< 20) && (> 0))"
        end

        it "* (== 2) should be ((< 20) && (> 0))" do
          rhs = value_domain_equal_to(2)
          expect((subject * rhs).to_s).to eq "((< 20) && (> 0))"
        end

        it "* ((< 10) && (> 0)) should be ((< 100) && (> 0))" do
          rhs = value_domain_greater_than(0)
          rhs = rhs.intersection(value_domain_less_than(10))
          expect((subject * rhs).to_s).to eq "((< 100) && (> 0))"
        end

        it "/ (== 2) should be ((< 5) && (> 0))" do
          rhs = value_domain_equal_to(2)
          expect((subject / rhs).to_s).to eq "((< 5) && (> 0))"
        end

        # TODO: Fix bad value-domain division before 1.14.0 GA release.
        #it "/ ((< 10) && (> 0)) should be ((< 10) && (> 0))" do
        #  rhs = value_domain_greater_than(0)
        #  rhs = rhs.intersection(value_domain_less_than(10))
        #  File.open("dump", "w") { |io| PP.pp(subject / rhs, io) }
        #  expect((subject / rhs).to_s).to eq "((< 10) && (> 0))"
        #end
      end

      context "(== 0)" do
        subject { value_domain_equal_to(0) }

        it "narrowed by == ((== 3) || (== 4)) should be (== Nil)" do
          rhs = value_domain_equal_to(3).union(value_domain_equal_to(4))
          expect(subject.narrow(Operator::EQ, rhs).to_s).to eq "(== Nil)"
        end
      end
    end

    private
    def value_domain_equal_to(val)
      ValueDomain.equal_to(val, logical_right_shift?)
    end

    def value_domain_less_than(val)
      ValueDomain.less_than(val, logical_right_shift?)
    end

    def value_domain_greater_than(val)
      ValueDomain.greater_than(val, logical_right_shift?)
    end

    def value_domain_less_than_or_equal_to(val)
      ValueDomain.less_than_or_equal_to(val, logical_right_shift?)
    end

    def value_domain_greater_than_or_equal_to(val)
      ValueDomain.greater_than_or_equal_to(val, logical_right_shift?)
    end

    def traits
      @adlint.traits
    end
  end

end
end
