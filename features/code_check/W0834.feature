Feature: W0834

  W0834 detects that a `long long' type of the ISO C99 standard is used.

  Scenario: `long long' global variable declaration
    Given a target source named "fixture.c" with:
      """
      extern long long ll; /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 18     |
      | W0834 | 1    | 8      |

  Scenario: `long long' global variable definition
    Given a target source named "fixture.c" with:
      """
      static long long ll; /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0834 | 1    | 8      |

  Scenario: `long long' parameter in function declaration
    Given a target source named "fixture.c" with:
      """
      extern void foo(long long ll); /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0834 | 1    | 17     |

  Scenario: `long long' parameter in function definition
    Given a target source named "fixture.c" with:
      """
      static void foo(long long ll) /* W0834 */
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0031 | 1    | 27     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 13     |
      | W0834 | 1    | 17     |
      | W0628 | 1    | 13     |

  Scenario: `long long' function local variable definition
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          long long ll = 0; /* W0834 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0100 | 3    | 15     |
      | W0629 | 1    | 13     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 13     |

  Scenario: `long long' as return type in function declaration
    Given a target source named "fixture.c" with:
      """
      extern long long foo(void); /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 18     |
      | W0834 | 1    | 8      |

  Scenario: `long long' as return type in function definition
    Given a target source named "fixture.c" with:
      """
      static long long foo(void) /* W0834 */
      {
          return 0LL;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 18     |
      | W0833 | 3    | 12     |
      | W0629 | 1    | 18     |
      | W0834 | 1    | 8      |
      | W0628 | 1    | 18     |

  Scenario: `long long' in cast-expression
    Given a target source named "fixture.c" with:
      """
      static long long foo(void) /* W0834 */
      {
          return (long long) 0; /* W0834 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 18     |
      | W0629 | 1    | 18     |
      | W0834 | 1    | 8      |
      | W0834 | 3    | 13     |
      | W0628 | 1    | 18     |

  Scenario: `long long' in sizeof-expression
    Given a target source named "fixture.c" with:
      """
      #include <stddef.h>

      static size_t foo(void)
      {
          return sizeof(long long); /* W0834 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 15     |
      | W0629 | 3    | 15     |
      | W0834 | 5    | 19     |
      | W0628 | 3    | 15     |

  Scenario: multiple `long long' parameters in function declaration
    Given a target source named "fixture.c" with:
      """
      extern void foo(long long a, int b, long long b); /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0834 | 1    | 17     |
      | W0834 | 1    | 37     |

  Scenario: nested function-declarators with `long long'
    Given a target source named "fixture.c" with:
      """
      extern void (*p)(long long, int (*)(long long), unsigned long long); /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 15     |
      | W0834 | 1    | 18     |
      | W0834 | 1    | 37     |
      | W0834 | 1    | 49     |

  Scenario: `long long' member in struct and union type.
    Given a target source named "fixture.c" with:
      """
      struct Foo {
          int i;
          long long ll; /* W0834 */
          union {
              int i;
              long long ll; /* W0834 */
          } u;
      } foo;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 8    | 3      |
      | W0834 | 3    | 5      |
      | W0834 | 6    | 9      |
      | W0551 | 4    | 5      |

  Scenario: nested function-declarators with `long long' in typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef void (*p)(long long, int (*)(long long), signed long long); /* W0834 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0834 | 1    | 19     |
      | W0834 | 1    | 38     |
      | W0834 | 1    | 50     |
