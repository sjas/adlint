Feature: W0794

  W0794 detects that a value of the signed integer variable is shifted to left.

  Scenario: left shifting a `signed int' value
    Given a target source named "fixture.c" with:
      """
      int func(int i)
      {
          return i << 1; /* W0794 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0570 | 3    | 14     |
      | W0572 | 3    | 14     |
      | W0794 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: right shifting a `signed int' value
    Given a target source named "fixture.c" with:
      """
      int func(int i)
      {
          return i >> 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0571 | 3    | 14     |
      | W0572 | 3    | 14     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: left shifting an `unsigned int' value
    Given a target source named "fixture.c" with:
      """
      unsigned int func(unsigned int ui)
      {
          return ui << 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0116 | 3    | 15     |
      | W0104 | 1    | 32     |
      | W0628 | 1    | 14     |

  Scenario: left shifting a `signed int' constant
    Given a target source named "fixture.c" with:
      """
      int func(void)
      {
          return 123 << 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0572 | 3    | 16     |
      | W0628 | 1    | 5      |

  Scenario: left shifting an `unsigned char' value which will be
            integer-promoted to `signed int'
    Given a target source named "fixture.c" with:
      """
      int func(unsigned char uc)
      {
          return uc << 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0246 | 3    | 12     |
      | W0116 | 3    | 15     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 5      |
