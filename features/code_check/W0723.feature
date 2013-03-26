Feature: W0723

  W0723 detects that signed arithmetic-expression may overflow.

  Scenario: an arithmetic operation in initializer of a global variable
    Given a target source named "fixture.c" with:
      """
      static int i = 5;
      static unsigned int j = (unsigned int) &i + 1; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0567 | 2    | 25     |
      | W0167 | 2    | 45     |

  Scenario: multiplication of two arbitrary `signed short' values
    Given a target source named "fixture.c" with:
      """
      static int foo(short a, short b)
      {
          return a * b; /* W0723 should not be output */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 22     |
      | W0104 | 1    | 31     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiplication of two arbitrary `signed int' values
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a * b; /* W0723 */
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
      | W0628 | 1    | 12     |
