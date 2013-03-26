Feature: W1058

  W1058 detects that a function of enum return type is returning a value of
  inconsistently enum typed non-constant expression.

  Scenario: returning a value of the consistently enum typed constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(void)
      {
          return RED + 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W9003 | 6    | 18     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |

  Scenario: returning a value of the consistently enum typed non-constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(const enum Color c)
      {
          return c + 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W9003 | 6    | 16     |
      | W0723 | 6    | 14     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |

  Scenario: returning a value of the inconsistently enum typed constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(void)
      {
          return ORANGE + 1; /* OK but W0730 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W9003 | 6    | 21     |
      | W0727 | 6    | 19     |
      | W9003 | 6    | 19     |
      | W0730 | 6    | 19     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |

  Scenario: returning a value of the inconsistently enum typed non-constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(const enum Fruit f)
      {
          return f + 1; /* W1058 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W9003 | 6    | 16     |
      | W0723 | 6    | 14     |
      | W0727 | 6    | 14     |
      | W9003 | 6    | 14     |
      | W1058 | 6    | 14     |
      | W1063 | 6    | 14     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |
