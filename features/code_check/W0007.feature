Feature: W0007

  W0007 detects that the previous case or default clause does not have a
  jump-statement at the last statement.

  Scenario: no jump-statement in the previous case clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
          case 3: /* W0007 */
              j = 3;
              break;
          default:
              j = 0;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0007 | 11   | 5      |
      | W0628 | 1    | 12     |

  Scenario: a break-statement at the middle of the previous case clause
    Given a target source named "fixture.c" with:
      """
      extern int rand(void);

      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          case 2:
              if (rand() == 0) {
                  j = -1;
                  break;
              }
              j = 2;
          case 3: /* W0007 */
              j = 3;
              break;
          default:
              j = 0;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0007 | 17   | 5      |
      | W0532 | 14   | 13     |
      | W0628 | 3    | 12     |

  Scenario: a break-statement at the bottom of the previous case clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              break;
          case 3: /* OK */
              j = 3;
              break;
          default:
              j = 0;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a return-statement at the bottom of the previous case clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              return j;
          case 3: /* OK */
              j = 3;
              break;
          default:
              j = 0;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no jump-statement in the previous default clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          default:
              j = 2;
          case 3: /* W0007 */
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0007 | 11   | 5      |
      | W0538 | 9    | 5      |
      | W0628 | 1    | 12     |

  Scenario: a break-statement at the middle of the previous default clause
    Given a target source named "fixture.c" with:
      """
      extern int rand(void);

      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          default:
              if (rand() == 0) {
                  j = -1;
                  break;
              }
              j = 2;
          case 3: /* W0007 */
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0007 | 17   | 5      |
      | W0532 | 14   | 13     |
      | W0538 | 11   | 5      |
      | W0628 | 3    | 12     |

  Scenario: a break-statement at the bottom of the previous default clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          case 2:
              j = 2;
              break;
          case 3: /* OK */
              j = 3;
              break;
          default:
              j = 0;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a return-statement at the bottom of the previous default clause
    Given a target source named "fixture.c" with:
      """
      static int foo(const int i)
      {
          int j;

          switch (i) {
          case 1:
              j = 1;
              break;
          default:
              j = 2;
              return j;
          case 3: /* OK */
              j = 3;
              break;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0538 | 9    | 5      |
      | W0628 | 1    | 12     |
