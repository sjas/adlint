Feature: W0833

  W0833 detects that an integer-constant has a long-long-suffix `LL'.

  Scenario: LL-ed decimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long long ll = 123LL; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 16     |
      | W0117 | 1    | 11     |
      | W0834 | 1    | 1      |

  Scenario: LL-ed octal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long long ll = 0123LL; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 16     |
      | W0117 | 1    | 11     |
      | W0529 | 1    | 16     |
      | W0834 | 1    | 1      |

  Scenario: LL-ed hexadecimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long long ll = 0x123LL; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 16     |
      | W0117 | 1    | 11     |
      | W0834 | 1    | 1      |

  Scenario: ULL-ed decimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      unsigned long long ull = 123ULL; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 26     |
      | W0117 | 1    | 20     |
      | W0834 | 1    | 1      |

  Scenario: ULL-ed octal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      unsigned long long ull = 0123LLU; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 26     |
      | W0117 | 1    | 20     |
      | W0529 | 1    | 26     |
      | W0834 | 1    | 1      |

  Scenario: ULL-ed hexadecimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      unsigned long long ull = 0x123LLU; /* W0833 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0833 | 1    | 26     |
      | W0117 | 1    | 20     |
      | W0834 | 1    | 1      |

  Scenario: LL-ed decimal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          long long ll;
          ll = 123LL; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 10     |
      | W0100 | 3    | 15     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: LL-ed octal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          long long ll;
          ll = 0123LL; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 10     |
      | W0100 | 3    | 15     |
      | W0834 | 3    | 5      |
      | W0529 | 4    | 10     |
      | W0628 | 1    | 6      |

  Scenario: LL-ed hexadecimal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          long long ll;
          ll = 0x123LL; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 10     |
      | W0100 | 3    | 15     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: ULL-ed decimal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          unsigned long long ull;
          ull = 123LLU; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 11     |
      | W0100 | 3    | 24     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: ULL-ed octal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          unsigned long long ull;
          ull = 0123ULL; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 11     |
      | W0100 | 3    | 24     |
      | W0834 | 3    | 5      |
      | W0529 | 4    | 11     |
      | W0628 | 1    | 6      |

  Scenario: ULL-ed hexadecimal-constant in assignment-expression
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          unsigned long long ull;
          ull = 0x123LLU; /* W0833 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0833 | 4    | 11     |
      | W0100 | 3    | 24     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: L-ed decimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long l = 123L; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |

  Scenario: LL-ed octal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long l = 0123L; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0529 | 1    | 10     |

  Scenario: LL-ed hexadecimal-constant in initializer
    Given a target source named "fixture.c" with:
      """
      long l = 0x123L; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
