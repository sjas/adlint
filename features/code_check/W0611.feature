Feature: W0611

  W0611 detects that a controlling expression of the iteration-statement always
  be true.

  Scenario: controlling variable of for-statement is not updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          for (; i < 10; ) { /* W0611 */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0534 | 4    | 10     |
      | W0609 | 4    | 14     |
      | W0708 | 5    | 10     |
      | W0611 | 4    | 14     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: controlling variable of for-statement is updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          for (; i < 10; i++) { /* OK */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0534 | 4    | 10     |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: controlling variable of while-statement is not updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          while (i < 10) { /* W0611 */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0609 | 4    | 14     |
      | W0611 | 4    | 14     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: controlling variable of while-statement is updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          while (i < 10) { /* OK */
              i++;
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: controlling variable of do-statement is not updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          do {
              j++;
          } while (i < 10); /* W0611 */
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0609 | 6    | 16     |
      | W0611 | 6    | 16     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: controlling variable of do-statement is updated
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0, j = 0;
          do {
              i++;
              j++;
          } while (i < 10); /* OK */
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 12     |
