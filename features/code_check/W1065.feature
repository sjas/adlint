Feature: W1065

  W1065 detects that an enum type of the case-label's value is different from
  the enum type of controlling variable.

  Scenario: different enum types
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE, GRAPE };

      static int foo(const enum Color c)
      {
          switch (c) {
          case RED: /* OK */
              return 1;
          case ORANGE: /* W1065 */
              return 2;
          default:
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 4    | 12     |
      | W1065 | 9    | 10     |
      | W1071 | 4    | 12     |
      | W0629 | 4    | 12     |
      | W0628 | 4    | 12     |

  Scenario: same enum types
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(const enum Color c)
      {
          switch (c) {
          case RED: /* OK */
              return 1;
          case GREEN: /* OK */
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

  Scenario: enum type and `int'
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(const enum Color c)
      {
          switch (c) {
          case RED: /* OK */
              return 1;
          case 1: /* OK but W1064 */
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
      | W1064 | 8    | 10     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |
