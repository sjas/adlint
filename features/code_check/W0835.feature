Feature: W0835

  W0835 detects that a function like macro with variable arguments is defined.

  Scenario: function declaration helper macro
    Given a target source named "fixture.c" with:
      """
      #define defun(type, name, ...) /* W0835 has not been implemented yet */ \
          extern type builtin_##name(__VA_ARGS__)

      defun(int, foo, int);
      defun(long, bar, int, long);
      defun(int, baz);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 2    | 12     |
      | W0118 | 4    | 1      |
      | W0118 | 5    | 1      |
      | W0118 | 6    | 1      |
      | W0478 | 1    | 1      |
      | W0078 | 6    | 1      |

  Scenario: initializer generator macro
    Given a target source named "fixture.c" with:
      """
      #define init(...) /* W0835 has not been implemented yet */ \
          { 0, __VA_ARGS__, -1 }

      int a[] = init(1, 2, 3);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 4    | 5      |

  Scenario: initializer generator macro with ## operator
    Given a target source named "fixture.c" with:
      """
      #define init(...) /* W0835 has not been implemented yet */ \
          { 0, ## __VA_ARGS__, -1 }

      int a[] = init(1, 2, 3);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0691 | 4    | 11     |
      | W0117 | 4    | 5      |

  Scenario: interface to a varg function
    Given a target source named "fixture.c" with:
      """
      extern int printf(const char *, ...);
      extern const char *mesg(int);

      #define msg(n) mesg(100 + (n))
      #define log(fmt, ...) /* W0835 has not been implemented yet */ \
          (void) printf((fmt), __VA_ARGS__)

      static void func(void)
      {
          log("%d %d", 1, 2);
          log("%d %s %s", 1, msg(1), msg(1 + 2));
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 4    | 1      |
      | W0442 | 5    | 1      |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 20     |
      | W1076 | 8    | 13     |
      | W0629 | 8    | 13     |
      | W0443 | 4    | 1      |
      | W0628 | 8    | 13     |

  Scenario: interface to a varg function with ## operator
    Given a target source named "fixture.c" with:
      """
      extern int printf(const char *, ...);
      extern const char *mesg(int);

      #define msg(n) mesg(100 + (n))
      #define log(fmt, ...) /* W0835 has not been implemented yet */ \
          (void) printf((fmt), ##__VA_ARGS__)

      static void func(void)
      {
          log("%d %d", 1, 2);
          log("%d %s %s", 1, msg(1), msg(1 + 2));
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 4    | 1      |
      | W0442 | 5    | 1      |
      | W0691 | 10   | 5      |
      | W0691 | 11   | 5      |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 20     |
      | W1076 | 8    | 13     |
      | W0629 | 8    | 13     |
      | W0443 | 4    | 1      |
      | W0628 | 8    | 13     |
