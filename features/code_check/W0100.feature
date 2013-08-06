Feature: W0100

  W0100 detects that a variable is not reassigned since the initial value is
  assigned.

  Scenario: reassigning value to an array element of the indefinite subscript
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int a[3]; /* OK not W0100 */
          a[i] = 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0705 | 4    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0104 | 1    | 14     |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 6      |

  Scenario: reassigning value to a nested array element of the indefinite
            subscript
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int a[3][3]; /* OK not W0100 */
          a[i][i] = 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0705 | 4    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0705 | 4    | 10     |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0104 | 1    | 14     |
      | W0950 | 3    | 14     |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 6      |

  Scenario: only reference to a nested array element of the indefinite
            subscript
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int a[3][3]; /* W0100 */
          a[i][i];
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0705 | 4    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0705 | 4    | 10     |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 14     |
      | W0950 | 3    | 14     |
      | W0950 | 3    | 11     |
      | W0085 | 4    | 5      |
      | W0628 | 1    | 6      |
