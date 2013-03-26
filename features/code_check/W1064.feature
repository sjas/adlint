Feature: W1064

  W1064 detects that an integer constant is specified to the case-label in the
  switch-statement with an enum typed controlling variable.

  Scenario: an integer constant
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(const enum Color c)
      {
          switch (c) {
          case 0: /* W1064 */
              return 1;
          case 1: /* W1064 */
              return 2;
          default:
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W1064 | 6    | 10     |
      | W1064 | 8    | 10     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: enumerator of the same enum type
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(const enum Color c)
      {
          switch (c) {
          case RED: /* OK */
              return 1;
          case BLUE: /* OK */
              return 2;
          default:
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: enum typed variable of the same enum type
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(const enum Color c)
      {
          const enum Color col = RED;

          switch (c) {
          case col: /* OK */
              return 1;
          case BLUE: /* OK */
              return 2;
          default:
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |
