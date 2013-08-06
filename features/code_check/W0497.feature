Feature: W0497

  W0497 detects that multiple shift-expressions or relational-expressions or
  equality-expressions appear in an expression without appropriate grouping.

  Scenario: without grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(unsigned int a, unsigned int b)
      {
          return a << 1 < b << 2; /* W0497 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0116 | 3    | 23     |
      | C1000 |      |        |
      | C1006 | 1    | 45     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 45     |
      | W0629 | 1    | 12     |
      | W0497 | 3    | 12     |
      | W0502 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: with appropriate grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(unsigned int a, unsigned int b)
      {
          return (a << 1) < (b << 2); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0116 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0116 | 3    | 26     |
      | C1000 |      |        |
      | C1006 | 1    | 45     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 45     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: entirely grouped
    Given a target source named "fixture.c" with:
      """
      static int foo(unsigned int a, unsigned int b)
      {
          return (a << 1 < b << 2); /* W0497 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0116 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0116 | 3    | 24     |
      | C1000 |      |        |
      | C1006 | 1    | 45     |
      | W0104 | 1    | 29     |
      | W0104 | 1    | 45     |
      | W0629 | 1    | 12     |
      | W0497 | 3    | 12     |
      | W0502 | 3    | 12     |
      | W0628 | 1    | 12     |
