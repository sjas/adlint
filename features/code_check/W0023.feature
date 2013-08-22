Feature: W0023

  W0023 detects that a pointer variable appears in the arithmetic operation.

  Scenario: additive-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p)
      {
          const long r = p + 10L; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W9003 | 3    | 24     |
      | W0023 | 3    | 22     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W9003 | 3    | 22     |
      | W0628 | 1    | 6      |

  Scenario: multiplicative-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p)
      {
          const long r = p * 2L; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W9003 | 3    | 24     |
      | W0023 | 3    | 22     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W9003 | 3    | 22     |
      | W0628 | 1    | 6      |

  Scenario: additive-expression with pointer variables
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p, const int * const q)
      {
          const long r = p - q; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0023 | 3    | 22     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W0424 | 3    | 24     |
      | C1000 |      |        |
      | C1005 | 1    | 50     |
      | W1052 | 3    | 22     |
      | W9003 | 3    | 22     |
      | W0628 | 1    | 6      |

  Scenario: multiplicative-expression with pointer variables
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p, const int * const q)
      {
          const long r = p / q; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0023 | 3    | 22     |
      | W0093 | 3    | 22     |
      | C1000 |      |        |
      | C1006 | 1    | 50     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W0424 | 3    | 24     |
      | C1000 |      |        |
      | C1005 | 1    | 50     |
      | W9003 | 3    | 22     |
      | W0628 | 1    | 6      |

  Scenario: additive-expression and multiplicative-expression with
            pointer variables
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p, const int * const q, const int * const r)
      {
          const long s = (p + q) * r; /* W0023 */
          return s;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0023 | 3    | 23     |
      | W0424 | 3    | 21     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W0424 | 3    | 25     |
      | C1000 |      |        |
      | C1005 | 1    | 50     |
      | W1052 | 3    | 23     |
      | W0023 | 3    | 28     |
      | W0424 | 3    | 20     |
      | W0424 | 3    | 30     |
      | C1000 |      |        |
      | C1005 | 1    | 71     |
      | W1052 | 3    | 28     |
      | W9003 | 3    | 28     |
      | W0628 | 1    | 6      |

  Scenario: additive-expression and increment operation with pointer variables
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p, const int * const q)
      {
          const long r = q - p + 1; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0023 | 3    | 22     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 50     |
      | W0424 | 3    | 24     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W1052 | 3    | 22     |
      | W9003 | 3    | 28     |
      | W0024 | 3    | 26     |
      | W0424 | 3    | 22     |
      | W9003 | 3    | 26     |
      | W0498 | 3    | 20     |
      | W0628 | 1    | 6      |

  Scenario: additive-expression with an array vairable
    Given a target source named "fixture.c" with:
      """
      long func(void)
      {
          const long a[] = { 0, 1, 2 };
          const long r = a + 10L; /* W0023 */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W9003 | 4    | 24     |
      | W0023 | 4    | 22     |
      | W9003 | 4    | 22     |
      | W0628 | 1    | 6      |

  Scenario: shift-expression with pointer variables
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p, const int * const q)
      {
          const long r = p << q; /* OK */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0116 | 3    | 22     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0424 | 3    | 20     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W0424 | 3    | 25     |
      | C1000 |      |        |
      | C1005 | 1    | 50     |
      | W9003 | 3    | 22     |
      | W0628 | 1    | 6      |

  Scenario: equality-expression with pointer variables
    Given a target source named "fixture.c" with:
      """
      int func(const int * const p, const int * const q)
      {
          return p != q; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0027 | 3    | 14     |
      | W0628 | 1    | 5      |

  Scenario: assignment-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      long func(const int * const p)
      {
          long r = 0;
          r += p; /* OK */
          return r;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W9003 | 4    | 5      |
      | W0023 | 4    | 7      |
      | W0424 | 4    | 10     |
      | C1000 |      |        |
      | C1005 | 1    | 29     |
      | W9003 | 4    | 5      |
      | W0628 | 1    | 6      |
