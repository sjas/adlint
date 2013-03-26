Feature: W0013

  W0013 detects that a continue-statement is used in iteration-statement.

  Scenario: a continue-statement in for-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i;
          int j;

          for (i = 1, j = 0; i < 20; i++) {
              j += 2;
              if ((j % i) == 3) {
                  continue; /* W0013 */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0535 | 6    | 10     |
      | W0013 | 9    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a continue-statement in c99-for-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int j = 0;

          for (int i = 1; i < 20; i++) {
              j += 2;
              if ((j % i) == 3) {
                  continue; /* W0013 */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0013 | 8    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a continue-statement in while-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i = 1;
          int j = 0;

          while (i < 20) {
              i++;
              j += 2;
              if ((j % i) == 3) {
                  continue; /* W0013 */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0013 | 10   | 13     |
      | W0628 | 1    | 13     |

  Scenario: a continue-statement in do-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i = 1;
          int j = 0;

          do {
              i++;
              j += 2;
              if ((j % i) == 3) {
                  continue; /* W0013 */
              }
          } while (i < 20);
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0013 | 10   | 13     |
      | W0628 | 1    | 13     |

  Scenario: no continue-statement in for-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i;
          int j;

          for (i = 1, j = 0; i < 20; i++) {
              j += 2;
              if ((j % i) == 3) {
                  break; /* OK */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0535 | 6    | 10     |
      | W0628 | 1    | 13     |

  Scenario: no continue-statement in c99-for-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int j = 0;

          for (int i = 1; i < 20; i++) {
              j += 2;
              if ((j % i) == 3) {
                  break; /* OK */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: no continue-statement in while-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i = 1;
          int j = 0;

          while (i < 20) {
              i++;
              j += 2;
              if ((j % i) == 3) {
                  break; /* OK */
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: no continue-statement in do-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i = 1;
          int j = 0;

          do {
              i++;
              j += 2;
              if ((j % i) == 3) {
                  break; /* OK */
              }
          } while (i < 20);
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
