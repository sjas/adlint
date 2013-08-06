Feature: W0144

  W0144 detects that `unsigned short' value is converted into `short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned short a)
      {
          short b = a; /* W0144 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0144 | 3    | 15     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned short a)
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
      | C1006 | 1    | 25     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned short a)
      {
          short b;
          b = a; /* W0144 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0144 | 4    | 9      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned short a)
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
      | C1006 | 1    | 25     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(unsigned short a)
      {
          bar(a); /* W0144 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0144 | 5    | 9      |
      | W0104 | 3    | 25     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(unsigned short a)
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
      | C1006 | 3    | 25     |
      | W0104 | 3    | 25     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(unsigned short a)
      {
          return a; /* W0144 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0144 | 3    | 12     |
      | W0280 | 3    | 5      |
      | W0104 | 1    | 26     |
      | W0628 | 1    | 7      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(unsigned short a)
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
      | C1006 | 1    | 26     |
      | W0104 | 1    | 26     |
      | W0628 | 1    | 7      |
