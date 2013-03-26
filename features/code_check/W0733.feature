Feature: W0733

  W0733 detects that both sides of `||' operator are bitwise expression or
  arithmetic expression.

  Scenario: both sides of `||' operator are arithmetic expressions
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a + b) || (c + d); /* W0733 */
          r = (a - b) || (c - d); /* W0733 */
          r = (a * b) || (c * d); /* W0733 */
          r = (a / b) || (c / d); /* W0733 */
          r = (a % b) || (c % d); /* W0733 */

          r = (a += b) || (c -= d); /* W0733 */
          r = (a *= b) || (c /= d); /* W0733 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 5    | 23     |
      | W0723 | 6    | 12     |
      | W0723 | 6    | 23     |
      | W0723 | 7    | 12     |
      | W0723 | 7    | 23     |
      | W0093 | 8    | 12     |
      | W0093 | 8    | 23     |
      | W0093 | 9    | 12     |
      | W0093 | 9    | 23     |
      | W0093 | 12   | 12     |
      | W0093 | 12   | 24     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0733 | 5    | 17     |
      | W0733 | 6    | 17     |
      | W0733 | 7    | 17     |
      | W0733 | 8    | 17     |
      | W0733 | 9    | 17     |
      | W0508 | 11   | 18     |
      | W0733 | 11   | 18     |
      | W0508 | 12   | 18     |
      | W0733 | 12   | 18     |
      | W0108 | 11   | 12     |
      | W0108 | 11   | 24     |
      | W0108 | 12   | 12     |
      | W0108 | 12   | 24     |
      | W0628 | 1    | 13     |

  Scenario: both sides of `&&' operator are bitwise expressions
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a << b) || (c << d); /* W0733 */
          r = (a >> b) || (c >> d); /* W0733 */
          r = (a & b) || (c & d); /* W0733 */
          r = (a ^ b) || (c ^ d); /* W0733 */
          r = (a | b) || (c | d); /* W0733 */

          r = (a &= b) || (c ^= d); /* W0733 */
          r = (a <<= b) || (c >>= d); /* W0733 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 12     |
      | W0572 | 5    | 12     |
      | W0794 | 5    | 12     |
      | W0570 | 5    | 24     |
      | W0572 | 5    | 24     |
      | W0794 | 5    | 24     |
      | W0571 | 6    | 12     |
      | W0572 | 6    | 12     |
      | W0571 | 6    | 24     |
      | W0572 | 6    | 24     |
      | W0572 | 7    | 12     |
      | W0572 | 7    | 23     |
      | W0572 | 8    | 12     |
      | W0572 | 8    | 23     |
      | W0572 | 9    | 12     |
      | W0572 | 9    | 23     |
      | W0572 | 11   | 12     |
      | W0572 | 11   | 24     |
      | W0570 | 12   | 12     |
      | W0572 | 12   | 12     |
      | W0794 | 12   | 12     |
      | W0571 | 12   | 25     |
      | W0572 | 12   | 25     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0733 | 5    | 18     |
      | W0733 | 6    | 18     |
      | W0733 | 7    | 17     |
      | W0733 | 8    | 17     |
      | W0733 | 9    | 17     |
      | W0508 | 11   | 18     |
      | W0733 | 11   | 18     |
      | W0508 | 12   | 19     |
      | W0733 | 12   | 19     |
      | W0108 | 11   | 12     |
      | W0108 | 11   | 24     |
      | W0108 | 12   | 12     |
      | W0108 | 12   | 25     |
      | W0628 | 1    | 13     |

  Scenario: both sides of `||' operator are neither arithmetic nor bitwise
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          /* equality expression */
          r = (a == b) || (c != d); /* OK */

          /* relational expression */
          r = (a < b) || (c > d);   /* OK */
          r = (a <= b) || (c >= d);   /* OK */

          /* logical expression */
          r = (a && b) || (c && d); /* OK */
          r = (a || b) || (c || d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
