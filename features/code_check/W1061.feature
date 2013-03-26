Feature: W1061

  W1061 detects that a value of the inconsistently typed non-constant
  expression is passed to a enum typed parameter.

  Scenario: non-constant `int' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern void foo(enum Color);

      static void bar(const int i)
      {
          foo(i + 1); /* W1061 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W1076 | 6    | 13     |
      | W0723 | 8    | 11     |
      | W0727 | 8    | 11     |
      | W9003 | 8    | 11     |
      | W1061 | 8    | 11     |
      | W0629 | 6    | 13     |
      | W0628 | 6    | 13     |

  Scenario: non-constant consistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern void foo(enum Color);

      static void bar(const enum Color c)
      {
          foo(c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W1076 | 6    | 13     |
      | W0629 | 6    | 13     |
      | W0628 | 6    | 13     |

  Scenario: non-constant inconsistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern void foo(enum Color);

      static void bar(const enum Fruit f)
      {
          foo(f); /* W1061 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W1076 | 6    | 13     |
      | W0727 | 8    | 9      |
      | W9003 | 8    | 9      |
      | W1056 | 8    | 9      |
      | W1061 | 8    | 9      |
      | W0629 | 6    | 13     |
      | W0628 | 6    | 13     |

  Scenario: constant consistent `int' typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(enum Color);

      static void bar(void)
      {
          foo(2); /* OK but W1053 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 9      |
      | W1053 | 7    | 9      |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: constant consistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(enum Color);

      static void bar(void)
      {
          foo(RED + 1); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 15     |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: constant inconsistent enum typed expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      extern void foo(enum Color);

      static void bar(void)
      {
          foo(ORANGE + 1); /* OK but W0728 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W1076 | 6    | 13     |
      | W9003 | 8    | 18     |
      | W0727 | 8    | 16     |
      | W9003 | 8    | 16     |
      | W0728 | 8    | 16     |
      | W0629 | 6    | 13     |
      | W0628 | 6    | 13     |
