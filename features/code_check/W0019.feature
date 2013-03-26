Feature: W0019

  W0019 detects that a pointer-cast deletes `const' qualifier.

  Scenario: casting const int pointer to int pointer
    Given a target source named "fixture.c" with:
      """
      int foo(const int *p)
      {
          int *q;
          q = (int *) p; /* W0019 */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0019 | 4    | 9      |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 20     |
      | W0628 | 1    | 5      |

  Scenario: casting const unsigned short pointer to short pointer
    Given a target source named "fixture.c" with:
      """
      int foo(const unsigned short *p)
      {
          unsigned short *q;
          q = (short *) p; /* W0019 */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0019 | 4    | 9      |
      | W9003 | 4    | 9      |
      | W0100 | 3    | 21     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 5      |

  Scenario: assigning compatible const pointers
    Given a target source named "fixture.c" with:
      """
      int foo(const int *p)
      {
          const int *q;
          q = p; /* OK */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 16     |
      | W0104 | 1    | 20     |
      | W0628 | 1    | 5      |

  Scenario: casting const int array pointer to int pointer
    Given a target source named "fixture.c" with:
      """
      const int a[] = { 0, 1, 2 };

      int foo(void)
      {
          const int *p = a; /* OK */
          return -1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 11     |
      | W0117 | 3    | 5      |
      | W0100 | 5    | 16     |
      | W0628 | 3    | 5      |
