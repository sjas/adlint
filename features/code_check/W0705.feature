Feature: W0705

  W0705 detects that an array subscript may cause out of bound access of the
  array object.

  Scenario: array-subscript-expression with non-constant subscript may cause
            OOB access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          if (i >= 0 && i < 5) {
              int j = a[i + 1]; /* W0705 */
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
      | W0705 | 6    | 21     |
      | W0100 | 6    | 13     |
      | W0104 | 3    | 13     |
      | W1071 | 3    | 5      |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript may cause
            OOB access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i >= 0 && i < 4) {
              j = a[i - 1]; /* W0705 */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0705 | 7    | 17     |
      | W0104 | 3    | 13     |
      | W0490 | 6    | 9      |
      | W0499 | 6    | 9      |
      | W0502 | 6    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript may cause
            OOB access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i >= 0 && i < 3) {
              a[i + 3] = 0; /* W0705 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W0705 | 6    | 13     |
      | W0104 | 3    | 14     |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with non-constant subscript may cause OOB
            access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i >= 0 && i < 5) {
              j = *(a + i - 1); /* W0705 */
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
      | W0024 | 7    | 21     |
      | W0705 | 7    | 14     |
      | W0104 | 3    | 13     |
      | W0490 | 6    | 9      |
      | W0499 | 6    | 9      |
      | W0502 | 6    | 9      |
      | W0498 | 7    | 14     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with non-constant subscript may cause OOB
            access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i >= 0 && i < 5) {
              *(2 + a + i - 1) = 0; /* W0705 */
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
      | W0023 | 6    | 17     |
      | W9003 | 6    | 23     |
      | W0024 | 6    | 21     |
      | W0705 | 6    | 10     |
      | W0104 | 3    | 14     |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0498 | 6    | 10     |
      | W0628 | 3    | 6      |

  Scenario: array-subscript-expression with non-constant subscript must not
            cuase OOB access in initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          if (i > 0 && i <= 5) {
              int j = a[i - 1]; /* OK */
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
      | W0100 | 6    | 13     |
      | W0104 | 3    | 13     |
      | W1071 | 3    | 5      |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript must not
            cause OOB access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i >= 0 && i < 4) {
              j = a[i + 1]; /* OK */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0490 | 6    | 9      |
      | W0499 | 6    | 9      |
      | W0502 | 6    | 9      |
      | W0628 | 3    | 5      |

  Scenario: array-subscript-expression with non-constant subscript must not
            cause OOB access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i >= 0 && i < 3) {
              a[i + 2] = 0; /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 14     |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with non-constant subscript must not cause
            OOB access in rhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          int j = 0;
          if (i > 0 && i < 6) {
              j = *(a + i - 1); /* OK */
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
      | W0024 | 7    | 21     |
      | W0104 | 3    | 13     |
      | W0490 | 6    | 9      |
      | W0499 | 6    | 9      |
      | W0502 | 6    | 9      |
      | W0498 | 7    | 14     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with non-constant subscript must not cause
            OOB access in lhs operand of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      void foo(int i)
      {
          if (i >= 0 && i < 5) {
              *(2 + a + i - 2) = 0; /* OK */
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
      | W0023 | 6    | 17     |
      | W9003 | 6    | 23     |
      | W0023 | 6    | 21     |
      | W0104 | 3    | 14     |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0498 | 6    | 10     |
      | W0628 | 3    | 6      |

  Scenario: indirection-expression with non-constant subscript should not cause
            OOB access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          if (i >= 0 && i < 5) {
              int j = *(a + i++); /* OK */
              int k = *(a + i - 1); /* OK */
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
      | W9003 | 6    | 24     |
      | W0023 | 6    | 21     |
      | W9003 | 7    | 23     |
      | W0023 | 7    | 21     |
      | W9003 | 7    | 27     |
      | W0024 | 7    | 25     |
      | W0100 | 6    | 13     |
      | W0100 | 7    | 13     |
      | W1071 | 3    | 5      |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0498 | 7    | 18     |
      | W0628 | 3    | 5      |

  Scenario: indirection-expression with non-constant subscript may and should
            not cause OOB access in an initializer
    Given a target source named "fixture.c" with:
      """
      extern int a[5];

      int foo(int i)
      {
          if (i >= 0 && i < 5) {
              int j = *(a + ++i); /* W0705 */
              int k = *(a + i - 1); /* OK */
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
      | W9003 | 6    | 23     |
      | W0023 | 6    | 21     |
      | W0705 | 6    | 18     |
      | W9003 | 7    | 23     |
      | W0023 | 7    | 21     |
      | W9003 | 7    | 27     |
      | W0024 | 7    | 25     |
      | W0100 | 6    | 13     |
      | W0100 | 7    | 13     |
      | W1071 | 3    | 5      |
      | W0490 | 5    | 9      |
      | W0499 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0498 | 7    | 18     |
      | W0628 | 3    | 5      |
