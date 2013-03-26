Feature: W0734

  W0734 detects that left side of logical expression is bitwise expression or
  arithmetic expression.

  Scenario: left side of `&&' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = (a + b) && c; /* W0734 */
          r = (a - b) && c; /* W0734 */
          r = (a * b) && c; /* W0734 */
          r = (a / b) && c; /* W0734 */
          r = (a % b) && c; /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 6    | 12     |
      | W0723 | 7    | 12     |
      | W0093 | 8    | 12     |
      | W0093 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0628 | 1    | 13     |

  Scenario: left side of `&&' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a + b) && (c == d); /* W0734 */
          r = (a - b) && (c = d); /* W0734 */
          r = (a * b) && (c && d); /* W0734 */
          r = (a / b) && (c < d); /* W0734 */
          r = (a / b) && (c != d); /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 6    | 12     |
      | W0723 | 7    | 12     |
      | W0093 | 8    | 12     |
      | W0093 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0508 | 6    | 17     |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0108 | 6    | 23     |
      | W0628 | 1    | 13     |

  Scenario: left side of `||' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = (a + b) || c; /* W0734 */
          r = (a - b) || c; /* W0734 */
          r = (a * b) || c; /* W0734 */
          r = (a / b) || c; /* W0734 */
          r = (a % b) || c; /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 6    | 12     |
      | W0723 | 7    | 12     |
      | W0093 | 8    | 12     |
      | W0093 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0628 | 1    | 13     |

  Scenario: left side of `||' operator is an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a + b) || (c == d); /* W0734 */
          r = (a - b) || (c = d); /* W0734 */
          r = (a * b) || (c || d); /* W0734 */
          r = (a / b) || (c < d); /* W0734 */
          r = (a / b) || (c != d); /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 6    | 12     |
      | W0723 | 7    | 12     |
      | W0093 | 8    | 12     |
      | W0093 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0508 | 6    | 17     |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0108 | 6    | 23     |
      | W0628 | 1    | 13     |

  Scenario: left side of `&&' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = (a << b) && c; /* W0734 */
          r = (a >> b) && c; /* W0734 */
          r = (a & b) && c; /* W0734 */
          r = (a ^ b) && c; /* W0734 */
          r = (a | b) && c; /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 12     |
      | W0572 | 5    | 12     |
      | W0794 | 5    | 12     |
      | W0571 | 6    | 12     |
      | W0572 | 6    | 12     |
      | W0572 | 7    | 12     |
      | W0572 | 8    | 12     |
      | W0572 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0628 | 1    | 13     |

  Scenario: left side of `||' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c)
      {
          int r;

          r = (a << b) || c; /* W0734 */
          r = (a >> b) || c; /* W0734 */
          r = (a & b) || c; /* W0734 */
          r = (a ^ b) || c; /* W0734 */
          r = (a | b) || c; /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 12     |
      | W0572 | 5    | 12     |
      | W0794 | 5    | 12     |
      | W0571 | 6    | 12     |
      | W0572 | 6    | 12     |
      | W0572 | 7    | 12     |
      | W0572 | 8    | 12     |
      | W0572 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 36     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0628 | 1    | 13     |

  Scenario: left side of `&&' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a << b) && (c == d); /* W0734 */
          r = (a >> b) && (c = d); /* W0734 */
          r = (a & b) && (c && d); /* W0734 */
          r = (a ^ b) && (c < d); /* W0734 */
          r = (a | b) && (c != d); /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 12     |
      | W0572 | 5    | 12     |
      | W0794 | 5    | 12     |
      | W0571 | 6    | 12     |
      | W0572 | 6    | 12     |
      | W0572 | 7    | 12     |
      | W0572 | 8    | 12     |
      | W0572 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0508 | 6    | 18     |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0108 | 6    | 24     |
      | W0628 | 1    | 13     |

  Scenario: left side of `||' operator is a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static void func(int a, int b, int c, int d)
      {
          int r;

          r = (a << b) || (c == d); /* W0734 */
          r = (a >> b) || (c = d); /* W0734 */
          r = (a & b) || (c && d); /* W0734 */
          r = (a ^ b) || (c < d); /* W0734 */
          r = (a | b) || (c != d); /* W0734 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0570 | 5    | 12     |
      | W0572 | 5    | 12     |
      | W0794 | 5    | 12     |
      | W0571 | 6    | 12     |
      | W0572 | 6    | 12     |
      | W0572 | 7    | 12     |
      | W0572 | 8    | 12     |
      | W0572 | 9    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 43     |
      | W0629 | 1    | 13     |
      | W0734 | 5    | 9      |
      | W0508 | 6    | 18     |
      | W0734 | 6    | 9      |
      | W0734 | 7    | 9      |
      | W0734 | 8    | 9      |
      | W0734 | 9    | 9      |
      | W0108 | 6    | 24     |
      | W0628 | 1    | 13     |
