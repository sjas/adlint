Feature: W1059

  W1059 detects that a value of enum typed expression is passed to a non-enum
  typed parameter.

  Scenario: passing a value of the enum typed constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(int);

      static void bar(void)
      {
          foo(RED + 1); /* W1059 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 15     |
      | W9003 | 7    | 13     |
      | W1059 | 7    | 13     |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: passing a value of the enum typed non-constant expression
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(int);

      static void bar(const enum Color c)
      {
          foo(c); /* W1059 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 9      |
      | W1059 | 7    | 9      |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: passing a value of consistently typed constant expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(int);

      static void bar(void)
      {
          foo(1 + 1); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: passing a value of inconsistently typed constant expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(int);

      static void bar(void)
      {
          foo(1.0 * .1); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 3    | 13     |
      | W0226 | 5    | 13     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |
