Feature: W1070

  W1070 detects that a `switch' statement can be translated into if-else
  statement because there are only two execution paths.

  Scenario: `switch' statement which has only two execution paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* W1070 */
          case 0:
              return 4;
          default:
              return 8;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W1070 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has only two execution paths and doesn't
            have `default' clause
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* W1070 */
          case 0:
              return 4;
          case 1:
              return 6;
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
      | W0003 | 3    | 5      |
      | W1070 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `switch' statement which has only two execution paths and the
            control never reaches to one of that paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          if (i > 5) {
              switch (i) { /* W1070 */
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

  Scenario: `switch' statement which has only one execution path
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* OK */
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
              switch (i) { /* OK */
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

  Scenario: `switch' statement which has three execution paths
    Given a target source named "fixture.c" with:
      """
      static int func(const int i)
      {
          switch (i) { /* OK */
          case 0:
              return 4;
          case 1:
              return 6;
          default:
              return 8;
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
