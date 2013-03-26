Feature: W0752

  W0752 detects that `unsigned int' value is converted into `unsigned short'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          unsigned short b = a; /* W0752 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0752 | 3    | 24     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          unsigned short b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          unsigned short b;
          b = a; /* W0752 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0752 | 4    | 9      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          unsigned short b;
          b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(unsigned int a)
      {
          bar(a); /* W0752 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0752 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(unsigned int a)
      {
          bar((unsigned short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(unsigned int a)
      {
          return a; /* W0752 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0752 | 3    | 12     |
      | W0386 | 3    | 5      |
      | W0104 | 1    | 33     |
      | W0628 | 1    | 16     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(unsigned int a)
      {
          return (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0104 | 1    | 33     |
      | W0628 | 1    | 16     |
