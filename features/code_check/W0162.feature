Feature: W0162

  W0162 detects that `short' value is converted into `unsigned short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          unsigned short b = a; /* W0162 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0162 | 3    | 24     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          unsigned short b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 3    | 24     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          unsigned short b;
          b = a; /* W0162 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0162 | 4    | 9      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          unsigned short b;
          b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 4    | 9      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(short a)
      {
          bar(a); /* W0162 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0162 | 5    | 9      |
      | W0104 | 3    | 16     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(short a)
      {
          bar((unsigned short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0608 | 5    | 9      |
      | W0104 | 3    | 16     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(short a)
      {
          return a; /* W0162 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0162 | 3    | 12     |
      | W0298 | 3    | 5      |
      | W0104 | 1    | 26     |
      | W0628 | 1    | 16     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(short a)
      {
          return (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0608 | 3    | 12     |
      | W0104 | 1    | 26     |
      | W0628 | 1    | 16     |
