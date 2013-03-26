Feature: W0780

  W0780 detects that a left shift-expression of unsigned constant value
  discards upper non-zero bits.

  Scenario: discarding 3 of zero bits and 1 of non-zero bit in `unsigned int'
            constant
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(void)
      {
          return 0x08000000U << 5; /* W0780 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0115 | 3    | 24     |
      | W0780 | 3    | 24     |
      | W0628 | 1    | 14     |

  Scenario: discarding 4 of zero bits in `unsigned int' constant
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(void)
      {
          return 0x08000000U << 4; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0628 | 1    | 14     |

  Scenario: discarding 3 of zero bits and 1 of non-zero bit in `unsigned long'
            constant
    Given a target source named "fixture.c" with:
      """
      unsigned long foo(void)
      {
          return 0x08000000UL << 5; /* W0780 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1   | 15   |
      | W0115 | 3   | 25   |
      | W0780 | 3   | 25   |
      | W0628 | 1   | 15   |

  Scenario: discarding 4 of zero bits in `unsigned int' constant
    Given a target source named "fixture.c" with:
      """
      unsigned long foo(void)
      {
          return 0x08000000UL << 4; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0628 | 1    | 15     |
