Feature: W0719

  W0719 detects that the right hand side of the shift-expression is greater
  than the bit length of underlying type of the left hand side.

  Scenario: 31-bit left shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c << 31; /* W0719 */
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
          return c >> 31; /* W0719 */
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

  Scenario: 7-bit left shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c << 7; /* OK */
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
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: 7-bit right shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c >> 7; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0123 | 3    | 12     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: 31-bit left shift compound-assignment-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      void foo(char c)
      {
          c <<= 31; /* W0719 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0123 | 3    | 5      |
      | W0116 | 3    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 15     |
      | W0719 | 3    | 7      |
      | W0136 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: 31-bit right shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c >> 31; /* W0719 */
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

  Scenario: 63-bit left shift compound-assignment-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      void foo(char c)
      {
          c <<= 63; /* OK but W0650 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0123 | 3    | 5      |
      | W0116 | 3    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 15     |
      | W0650 | 3    | 7      |
      | W0136 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: 63-bit right shift-expression of `char' value
    Given a target source named "fixture.c" with:
      """
      int foo(char c)
      {
          return c >> 63; /* OK but W0650 */
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
