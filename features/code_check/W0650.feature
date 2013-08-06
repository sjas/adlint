Feature: W0650

  W0650 detects that right hand side of shift-expression is greater than the
  bit length of left hand side value.

  Scenario: 32-bit left shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i << 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 31     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 32-bit right shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i >> 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 31-bit left shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i << 31; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 31     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 31-bit right shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i >> 31; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 64-bit left shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i << 64; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 31     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 64-bit right shift-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned int i)
      {
          return i >> 64; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 14     |

  Scenario: 32-bit left shift compound-assignment-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int i)
      {
          i <<= 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0116 | 3    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 23     |
      | W0650 | 3    | 7      |
      | W0628 | 1    | 6      |

  Scenario: 32-bit right shift compound-assignment-expression of `int' value
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int i)
      {
          i >>= 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0650 | 3    | 7      |
      | W0628 | 1    | 6      |

  Scenario: 31-bit left shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c << 31; /* OK because of the integer-promotion */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0123 | 3    | 12     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0719 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: 31-bit right shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c >> 31; /* OK because of the integer-promotion */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0123 | 3    | 12     |
      | W0719 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: 31-bit left shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c << 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0123 | 3    | 12     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: 31-bit right shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c >> 32; /* W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0123 | 3    | 12     |
      | W0650 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |
