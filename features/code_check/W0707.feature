Feature: W0707

  W0707 detects that a constant-expression array subscript must cause out of
  bound access of the array object.

  Scenario: array-subscript-expression with constant subscript must cause OOB
            access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = a[5]; /* W0707 */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0707 | 5    | 15     |
      | W0100 | 5    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with constant subscript must cause OOB
            access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = 0;
          i = a[-1]; /* W0707 */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0707 | 6    | 11     |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with constant subscript must cause OOB
            access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          a[5] = i; /* W0707 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W0707 | 5    | 7      |
      | W0104 | 3    | 14     |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with constant subscript must cause OOB
            access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = 0;
          i = *(a + 5 - 6); /* W0707 */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W9003 | 6    | 15     |
      | W0023 | 6    | 13     |
      | W9003 | 6    | 19     |
      | W0023 | 6    | 17     |
      | W0707 | 6    | 10     |
      | W0498 | 6    | 10     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with constant subscript must cause OOB
            access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          *(a - 1 + 6) = i; /* W0707 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W9003 | 5    | 11     |
      | W0024 | 5    | 9      |
      | W9003 | 5    | 15     |
      | W0023 | 5    | 13     |
      | W0707 | 5    | 6      |
      | W0104 | 3    | 14     |
      | W0498 | 5    | 6      |
      | W0628 | 3    | 6      |

  Scenario: array-subscript-expression with constant subscript must not cause
            OOB access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = a[3]; /* OK */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0100 | 5    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with constant subscript must not cause
            OOB access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = 0;
          i = a[0]; /* OK */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with constant subscript must not cause
            OOB access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          a[4] = i; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 14     |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with constant subscript must not cause OOB
            access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(void)
      {
          int i = 0;
          i = *(a - 2 + 3); /* OK */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W9003 | 6    | 15     |
      | W0023 | 6    | 13     |
      | W9003 | 6    | 19     |
      | W0023 | 6    | 17     |
      | W0498 | 6    | 10     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with constant subscript must not cause OOB
            access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          *(a + 4 - 1) = i; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W9003 | 5    | 11     |
      | W0023 | 5    | 9      |
      | W9003 | 5    | 15     |
      | W0024 | 5    | 13     |
      | W0104 | 3    | 14     |
      | W0498 | 5    | 6      |
      | W0628 | 3    | 6      |
