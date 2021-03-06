Feature: W0146

  W0146 detects that `unsigned int' value is converted into `short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          short b = a; /* W0146 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0146 | 3    | 15     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          short b = (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 23     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          short b;
          b = a; /* W0146 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0146 | 4    | 9      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          short b;
          b = (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 4    | 9      |
      | C1000 |      |        |
      | C1006 | 1    | 23     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(unsigned int a)
      {
          bar(a); /* W0146 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0146 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(unsigned int a)
      {
          bar((short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W1049 | 5    | 9      |
      | C1000 |      |        |
      | C1006 | 3    | 23     |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(unsigned int a)
      {
          return a; /* W0146 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0146 | 3    | 12     |
      | W0282 | 3    | 5      |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 7      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(unsigned int a)
      {
          return (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W1049 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 24     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 7      |
