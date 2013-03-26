Feature: W1062

  W1062 detects that a value of the inconsistently typed non-constant
  expression is assigned to an enum typed variable.

  Scenario: non-constant `int' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(const int i)
      {
          enum Color c;

          c = i + 1; /* W1062 */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W0723 | 8    | 11     |
      | W0727 | 8    | 11     |
      | W9003 | 8    | 11     |
      | W1054 | 8    | 7      |
      | W1062 | 8    | 7      |
      | W0100 | 6    | 16     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |

  Scenario: non-constant consistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern enum Color color(void);

      static enum Color foo(void)
      {
          enum Color c;

          c = color(); /* OK */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 19     |
      | W1076 | 6    | 19     |
      | W0100 | 8    | 16     |
      | W0629 | 6    | 19     |
      | W0628 | 6    | 19     |

  Scenario: non-constant inconsistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern enum Fruit fruit(void);

      static enum Color foo(void)
      {
          enum Color c;

          c = fruit(); /* W1062 */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 19     |
      | W1076 | 6    | 19     |
      | W0727 | 10   | 14     |
      | W9003 | 10   | 14     |
      | W1057 | 10   | 7      |
      | W1062 | 10   | 7      |
      | W0100 | 8    | 16     |
      | W0629 | 6    | 19     |
      | W0628 | 6    | 19     |

  Scenario: constant consistent `int' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static enum Color foo(void)
      {
          enum Color c;

          c = 2; /* OK but W1054 */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 19     |
      | W9003 | 7    | 9      |
      | W1054 | 7    | 7      |
      | W0100 | 5    | 16     |
      | W0629 | 3    | 19     |
      | W0628 | 3    | 19     |

  Scenario: constant consistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static enum Color foo(void)
      {
          enum Color c;

          c = RED + 1; /* OK */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 19     |
      | W9003 | 7    | 15     |
      | W0100 | 5    | 16     |
      | W0629 | 3    | 19     |
      | W0628 | 3    | 19     |

  Scenario: constant inconsistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static enum Color foo(void)
      {
          enum Color c;

          c = ORANGE + 1; /* OK but W0729 */

          return c;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 19     |
      | W9003 | 8    | 18     |
      | W0727 | 8    | 16     |
      | W9003 | 8    | 16     |
      | W0729 | 8    | 7      |
      | W0100 | 6    | 16     |
      | W0629 | 4    | 19     |
      | W0628 | 4    | 19     |
