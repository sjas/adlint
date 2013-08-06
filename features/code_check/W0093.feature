Feature: W0093

  W0093 detects that a multiplicative-expression may cause division-by-zero.

  Scenario: narrowing denominator variable by an iteration controlling
            variable which has same value domain of the denominator
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int k;

          for (int i = 0; i < 10; i++) {
              for (int j = 0; j < 10; j++) {
                  if (i == j) {
                      k = j / i; /* W0093 */
                  }
                  else {
                      k = j / i; /* W0093 */
                  }
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0093 | 8    | 23     |
      | C1000 |      |        |
      | C1006 | 5    | 14     |
      | W0093 | 11   | 23     |
      | C1000 |      |        |
      | C1006 | 5    | 14     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: narrowing denominator variable by an iteration controlling
            variable which has narrower value domain than the denominator
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int k;

          for (int i = 0; i < 10; i++) {
              for (int j = 3; j < 5; j++) {
                  if (i == j) {
                      k = j / i; /* OK */
                  }
                  else {
                      k = j / i; /* W0093 */
                  }
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0093 | 11   | 23     |
      | C1000 |      |        |
      | C1006 | 5    | 14     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: narrowing denominator variable by an iteration controlling
            variable which has narrower value domain contains zero
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int k;

          for (int i = -5; i < 5; i++) {
              for (int j = -1; j < 2; j++) {
                  if (i == j) {
                      k = j / i; /* W0093 */
                  }
                  else {
                      k = j / i; /* OK */
                  }
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0093 | 8    | 23     |
      | C1000 |      |        |
      | C1006 | 5    | 14     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
