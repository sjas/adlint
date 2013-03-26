Feature: W0763

  W0763 detects that `unsigned long long' value is converted into
  `unsigned char' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          unsigned char b = a; /* W0763 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0763 | 3    | 23     |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          unsigned char b = (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          unsigned char b;
          b = a; /* W0763 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0763 | 4    | 9      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          unsigned char b;
          b = (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned char);

      void foo(unsigned long long a)
      {
          bar(a); /* W0763 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0763 | 5    | 9      |
      | W0104 | 3    | 29     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned char);

      void foo(unsigned long long a)
      {
          bar((unsigned char) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 29     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned char foo(unsigned long long a)
      {
          return a; /* W0763 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0763 | 3    | 12     |
      | W0397 | 3    | 5      |
      | W0104 | 1    | 38     |
      | W0834 | 1    | 19     |
      | W0628 | 1    | 15     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned char foo(unsigned long long a)
      {
          return (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0104 | 1    | 38     |
      | W0834 | 1    | 19     |
      | W0628 | 1    | 15     |
