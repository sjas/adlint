Feature: W1063

  W1063 detects that a function of enum return type is returning a value of the
  inconsistently typed non-constant expression.

  Scenario: returning a value of the non-constant `int' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static enum Color foo(const enum Color c)
      {
          int i = 0;

          if (c == RED) {
              i = 2;
          }

          return i + 1; /* W1063 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 19     |
      | W9003 | 11   | 14     |
      | W1055 | 11   | 14     |
      | W1063 | 11   | 14     |
      | W0629 | 3    | 19     |
      | W0628 | 3    | 19     |

  Scenario: returning a value of the non-constant `double' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static enum Color foo(const enum Color c)
      {
          double d = .0;

          if (c == RED) {
              d = .2;
          }

          return d + 1.0; /* W1063 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 19     |
      | W9003 | 11   | 14     |
      | W1055 | 11   | 14     |
      | W1063 | 11   | 14     |
      | W0629 | 3    | 19     |
      | W0628 | 3    | 19     |

  Scenario: returning a value of the non-constant same enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern enum Color foo(void);

      static enum Color bar(void)
      {
          return foo() + 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 19     |
      | W1076 | 5    | 19     |
      | W9003 | 7    | 20     |
      | W0723 | 7    | 18     |
      | W0629 | 5    | 19     |
      | W0628 | 5    | 19     |

  Scenario: returning a value of the non-constant inconsistent enum typed
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern enum Fruit foo(void);

      static enum Color bar(void)
      {
          return foo() + 1; /* W1063 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 19     |
      | W1076 | 6    | 19     |
      | W9003 | 8    | 20     |
      | W0723 | 8    | 18     |
      | W0727 | 8    | 18     |
      | W9003 | 8    | 18     |
      | W1058 | 8    | 18     |
      | W1063 | 8    | 18     |
      | W0629 | 6    | 19     |
      | W0628 | 6    | 19     |

  Scenario: returning a value of the constant same enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static enum Color foo(void)
      {
          return BLUE; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 19     |
      | W0629 | 3    | 19     |
      | W0628 | 3    | 19     |
