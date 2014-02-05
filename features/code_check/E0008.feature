Feature: E0008

  E0008 detects that a syntax error occured.

  Scenario: statements in initializer
    Given a target source named "fixture.c" with:
      """
      #ifdef FOOFOO
      void foo1(void);
      #endif

      void foo2(void); /* OK not E0008 */

      /**/\
      #define FOO 1
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 5    | 6      |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef int foo;
      typedef struct bar { foo f; } baz, *qux;
      typedef struct bar baz, *qux;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 2    | 37     |
      | W0425 | 3    | 26     |
      | W0586 | 2    | 31     |
      | W0586 | 3    | 20     |
      | W0586 | 2    | 37     |
      | W0586 | 3    | 26     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef enum foo { FOO } bar, *baz;
      typedef enum foo bar, *baz;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 1    | 32     |
      | W0425 | 2    | 24     |
      | W0586 | 1    | 26     |
      | W0586 | 2    | 18     |
      | W0586 | 1    | 32     |
      | W0586 | 2    | 24     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef struct foo { int i; } bar, *baz;
      typedef struct foo bar, *baz;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 1    | 37     |
      | W0425 | 2    | 26     |
      | W0586 | 1    | 31     |
      | W0586 | 2    | 20     |
      | W0586 | 1    | 37     |
      | W0586 | 2    | 26     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef struct foo { int i; } bar, *baz;
      typedef struct foo {} bar, *baz;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0703 | 2    | 16     |
      | C0001 | 1    | 16     |
      | W0785 | 2    | 16     |
      | W0801 | 1    | 16     |
      | W0801 | 2    | 16     |
      | W0425 | 1    | 37     |
      | W0425 | 2    | 29     |
      | W0586 | 1    | 31     |
      | W0586 | 2    | 23     |
      | W0586 | 1    | 37     |
      | W0586 | 2    | 29     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef struct foo { int i; } bar, *baz;
      typedef struct foo bar;
      typedef struct foo *baz;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 1    | 37     |
      | W0586 | 1    | 31     |
      | W0586 | 2    | 20     |
      | W0586 | 1    | 37     |
      | W0586 | 3    | 21     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef int foo, *bar;
      typedef int foo, *bar;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 1    | 19     |
      | W0425 | 2    | 19     |
      | W0586 | 1    | 13     |
      | W0586 | 2    | 13     |
      | W0586 | 1    | 19     |
      | W0586 | 2    | 19     |

  Scenario: repeated multiple typedefs in a typedef declaration
    Given a target source named "fixture.c" with:
      """
      typedef int foo, *bar, **baz;
      typedef int foo, *bar, **baz;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0425 | 1    | 19     |
      | W0425 | 1    | 26     |
      | W0425 | 2    | 19     |
      | W0425 | 2    | 26     |
      | W0586 | 1    | 13     |
      | W0586 | 2    | 13     |
      | W0586 | 1    | 19     |
      | W0586 | 2    | 19     |
      | W0586 | 1    | 26     |
      | W0586 | 2    | 26     |

  Scenario: concatenating hexadecimal prefix and number in function-form macro
    Given a target source named "fixture.c" with:
      """
      #define HEX(num) 0x##num

      static void foo(void)
      {
          int i = HEX(123); /* should be replaced into "0x123" not "0 x123" */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W1076 | 3    | 13     |
      | W0076 | 5    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: concatenating hexadecimal prefix and number in function-form macro
    Given a target source named "fixture.c" with:
      """
      #define HEX(num) 0x##num

      static void foo(void)
      {
          int i = HEX(AB123CD); /* should be replaced into "0xAB123CD" */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W1076 | 3    | 13     |
      | W0076 | 5    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: concatenating hexadecimal prefix and number in function-form macro
    Given a target source named "fixture.c" with:
      """
      #define HEX(num) 0x##num

      static void foo(void)
      {
          int i = HEX(ABCD); /* should be replaced into "0xABCD" */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W1076 | 3    | 13     |
      | W0076 | 5    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: concatenating hexadecimal prefix and number in function-form macro
    Given a target source named "fixture.c" with:
      """
      #define HEX(num) 0##num

      static void foo(void)
      {
          int i = HEX(x123); /* should be replaced into "0x123" not "0 x123" */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W1076 | 3    | 13     |
      | W0076 | 5    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: concatenating hexadecimal prefix and number in function-form macro
    Given a target source named "fixture.c" with:
      """
      #define HEX(num) 0x0##num

      static void foo(void)
      {
          int i = HEX(123); /* should be replaced into "0x0123" */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W1076 | 3    | 13     |
      | W0076 | 5    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: ill-formed standalone hexadecimal prefix
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i = 0x;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
