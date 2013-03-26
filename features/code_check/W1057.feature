Feature: W1057

  W1057 detects that a value of enum typed non-constant expression is assigned
  to the inconsistently enum typed variable.

  Scenario: assigning a value of the consistently enum typed constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(void)
      {
          enum Color c = RED;

          c = BLUE; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: assigning a value of the consistently enum typed non-constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(const enum Color p)
      {
          enum Color c = RED;

          c = p; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: assigning a value of the inconsistently enum typed constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(void)
      {
          enum Color c = RED;

          c = ORANGE; /* OK but W0729 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W9003 | 8    | 9      |
      | W0729 | 8    | 7      |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: assigning a value of the inconsistently enum typed non-constant
            expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(const enum Fruit f)
      {
          enum Color c = RED;

          c = f; /* W1057 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W0727 | 8    | 9      |
      | W9003 | 8    | 9      |
      | W1057 | 8    | 7      |
      | W1062 | 8    | 7      |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: assigning a value of `int' typed constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(void)
      {
          enum Color c = RED;

          c = 2; /* OK but W1054 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W9003 | 8    | 9      |
      | W1054 | 8    | 7      |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: assigning a value of `int' typed non-constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static void foo(const int i)
      {
          enum Color c = RED;

          c = i + 1; /* OK but W1062 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 13     |
      | W0723 | 8    | 11     |
      | W0727 | 8    | 11     |
      | W9003 | 8    | 11     |
      | W1054 | 8    | 7      |
      | W1062 | 8    | 7      |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |
