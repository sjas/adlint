Feature: W0021

  W0021 detects that a pointer-cast deletes `volatile' qualifier.

  Scenario: casting volatile int pointer to int pointer
    Given a target source named "fixture.c" with:
      """
      int foo(volatile int *p)
      {
          int *q;
          q = (int *) p; /* W0021 */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0021 | 4    | 9      |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 23     |
      | W0105 | 1    | 23     |
      | W0628 | 1    | 5      |

  Scenario: casting volatile const int pointer to int pointer
    Given a target source named "fixture.c" with:
      """
      int foo(volatile const int *p)
      {
          int *q;
          q = (int *) p; /* W0021 */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0019 | 4    | 9      |
      | W0021 | 4    | 9      |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 29     |
      | W0628 | 1    | 5      |

  Scenario: assigning compatible volatile pointers
    Given a target source named "fixture.c" with:
      """
      int foo(volatile int *p)
      {
          volatile int *q;
          q = p; /* OK */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 23     |
      | W0105 | 1    | 23     |
      | W0628 | 1    | 5      |

 Scenario: casting volatile int array pointer to int pointer
    Given a target source named "fixture.c" with:
      """
      volatile int a[] = { 0, 1, 2 };

      int foo(void)
      {
          volatile int *p = a; /* OK */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0117 | 3    | 5      |
      | W0100 | 5    | 19     |
      | W0628 | 3    | 5      |
