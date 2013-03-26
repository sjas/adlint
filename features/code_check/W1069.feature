Feature: W1069

  W1069 detects that no trailing `else' clause is found in this `if-else-if'
  statements chain.

  Scenario: no trailing `else' in `if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 2) { /* W1069 */
              return 0;
          }
          else if (i == 4) {
              return 1;
          }
          return 2;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W1069 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: no trailing `else' in `if-else-if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 2) { /* W1069 */
              return 0;
          }
          else if (i == 4) {
              return 1;
          }
          else if (i == 6) {
              return 2;
          }
          return 4;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W1069 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `else' clause at the last of `if-else-if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 2) { /* OK */
              return 0;
          }
          else if (i == 4) {
              return 1;
          }
          else if (i == 6) {
              return 2;
          }
          else {
              return 3;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: standalone `if' statement
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 2) { /* OK */
              return 0;
          }
          return 10;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: `else' clause at the last of `if-else-if' statements chain
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 2) { /* OK */
              return 0;
          }
          else if (i == 4) {
              return 1;
          }
          else {
              return 2;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: incomplete `if-else-if' statement chain in a complete `if-else'
            statement
    Given a target source named "fixture.c" with:
      """
      static void foo(int i)
      {
          if (i == 0) {
              return;
          }
          else {
              if (i == 1) { /* W1069 */
              }
              else if (i == 2) {
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 21     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W1069 | 7    | 9      |
      | W0628 | 1    | 13     |
