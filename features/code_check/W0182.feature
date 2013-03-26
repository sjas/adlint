Feature: W0182

  W0182 detects that `unsigned char' value is converted into `float' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned char a)
      {
          float b = a; /* W0182 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0182 | 3    | 15     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned char a)
      {
          float b = (float) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned char a)
      {
          float b;
          b = a; /* W0182 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0182 | 4    | 9      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned char a)
      {
          float b;
          b = (float) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(float);

      void foo(unsigned char a)
      {
          bar(a); /* W0182 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0182 | 5    | 9      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(float);

      void foo(unsigned char a)
      {
          bar((float) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      float foo(unsigned char a)
      {
          return a; /* W0182 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0182 | 3    | 12     |
      | W0318 | 3    | 5      |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 7      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      float foo(unsigned char a)
      {
          return (float) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 7      |
