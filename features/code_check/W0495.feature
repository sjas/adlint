Feature: W0495

  W0495 detects that different arithmetic operators appear with modulo operator
  in an expression without appropriate grouping.

  Scenario: without grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a + b % 5; /* W0495 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0495 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: with appropriate grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a + b) % 5; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: entirely grouped
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a + b % 5); /* W0495 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0495 | 3    | 12     |
      | W0628 | 1    | 12     |
