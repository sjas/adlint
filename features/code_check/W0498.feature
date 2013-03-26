Feature: W0498

  W0498 detects that different operators of the same priority appear in an
  expression without appropriate grouping.

  Scenario: multiple additive-expressions in an expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a + b - 5; /* W0498 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0723 | 3    | 18     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0498 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple additive-expressions in an expression with grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a + (b - 5); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 19     |
      | W0723 | 3    | 14     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple additive-expressions in an expression with large grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a + b - 5); /* W0498 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0723 | 3    | 19     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0498 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple multiplicative-expressions in an expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a * b / 5; /* W0498 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0498 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple multiplicative-expressions in an expression with grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a * (b / 5); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple multiplicative-expressions in an expression grouped
            entirely
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a * b / 5); /* W0498 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0498 | 3    | 12     |
      | W0628 | 1    | 12     |
