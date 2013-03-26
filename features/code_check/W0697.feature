Feature: W0697

  W0697 detects that some execution paths terminate implicitly without explicit
  `return' statements in the non-void function.

  Scenario: no `return' statement in non-void function
    Given a target source named "fixture.c" with:
      """
      extern int func(void) /* W0697 */
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0697 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a `return' statement is only in a `if' statement
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* W0697 */
      {
          if (value == 0) {
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0697 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: `return' statements are only in a `if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* W0697 */
      {
          if (value == 0) {
              return 0;
          } else if (value == 1) {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0697 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W1069 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `return' statements are in all `case' clauses but not in the
            `default` clause
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* W0697 */
      {
          switch (value) {
          case 1:
              return 0;
          case 2:
              return 1;
          case 3:
              return 2;
          default:
              break;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0697 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a `return' statement in non-void function
    Given a target source named "fixture.c" with:
      """
      extern int func(void) /* OK */
      {
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no implicit termination in all execution paths
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* OK */
      {
          if (value == 0) {
              return 0;
          }
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no implicit termination in `if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* OK */
      {
          if (value == 0) {
              return 0;
          } else if (value == 1) {
              return 1;
          } else {
              return 2;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no implicit termination with `switch' statement
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* OK */
      {
          switch (value) {
          case 1:
              return 0;
          case 2:
              return 1;
          case 3:
              return 2;
          default:
              break;
          }
          return 10;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no implicit termination with `goto' statement
    Given a target source named "fixture.c" with:
      """
      extern int func(int value) /* OK */
      {
          if (value == 10) {
              goto A;
          }
      A:
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1072 | 4    | 9      |
      | W0628 | 1    | 12     |
