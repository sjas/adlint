Feature: W9003

  W9003 detects that an object is implicitly converted into a new object of
  the different type.

  Scenario: passing an enum variable whose type differs from one of the
            corresponding enum parameter
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Fruit { APPLE, BANANA, ORANGE };

      extern void foo(enum Color);

      static void bar(void)
      {
          foo(ORANGE); /* W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W1076 | 6    | 13     |
      | W9003 | 8    | 9      |
      | W0728 | 8    | 9      |
      | W0629 | 6    | 13     |
      | W0628 | 6    | 13     |

  Scenario: passing an enum argument as an `int' parameter
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(int);

      static void bar(void)
      {
          foo(RED); /* W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 9      |
      | W1059 | 7    | 9      |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: passing an `int' argument as an enum parameter
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      extern void foo(enum Color);

      static void bar(void)
      {
          foo(0); /* W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W9003 | 7    | 9      |
      | W1053 | 7    | 9      |
      | W0629 | 5    | 13     |
      | W0628 | 5    | 13     |

  Scenario: initializing an `int' variable with an enumerator
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      int i = RED; /* W9003 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W9003 | 2    | 9      |
      | W0117 | 2    | 5      |

  Scenario: initializing an enum variable with an `int' value
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };
      enum Color c = 1; /* W9003 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W9003 | 2    | 16     |
      | W0117 | 2    | 12     |

  Scenario: arithmetic expression with an `int' variable and an enum variable
    Given a target source named "fixture.c" with:
      """
      enum Color { RED, BLUE, GREEN };

      static int foo(enum Color c)
      {
          if (c == RED || c == BLUE || c == GREEN) {
              return c + 10; /* W9003 */
          }
          else {
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0727 | 6    | 20     |
      | W9003 | 6    | 20     |
      | W9003 | 6    | 18     |
      | W1060 | 6    | 18     |
      | W0104 | 3    | 27     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0490 | 5    | 9      |
      | W0497 | 5    | 9      |
      | W0502 | 5    | 9      |
      | W0628 | 3    | 12     |

  Scenario: no implicit conversion of size_t value
    Given a target source named "fixture.c" with:
      """
      #include <stddef.h>

      size_t foo(int a)
      {
          return sizeof(a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 8      |
      | W0031 | 3    | 16     |
      | W0104 | 3    | 16     |
      | W0628 | 3    | 8      |

  Scenario: implicit conversion of size_t value
    Given a target source named "fixture.c" with:
      """
      #include <stddef.h>

      int foo(int a)
      {
          return sizeof(a); /* W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0150 | 5    | 12     |
      | W9003 | 5    | 12     |
      | W0286 | 5    | 5      |
      | W0031 | 3    | 13     |
      | W0104 | 3    | 13     |
      | W0070 | 1    | 1      |
      | W0628 | 3    | 5      |

  Scenario: explicit conversion of size_t value
    Given a target source named "fixture.c" with:
      """
      #include <stddef.h>

      int foo(int a)
      {
          return (int) sizeof(a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0031 | 3    | 13     |
      | W0104 | 3    | 13     |
      | W0070 | 1    | 1      |
      | W0628 | 3    | 5      |

  Scenario: implicit conversion to void pointer
    Given a target source named "fixture.c" with:
      """
      typedef struct foo { int i; } foo_t;
      extern void foo(foo_t *);

      typedef struct bar { int i; } bar_t;
      extern void bar(bar_t *);

      extern void baz(void *);

      static void qux(foo_t *f, bar_t *b)
      {
          foo(b); /* W9003 */
          bar(f); /* W9003 */
          foo(f); /* OK */
          baz(f); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 2    | 13     |
      | W0118 | 5    | 13     |
      | W0118 | 7    | 13     |
      | W1076 | 9    | 13     |
      | W9003 | 11   | 9      |
      | W9003 | 12   | 9      |
      | W0104 | 9    | 24     |
      | W0104 | 9    | 34     |
      | W0105 | 9    | 24     |
      | W0105 | 9    | 34     |
      | W0629 | 9    | 13     |
      | W0628 | 9    | 13     |

  Scenario: implicit convertion from void pointer
    Given a target source named "fixture.c" with:
      """
      typedef struct foo { int i; } foo_t;
      extern void *foo(foo_t *);

      static void bar(void *p)
      {
          foo_t *f = foo(p); /* legal but W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 2    | 14     |
      | W1076 | 4    | 13     |
      | W9003 | 6    | 20     |
      | W9003 | 6    | 19     |
      | W0100 | 6    | 12     |
      | W0104 | 4    | 23     |
      | W0105 | 4    | 23     |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |

  Scenario: implicit convertion of constant pointer
    Given a target source named "fixture.c" with:
      """
      static void foo(void *p)
      {
          int *p1 = NULL; /* OK */
          int *p2 = 0; /* OK */
          int *p3 = p; /* legal but W9003 */
          int *p4 = 3; /* W9003 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W9003 | 5    | 15     |
      | W9003 | 6    | 15     |
      | W0100 | 3    | 10     |
      | W0100 | 4    | 10     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 10     |
      | W0104 | 1    | 23     |
      | W0105 | 1    | 23     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: no implicit convertion of register variable
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          register char a[3];
          char *p;
          p = &a[0]; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0459 | 5    | 9      |
      | W0642 | 5    | 9      |
      | W0100 | 3    | 19     |
      | W0100 | 4    | 11     |
      | W0629 | 1    | 13     |
      | W0950 | 3    | 21     |
      | W0628 | 1    | 13     |
