Feature: W0745

  W0745 detects that an array subscript must cause out of bound access of the
  array object.

  Scenario: array-subscript-expression with non-constant subscript must cause
            OOB access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          if (i < 0) {
              int j = a[i - 1]; /* W0745 */
              return j;
          }
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0723 | 6    | 21     |
      | W0745 | 6    | 21     |
      | W0100 | 6    | 13     |
      | W0104 | 3    | 13     |
      | W1071 | 3    | 5      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript must cause
            OOB access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i > 4) {
              j = a[i + 1]; /* W0745 */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0723 | 7    | 17     |
      | W0745 | 7    | 17     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript must cause
            OOB access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i < -2) {
              a[i + 2] = 0; /* W0745 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W0745 | 6    | 13     |
      | W0104 | 3    | 14     |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with non-constant subscript must cause OOB
            access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i > 5) {
              j = *(a + i + 2); /* W0745 */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W9003 | 7    | 19     |
      | W0023 | 7    | 17     |
      | W9003 | 7    | 23     |
      | W0023 | 7    | 21     |
      | W0745 | 7    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with non-constant subscript must cause OOB
            access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i < 0) {
              *(i + a - 1) = 0; /* W0745 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W9003 | 6    | 11     |
      | W0023 | 6    | 13     |
      | W9003 | 6    | 19     |
      | W0024 | 6    | 17     |
      | W0745 | 6    | 10     |
      | W0104 | 3    | 14     |
      | W0498 | 6    | 10     |
      | W0628 | 3    | 6      |
