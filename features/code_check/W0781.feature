Feature: W0781

  W0781 detects that there is only one execution path in the switch-statement.

  Scenario: `switch' statement which has only one execution path
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* W0781 */
          default:
              return 8;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0781 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has three execution paths, but the control
            never reaches to only one of that paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          if (i > 5) {
              switch (i) { /* W0781 */
              case 0:
                  return 1;
              case 5:
                  return 2;
              default:
                  return 3;
              }
          }
          return 10;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W9001 | 5    | 9      |
      | W9001 | 6    | 13     |
      | W9001 | 7    | 9      |
      | W9001 | 8    | 13     |
      | W0781 | 4    | 9      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has only two execution paths and the
            control never reaches to one of that paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          if (i > 5) {
              return 0;
          }

          switch (i) { /* OK */
          case 0:
              return 4;
          default:
              switch (i) { /* W0781 */
              case 10:
                  return 5;
              default:
                  return 6;
              }
          }
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W9001 | 12   | 9      |
      | W9001 | 13   | 13     |
      | W0781 | 11   | 9      |
      | W1070 | 11   | 9      |
      | W1070 | 7    | 5      |
      | W9001 | 18   | 5      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has only two execution paths and the
            control never reaches to one of that paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          if (i > 5) {
              switch (i) { /* OK */
              case 5:
                  return 2;
              default:
                  return 3;
              }
          }
          return 10;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W9001 | 5    | 9      |
      | W9001 | 6    | 13     |
      | W0781 | 4    | 9      |
      | W1070 | 4    | 9      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has several execution paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* OK */
          case 5:
              return 2;
          case 6:
              return 3;
          default:
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
