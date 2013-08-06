Feature: W0644

  W0644 detects that an expression refers the value of a `void' expression.

  Scenario: casting value of the `void' function
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return (int) foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 12     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in
            array-subscript-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int a[])
      {
          return a[foo()]; /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 13     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in function-call-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);
      extern void bar(int);

      void baz(void)
      {
          bar(foo()); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0118 | 2    | 13     |
      | W0117 | 4    | 6      |
      | W0644 | 6    | 12     |
      | W1026 | 6    | 12     |
      | W0628 | 4    | 6      |

  Scenario: referring value of the `void' function in multiplicative-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i * foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            multiplicative-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() / foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in additive-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i + foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in additive-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() + foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in shift-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i << foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0570 | 5    | 14     |
      | C1000 |      |        |
      | C1006 | 3    | 13     |
      | W0572 | 5    | 14     |
      | W0794 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in shift-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() << foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in relational-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i < foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0610 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            relational-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() > foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in equality-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i == foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            relational-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() != foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in and-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i & foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in and-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() & foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in exclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i ^ foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            exclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() ^ foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in inclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          return i | foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            inclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          return foo() | foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in logical-and-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          if (i && foo()) { /* W0644 */
              return 0;
          }

          return i && foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 11     |
      | W0035 | 5    | 11     |
      | W0644 | 9    | 14     |
      | W0035 | 9    | 14     |
      | W0104 | 3    | 13     |
      | W1071 | 3    | 5      |
      | W0488 | 5    | 9      |
      | W0508 | 5    | 11     |
      | W0488 | 9    | 12     |
      | W0508 | 9    | 14     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            exclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          if (foo() && foo()) { /* W0644 */
              return 0;
          }

          return foo() && foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 15     |
      | W0035 | 5    | 15     |
      | W0644 | 9    | 18     |
      | W0035 | 9    | 18     |
      | W1071 | 3    | 5      |
      | W0488 | 5    | 9      |
      | W0508 | 5    | 15     |
      | W0488 | 9    | 12     |
      | W0508 | 9    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in logical-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(int i)
      {
          if (i || foo()) { /* W0644 */
              return 0;
          }

          return i || foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 11     |
      | W0035 | 5    | 11     |
      | W0644 | 9    | 14     |
      | W0035 | 9    | 14     |
      | W0104 | 3    | 13     |
      | W1071 | 3    | 5      |
      | W0488 | 5    | 9      |
      | W0508 | 5    | 11     |
      | W0488 | 9    | 12     |
      | W0508 | 9    | 14     |
      | W0628 | 3    | 5      |

  Scenario: referring two values of the `void' function in
            exclusive-or-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      int bar(void)
      {
          if (foo() || foo()) { /* W0644 */
              return 0;
          }

          return foo() || foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0644 | 5    | 15     |
      | W0035 | 5    | 15     |
      | W0644 | 9    | 18     |
      | W0035 | 9    | 18     |
      | W1071 | 3    | 5      |
      | W0488 | 5    | 9      |
      | W0508 | 5    | 15     |
      | W0488 | 9    | 12     |
      | W0508 | 9    | 18     |
      | W0628 | 3    | 5      |

  Scenario: referring value of the `void' function in assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      void bar(int i)
      {
          i = foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0644 | 5    | 7      |
      | W0628 | 3    | 6      |

  Scenario: referring value of the `void' function in
            compound-assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);

      void bar(int i)
      {
          i += foo(); /* W0644 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0644 | 5    | 7      |
      | W0628 | 3    | 6      |
