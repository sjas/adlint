Feature: W0003

  W0003 detects that no default clause is in the switch-statement.

  Scenario: no default clause
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j;

          switch(i) { /* W0003 */
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              break;
          case 3:
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0460 | 17   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 6    | 5      |
      | C1002 | 9    | 5      |
      | C1002 | 12   | 5      |
      | W0104 | 1    | 13     |
      | W0003 | 5    | 5      |
      | W0628 | 1    | 5      |

  Scenario: a default clause at the bottom
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j;

          switch(i) { /* OK */
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              break;
          case 3:
              j = 3;
              break;
          default:
              j = 4;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: a default clause at the middle
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j;

          switch(i) { /* OK */
          case 1:
              j = 1;
              break;
          default:
              j = 4;
              break;
          case 2:
              j = 2;
              break;
          case 3:
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0538 | 9    | 5      |
      | W0628 | 1    | 5      |

  Scenario: a default clause at the top
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j;

          switch(i) { /* OK */
          default:
              j = 4;
              break;
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              break;
          case 3:
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0538 | 6    | 5      |
      | W0628 | 1    | 5      |
