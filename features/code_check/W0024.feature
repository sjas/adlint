Feature: W0024

  W0024 detects that a pointer variable appears in the increment or decrement
  operation.

  Scenario: postfix-increment-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p)
      {
          return p++; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 13     |
      | W0628 | 1    | 12     |

  Scenario: prefix-increment-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p)
      {
          return ++p; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 12     |
      | W0424 | 3    | 14     |
      | W0628 | 1    | 12     |

  Scenario: a pointer variable as lhs of the additive-expression
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return p + 1; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 16     |
      | W0024 | 3    | 14     |
      | W0424 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a pointer variable as rhs of the additive-expression
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return 1 + p; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 12     |
      | W0024 | 3    | 14     |
      | W0424 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: a pointer variable as lhs of the additive-expression
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p)
      {
          p =  p + 1; /* W0024 */
          return p;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 14     |
      | W0024 | 3    | 12     |
      | W0424 | 3    | 10     |
      | W0628 | 1    | 12     |

  Scenario: postfix-decrement-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p)
      {
          return p--; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 13     |
      | W0424 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: prefix-decrement-expression with a pointer variable
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p)
      {
          return --p; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 12     |
      | W0424 | 3    | 14     |
      | W0628 | 1    | 12     |

  Scenario: a pointer variable as lhs of the additive-expression
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return p - 1; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 16     |
      | W0024 | 3    | 14     |
      | W0424 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a pointer variable as rhs of the additive-expression
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return 1 - p; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 12     |
      | W0024 | 3    | 14     |
      | W0424 | 3    | 16     |
      | W0628 | 1    | 12     |

  Scenario: pointer variables are incremented and decremented
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p, const int *q)
      {
          return p++ & q--; /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 13     |
      | W0024 | 3    | 19     |
      | W0424 | 3    | 18     |
      | W0424 | 3    | 13     |
      | W0424 | 3    | 19     |
      | W0628 | 1    | 12     |

 Scenario: pointer variables are incremented in arithmetic operations
    Given a target source named "fixture.c" with:
      """
      const int *func(const int *p, const int *q)
      {
          return (p++) * (q++); /* W0024 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0024 | 3    | 14     |
      | W0024 | 3    | 22     |
      | W0023 | 3    | 18     |
      | W0424 | 3    | 12     |
      | W0424 | 3    | 20     |
      | W1052 | 3    | 18     |
      | W0628 | 1    | 12     |

  Scenario: pointer variable plus 2
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return p + 2; /* Ok but W0023 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 16     |
      | W0023 | 3    | 14     |
      | W0424 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: pointer variable minus 2
    Given a target source named "fixture.c" with:
      """
      const int *func(const int * const p)
      {
          return p - 2; /* Ok but W0023 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W9003 | 3    | 16     |
      | W0023 | 3    | 14     |
      | W0424 | 3    | 12     |
      | W0628 | 1    | 12     |
