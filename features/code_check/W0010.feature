Feature: W0010

  W0010 detects that a side-effect may occur in the conditional-expression.

  Scenario: postfix-increment-expression and postfix-decrement-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a > 0) ? b++ : b--; /* W0010 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0629 | 1    | 12     |
      | W0010 | 3    | 20     |
      | W0628 | 1    | 12     |

  Scenario: object-specifier and postfix-decrement-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a > 0) ? b : b--; /* W0010 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0629 | 1    | 12     |
      | W0010 | 3    | 20     |
      | W0086 | 3    | 20     |
      | W0628 | 1    | 12     |

  Scenario: function-call-expression and constant-specifier
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a > 0) ? foo(1, b) : 0; /* W0010 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0556 | 3    | 25     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0010 | 3    | 20     |
      | W0086 | 3    | 20     |
      | W0555 | 1    | 12     |

  Scenario: additive-expression and multiplicative-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a > 0) ? b / a : a + b; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 32     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0501 | 3    | 20     |
      | W0628 | 1    | 12     |
