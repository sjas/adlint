Feature: W1060

  W1060 detects that a function of non-enum return type is returning a value of
  enum typed expression.

  Scenario: returning a value of the enum typed constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int bar(void)
      {
          return RED + 1; /* W1060 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W9003 | 5    | 18     |
      | W9003 | 5    | 16     |
      | W1060 | 5    | 16     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: returning a value of the enum typed non-constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int bar(const enum Color c)
      {
          return c + 1; /* W1060 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W9003 | 5    | 16     |
      | W0723 | 5    | 14     |
      | W9003 | 5    | 14     |
      | W1060 | 5    | 14     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: returning a value of consistently typed constant expression
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          return 1 + 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: returning a value of inconsistently typed constant expression
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          return 1.0 * .1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0226 | 3    | 16     |
      | W0362 | 3    | 5      |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
