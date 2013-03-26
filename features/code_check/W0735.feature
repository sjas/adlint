Feature: W0735

  W0735 detects that right side of logical expression is bitwise expression or
  arithmetic expression.

  Scenario: right side of `&&' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = a && (b + c); /* W0735 */
          r = a && (b - c); /* W0735 */
          r = a && (b * c); /* W0735 */
          r = a && (b / c); /* W0735 */
          r = a && (b % c); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 17     |
      | W0723 | 6    | 17     |
      | W0723 | 7    | 17     |
      | W0093 | 8    | 17     |
      | W0093 | 9    | 17     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 14     |
      | W0735 | 6    | 14     |
      | W0735 | 7    | 14     |
      | W0735 | 8    | 14     |
      | W0735 | 9    | 14     |
      | W0628 | 1    | 13     |

  Scenario: right side of `&&' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a == b) && (c + d); /* W0735 */
          r = (a = b) && (c - d); /* W0735 */
          r = (a && b) && (c * d); /* W0735 */
          r = (a < b) && (c / d); /* W0735 */
          r = (a != b) && (c % d); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 24     |
      | W0723 | 6    | 23     |
      | W0723 | 7    | 24     |
      | W0093 | 8    | 23     |
      | W0093 | 9    | 24     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 21     |
      | W0735 | 6    | 20     |
      | W0735 | 7    | 21     |
      | W0735 | 8    | 20     |
      | W0735 | 9    | 21     |
      | W0108 | 6    | 12     |
      | W0628 | 1    | 13     |

  Scenario: right side of `||' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = a || (b + c); /* W0735 */
          r = a || (b - c); /* W0735 */
          r = a || (b * c); /* W0735 */
          r = a || (b / c); /* W0735 */
          r = a || (b % c); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 17     |
      | W0723 | 6    | 17     |
      | W0723 | 7    | 17     |
      | W0093 | 8    | 17     |
      | W0093 | 9    | 17     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 14     |
      | W0735 | 6    | 14     |
      | W0735 | 7    | 14     |
      | W0735 | 8    | 14     |
      | W0735 | 9    | 14     |
      | W0628 | 1    | 13     |

  Scenario: right side of `||' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a == b) || (c + d); /* W0735 */
          r = (a = b) || (c - d); /* W0735 */
          r = (a || b) || (c * d); /* W0735 */
          r = (a < b) || (c / d); /* W0735 */
          r = (a != b) || (c % d); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 24     |
      | W0723 | 6    | 23     |
      | W0723 | 7    | 24     |
      | W0093 | 8    | 23     |
      | W0093 | 9    | 24     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 21     |
      | W0735 | 6    | 20     |
      | W0735 | 7    | 21     |
      | W0735 | 8    | 20     |
      | W0735 | 9    | 21     |
      | W0108 | 6    | 12     |
      | W0628 | 1    | 13     |

  Scenario: right side of `&&' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = a && (b << c); /* W0735 */
          r = a && (b >> c); /* W0735 */
          r = a && (b & c); /* W0735 */
          r = a && (b ^ c); /* W0735 */
          r = a && (b | c); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 17     |
      | W0572 | 5    | 17     |
      | W0794 | 5    | 17     |
      | W0571 | 6    | 17     |
      | W0572 | 6    | 17     |
      | W0572 | 7    | 17     |
      | W0572 | 8    | 17     |
      | W0572 | 9    | 17     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 14     |
      | W0735 | 6    | 14     |
      | W0735 | 7    | 14     |
      | W0735 | 8    | 14     |
      | W0735 | 9    | 14     |
      | W0628 | 1    | 13     |

  Scenario: right side of `||' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = a || (b << c); /* W0735 */
          r = a || (b >> c); /* W0735 */
          r = a || (b & c); /* W0735 */
          r = a || (b ^ c); /* W0735 */
          r = a || (b | c); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 17     |
      | W0572 | 5    | 17     |
      | W0794 | 5    | 17     |
      | W0571 | 6    | 17     |
      | W0572 | 6    | 17     |
      | W0572 | 7    | 17     |
      | W0572 | 8    | 17     |
      | W0572 | 9    | 17     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 14     |
      | W0735 | 6    | 14     |
      | W0735 | 7    | 14     |
      | W0735 | 8    | 14     |
      | W0735 | 9    | 14     |
      | W0628 | 1    | 13     |

  Scenario: right side of `&&' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a == b) && (c << d); /* W0735 */
          r = (a = b) && (c >> d); /* W0735 */
          r = (a && b) && (c & d); /* W0735 */
          r = (a < b) && (c ^ d); /* W0735 */
          r = (a != b) && (c | d); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 24     |
      | W0572 | 5    | 24     |
      | W0794 | 5    | 24     |
      | W0571 | 6    | 23     |
      | W0572 | 6    | 23     |
      | W0572 | 7    | 24     |
      | W0572 | 8    | 23     |
      | W0572 | 9    | 24     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 21     |
      | W0735 | 6    | 20     |
      | W0735 | 7    | 21     |
      | W0735 | 8    | 20     |
      | W0735 | 9    | 21     |
      | W0108 | 6    | 12     |
      | W0628 | 1    | 13     |

  Scenario: right side of `||' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a == b) || (c << d); /* W0735 */
          r = (a = b) || (c >> d); /* W0735 */
          r = (a && b) || (c & d); /* W0735 */
          r = (a < b) || (c ^ d); /* W0735 */
          r = (a != b) || (c | d); /* W0735 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 24     |
      | W0572 | 5    | 24     |
      | W0794 | 5    | 24     |
      | W0571 | 6    | 23     |
      | W0572 | 6    | 23     |
      | W0572 | 7    | 24     |
      | W0572 | 8    | 23     |
      | W0572 | 9    | 24     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0735 | 5    | 21     |
      | W0735 | 6    | 20     |
      | W0735 | 7    | 21     |
      | W0735 | 8    | 20     |
      | W0735 | 9    | 21     |
      | W0108 | 6    | 12     |
      | W0628 | 1    | 13     |
